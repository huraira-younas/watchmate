from core.helpers import check_ffmpeg_installed
from core.convert import convert_to_hls
import argparse


def main():
    parser = argparse.ArgumentParser(description="Convert video to HLS format.")
    parser.add_argument("input_file", help="Path to the input video file.")
    parser.add_argument("output_dir", help="Directory to store HLS output.")
    args = parser.parse_args()

    if not check_ffmpeg_installed():
        return

    convert_to_hls(args.input_file, args.output_dir)

if __name__ == "__main__":
    main()
