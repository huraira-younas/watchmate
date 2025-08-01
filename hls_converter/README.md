# HLS Converter GUI

A modern Python-based GUI application to convert videos into HLS (HTTP Live Streaming) format at multiple resolutions using FFmpeg.

## ✨ Features

- Beautiful dark-themed user interface built with PyQt5.
- Select multiple input videos for batch HLS conversion.
- Choose desired output resolutions (320p, 480p, 720p, 1080p).
- Real-time conversion logs with progress updates.
- Option to stop all conversions mid-process.
- Easy to use – no command line required.

## 🛠 Requirements

- Python 3.7+
- FFmpeg must be installed and accessible via system PATH.

## 📦 How to Install FFmpeg

### Windows

**Manual:**
1. Download the latest build from [ffmpeg.org/download.html](https://ffmpeg.org/download.html)
2. Extract it to a directory (e.g., `C:\ffmpeg`)
3. Add `C:\ffmpeg\bin` to your system's PATH environment variable

**Winget:**
```bash
winget install ffmpeg
```

### macOS
```bash
brew install ffmpeg
```

### Ubuntu/Debian Linux
```bash
sudo apt update
sudo apt install ffmpeg
```

## 🚀 How to Use

1. Clone or download this repository:
```bash
git clone https://github.com/huraira-younas/watchmate
cd hls_converter
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the app:
```bash
python -m gui
```

### GUI Instructions

- Input videos are loaded from the `input/` directory.
- Select one or more videos using the checkboxes.
- Select desired output resolutions.
- Click **Convert Selected** to begin HLS conversion.
- The converted HLS files will appear in the `output/` directory.

## 📂 Output Folder Structure

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

## 📁 Project Structure

```
hls_converter/
├── core/
│   └── convert.py
├── gui/
│   └── __main__.py
├── input/
│   └── (Place your source videos here)
├── output/
│   └── (Converted HLS files will be saved here)
├── constants.py
└── requirements.txt
```

## 📃 License

MIT License – do whatever you want with proper credit.
