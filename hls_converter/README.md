# HLS Packaging Script

This project provides a Python script for converting video files into HLS (HTTP Live Streaming) format at multiple resolutions.

## Features

- Converts video to HLS at 320p, 480p, 720p, and 1080p (if applicable).
- Organizes HLS output into a structured folder hierarchy.

## Requirements

- Python 3.7+
- FFmpeg installed and added to your system's PATH.

### How to Install FFmpeg

**Windows:**
1. Download the latest FFmpeg build from [ffmpeg.org/download.html](https://ffmpeg.org/download.html).
2. Extract the downloaded archive to a directory (e.g., `C:\ffmpeg`).
3. Add the `bin` directory (e.g., `C:\ffmpeg\bin`) to your system's PATH environment variable.

**macOS:**
```bash
brew install ffmpeg
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install ffmpeg
```

## Usage

1.  **Clone the repository (or download the files):**

    ```bash
    git clone <repository_url>
    cd hls_converter
    ```

2.  **Run the script:**

    ```bash
    python main.py <input_video_file> <output_directory>
    ```

    - `<input_video_file>`: The path to your source video file (e.g., `video.mp4`).
    - `<output_directory>`: The directory where the HLS output will be saved (e.g., `output`).

    **Example:**
    ```bash
    python main.py my_video.mp4 output/
    ```

    This will create a directory structure like:
    ```
    output/
      my_video/
        f_320/
          index.m3u8
          segment0.ts
          ...
        f_480/
        f_720/
        f_1080/
    ```
