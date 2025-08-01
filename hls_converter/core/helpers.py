import subprocess
import shutil
import os

def check_ffmpeg_installed():
    try:
        subprocess.run(["ffmpeg", "-version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("✅ FFmpeg is installed and ready.")
        return True
    except FileNotFoundError:
        print("❌ FFmpeg not found. Please install it and add it to your system's PATH.")
        return False

def create_out_directories(base_output_dir, filename_base, selected_resolutions):
    output_path = os.path.join(base_output_dir, filename_base)

    if os.path.exists(output_path):
        shutil.rmtree(output_path)

    os.makedirs(output_path, exist_ok=True)

    dirs = {}
    for res in selected_resolutions:
        path = os.path.join(output_path, res)
        os.makedirs(path, exist_ok=True)
        dirs[res] = path

    return dirs

def get_video_info(input_file):
    try:
        result = subprocess.run(
            ["ffprobe", "-v", "error", "-select_streams", "v:0",
             "-show_entries", "stream=width,height", "-of", "csv=p=0", input_file],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )
        width, height = map(int, result.stdout.strip().split(','))
        return width, height
    except Exception as e:
        print(f"⚠️ Unable to retrieve video info: {e}")
        return None, None

