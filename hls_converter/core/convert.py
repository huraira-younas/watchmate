from core.helpers import create_out_directories, get_video_info
import subprocess
import time
import os

def convert_to_hls(input_file, base_output_dir, selected_resolutions, log_callback=None, stop_event=None):
    def log(msg):
        if log_callback:
            log_callback(msg)

    if not os.path.exists(input_file):
        log(f"❌ Input file not found: {input_file}")
        return
    
    print(selected_resolutions)

    filename_base = os.path.splitext(os.path.basename(input_file))[0]
    output_dirs = create_out_directories(base_output_dir, filename_base, selected_resolutions)

    width, height = get_video_info(input_file)
    if not width or not height:
        log("❌ Failed to retrieve video dimensions.")
        return

    resolution_map = {
        "f_1080": (1920, 1080),
        "f_720": (1280, 720),
        "f_480": (854, 480),
        "f_320": (568, 320),
    }

    applicable = {
        res_key: res_size
        for res_key, res_size in resolution_map.items()
        if res_key in selected_resolutions and height >= res_size[1]
    }

    if not applicable:
        log("❌ No applicable resolutions or video too small.")
        return

    for res_name, (res_w, res_h) in applicable.items():
        if stop_event and stop_event.is_set():
            log(f"⚠️ Conversion stopped by user: {os.path.basename(input_file)}")
            return

        output_path = output_dirs.get(res_name)
        if not output_path:
            log(f"⚠️ Skipping {res_name} - output directory missing.")
            continue

        log(f"🔄 Converting {os.path.basename(input_file)} to {res_name}...")

        command = [
            "ffmpeg", "-i", input_file,
            "-vf", f"scale={res_w}:{res_h}",
            "-c:v", "libx264", "-preset", "veryfast",
            "-g", "48", "-keyint_min", "48", "-sc_threshold", "0",
            "-c:a", "aac", "-b:a", "128k", "-ar", "48000",
            "-f", "hls", "-hls_time", "10", "-hls_playlist_type", "vod",
            "-hls_segment_filename", os.path.join(output_path, "segment%03d.ts"),
            os.path.join(output_path, "index.m3u8")
        ]

        process = None
        try:
            process = subprocess.Popen(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1
            )

            for line in iter(process.stderr.readline, ''):
                if stop_event and stop_event.is_set():
                    log(f"⏹ Terminating FFmpeg for {os.path.basename(input_file)} ({res_name})...")
                    process.terminate()
                    break
                if line.strip():
                    log(line.strip())
                time.sleep(0.01)

            stdout, stderr = process.communicate()

            if stdout.strip():
                log(stdout.strip())
            if stderr.strip():
                log(stderr.strip())

            if process.returncode == 0:
                log(f"✅ {res_name} HLS generated at: {output_path}")
            else:
                log(f"❌ Failed {res_name}: FFmpeg exited with code {process.returncode}")

        except FileNotFoundError:
            log("❌ FFmpeg not found. Ensure it is installed and added to your system's PATH.")
        except Exception as e:
            log(f"❌ Unexpected error during {res_name} conversion: {e}")
        finally:
            if process and process.poll() is None:
                process.kill()
                log(f"❌ Forced termination of FFmpeg for {os.path.basename(input_file)} ({res_name}).")
