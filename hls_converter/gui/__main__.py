import sys
import os
import threading
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QPushButton,
    QListWidget, QListWidgetItem, QCheckBox, QLabel, QTextEdit, QGridLayout,
    QMessageBox, QSizePolicy, QGroupBox
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from PyQt5.QtGui import QPalette, QColor, QFont

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from constants import INPUT_DIR, VIDEO_EXTENSIONS, RESOLUTIONS, OUTPUT_DIR
from core.convert import convert_to_hls
from core.helpers import check_ffmpeg_installed

class ConversionThread(QThread):
    conversion_finished = pyqtSignal(str)
    conversion_error = pyqtSignal(str)
    log_message = pyqtSignal(str)
    process_started = pyqtSignal()
    process_finished = pyqtSignal()

    def __init__(self, input_path, output_dir, selected_resolutions):
        super().__init__()
        self.input_path = input_path
        self.output_dir = output_dir
        self.selected_resolutions = selected_resolutions
        self.stop_event = threading.Event()

    def run(self):
        self.process_started.emit()
        try:
            self.log_message.emit(f"\n➡️ Starting: {os.path.basename(self.input_path)}")
            convert_to_hls(
                self.input_path,
                self.output_dir,
                self.selected_resolutions,
                log_callback=self.log_message.emit,
                stop_event=self.stop_event
            )
            if not self.stop_event.is_set():
                self.conversion_finished.emit(f"✅ Done: {os.path.basename(self.input_path)}")
            else:
                self.log_message.emit(f"⛔ Stopped: {os.path.basename(self.input_path)}")
        except Exception as e:
            self.conversion_error.emit(f"❌ Error converting {os.path.basename(self.input_path)}: {e}")
        finally:
            self.process_finished.emit()

    def stop(self):
        self.stop_event.set()


