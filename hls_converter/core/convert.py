from core.helpers import create_out_directories, get_video_info
import subprocess
import os

def convert_to_hls(input_file, base_output_dir):
    if not os.path.exists(input_file):
        print(f"❌ Input file not found: {input_file}")
        return

    filename_base = os.path.splitext(os.path.basename(input_file))[0]
    output_dirs = create_out_directories(base_output_dir, filename_base)
    width, height = get_video_info(input_file)

    if not width or not height:
        print("❌ Failed to retrieve video dimensions.")
        return

    resolutions = {
        "1080p": (1920, 1080),
        "720p": (1280, 720),
        "480p": (854, 480),
        "320p": (568, 320),
    }

    applicable = {
        name: (w, h) for name, (w, h) in resolutions.items() if height >= h
    }

    if not applicable:
        print("❌ Input video is too small for all target resolutions.")
        return

    for res_name, (res_w, res_h) in applicable.items():
        folder = f"f_{res_name.replace('p', '')}"
        output_path = output_dirs.get(folder)
        if not output_path:
            print(f"⚠️ Skipping {res_name} – output directory missing.")
            continue

        print(f"🔄 Converting to {res_name}...")

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

        try:
            subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            print(f"✅ {res_name} HLS generated at: {output_path}")
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed {res_name}: {e}")
            print(f"🧾 FFmpeg stdout: {e.stdout.decode()}")
            print(f"🧾 FFmpeg stderr: {e.stderr.decode()}")
        except Exception as e:
            print(f"❌ Unexpected error during {res_name} conversion: {e}")
