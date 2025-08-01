from constants import INPUT_DIR, VIDEO_EXTENSIONS, OUTPUT_DIR
from core.helpers import check_ffmpeg_installed
from core.convert import convert_to_hls
import os

def main():
    if not check_ffmpeg_installed():
        return

    if not os.path.exists(INPUT_DIR):
        print(f"❌ Input directory '{INPUT_DIR}' does not exist.")
        return

    videos = [
        f for f in os.listdir(INPUT_DIR)
        if os.path.isfile(os.path.join(INPUT_DIR, f)) and os.path.splitext(f)[1].lower() in VIDEO_EXTENSIONS
    ]

    if not videos:
        print("📂 No video files found in 'inputs/'.")
        return

    for video in videos:
        input_path = os.path.join(INPUT_DIR, video)
        convert_to_hls(input_path, OUTPUT_DIR)

if __name__ == "__main__":
    main()