class HLSConverterGUI(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("🎥 HLS Converter")
        self.resize(960, 720)
        self.conversion_threads = []
        self.active_conversions = 0

        self.setFont(QFont("Segoe UI", 10))
        self.set_dark_theme()
        self.init_ui()
        self.load_videos()

    def set_dark_theme(self):
        palette = QPalette()
        palette.setColor(QPalette.Window, QColor("#1e1e2f"))
        palette.setColor(QPalette.WindowText, Qt.white)
        palette.setColor(QPalette.Base, QColor("#2a2a3d"))
        palette.setColor(QPalette.Text, Qt.white)
        palette.setColor(QPalette.Button, QColor("#3a3a55"))
        palette.setColor(QPalette.ButtonText, Qt.white)
        palette.setColor(QPalette.Highlight, QColor("#5294e2"))
        palette.setColor(QPalette.HighlightedText, Qt.white)
        self.setPalette(palette)

        self.setStyleSheet("""
            QPushButton {
                padding: 10px;
                border-radius: 6px;
                font-size: 14px;
                background-color: #3a3a55;
                border: 1px solid #444;
                color: white;
            }
            QPushButton:hover {
                background-color: #4a4a66;
            }
            QPushButton:pressed {
                background-color: #2a2a3d;
            }
            QListWidget {
                background-color: #2a2a3d;
                border: 1px solid #444;
                color: white;
            }
            QTextEdit {
                background-color: #2a2a3d;
                border: 1px solid #444;
                color: white;
            }
            QCheckBox {
                margin-left: 4px;
                color: white;
            }
            QLabel {
                font-weight: bold;
                color: white;
            }
        """)

    def init_ui(self):
        layout = QGridLayout(self)

        video_group = QGroupBox("🎞️ Input Videos")
        vbox_videos = QVBoxLayout(video_group)
        self.video_list_widget = QListWidget()
        self.video_list_widget.setSelectionMode(QListWidget.NoSelection)
        vbox_videos.addWidget(self.video_list_widget)
        layout.addWidget(video_group, 0, 0)

        res_group = QGroupBox("📐 Resolutions")
        vbox_res = QVBoxLayout(res_group)
        self.resolution_checkboxes = []
        for res in RESOLUTIONS:
            cb = QCheckBox(res)
            cb.setChecked(True)
            self.resolution_checkboxes.append(cb)
            vbox_res.addWidget(cb)
        layout.addWidget(res_group, 0, 1)

        self.convert_button = QPushButton("🚀 Convert Selected")
        self.convert_button.clicked.connect(self.start_conversion)
        self.stop_button = QPushButton("🛑 Stop All")
        self.stop_button.clicked.connect(self.stop_all_conversions)
        self.stop_button.setEnabled(False)

        layout.addWidget(self.convert_button, 1, 0)
        layout.addWidget(self.stop_button, 1, 1)

        log_group = QGroupBox("📋 Conversion Log")
        vbox_log = QVBoxLayout(log_group)
        self.log_text_edit = QTextEdit()
        self.log_text_edit.setReadOnly(True)
        vbox_log.addWidget(self.log_text_edit)
        layout.addWidget(log_group, 2, 0, 1, 2)

    def load_videos(self):
        self.video_list_widget.clear()
        if not os.path.exists(INPUT_DIR):
            self.log_text_edit.append(f"⚠️ Input directory not found: {INPUT_DIR}")
            return

        videos = [f for f in os.listdir(INPUT_DIR)
                  if os.path.isfile(os.path.join(INPUT_DIR, f)) and os.path.splitext(f)[1].lower() in VIDEO_EXTENSIONS]

        for video in videos:
            item = QListWidgetItem(video)
            item.setFlags(item.flags() | Qt.ItemIsUserCheckable)
            item.setCheckState(Qt.Unchecked)
            self.video_list_widget.addItem(item)

    def start_conversion(self):
        if not check_ffmpeg_installed():
            QMessageBox.critical(self, "FFmpeg Missing", "FFmpeg is not installed or not found in PATH.")
            return

        selected_videos = [self.video_list_widget.item(i).text()
                           for i in range(self.video_list_widget.count())
                           if self.video_list_widget.item(i).checkState() == Qt.Checked]

        selected_res = [cb.text() for cb in self.resolution_checkboxes if cb.isChecked()]

        if not selected_videos:
            QMessageBox.warning(self, "No Videos Selected", "Select at least one video to convert.")
            return
        if not selected_res:
            QMessageBox.warning(self, "No Resolutions", "Select at least one resolution.")
            return

        self.convert_button.setEnabled(False)
        self.stop_button.setEnabled(True)
        self.active_conversions = len(selected_videos)

        for video in selected_videos:
            thread = ConversionThread(os.path.join(INPUT_DIR, video), OUTPUT_DIR, selected_res)
            thread.conversion_finished.connect(self.on_conversion_finished)
            thread.conversion_error.connect(self.on_conversion_error)
            thread.log_message.connect(self.append_log)
            thread.process_finished.connect(self.on_process_finished)
            self.conversion_threads.append(thread)
            thread.start()

    def stop_all_conversions(self):
        for thread in self.conversion_threads:
            if thread.isRunning():
                thread.stop()
        self.conversion_threads.clear()
        self.convert_button.setEnabled(True)
        self.stop_button.setEnabled(False)
        self.append_log("🛑 All conversions requested to stop.")

    def on_conversion_finished(self, msg):
        self.append_log(msg)

    def on_conversion_error(self, msg):
        self.append_log(msg)
        QMessageBox.critical(self, "Conversion Error", msg)

    def on_process_finished(self):
        self.active_conversions -= 1
        if self.active_conversions <= 0:
            self.convert_button.setEnabled(True)
            self.stop_button.setEnabled(False)
            self.append_log("✅ All conversions complete.")

    def append_log(self, msg):
        self.log_text_edit.append(msg)
        self.log_text_edit.moveCursor(self.log_text_edit.textCursor().End)


def main():
    app = QApplication(sys.argv)
    gui = HLSConverterGUI()
    gui.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
