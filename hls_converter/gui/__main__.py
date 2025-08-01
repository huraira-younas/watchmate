import sys
import os
import threading
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QPushButton,
    QListWidget, QListWidgetItem, QTextEdit, QGroupBox, QMessageBox,    
    QSizePolicy
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from PyQt5.QtGui import QFont, QPalette, QColor

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
            self.log_message.emit(f"➡️ Starting: {os.path.basename(self.input_path)}")
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
        self.setWindowTitle("WM-HLS Converter")
        self.setFont(QFont("Roboto", 10))
        self.conversion_threads = []
        self.active_conversions = 0
        self.set_dark_theme()
        self.resize(1080, 720)
        self.init_ui()
        self.load_videos()
        self.load_resolutions()

    def set_dark_theme(self):
        palette = QPalette()
        palette.setColor(QPalette.HighlightedText, QColor("#ffffff"))
        palette.setColor(QPalette.WindowText, QColor("#e2e8f0"))
        palette.setColor(QPalette.ButtonText, QColor("#ffffff"))
        palette.setColor(QPalette.Highlight, QColor("#63b3ed"))
        palette.setColor(QPalette.Window, QColor("#1a202c"))
        palette.setColor(QPalette.Button, QColor("#4299e1"))
        palette.setColor(QPalette.Base, QColor("#2d3748"))
        palette.setColor(QPalette.Text, QColor("#e2e8f0"))
        self.setPalette(palette)

        self.setStyleSheet("""
            QWidget {
                background-color: #1a202c;
                font-family: 'Roboto';
                color: #e2e8f0;
            }
            QGroupBox {
                padding: 10px 6px 6px 6px;
                border: 1px solid #4a5568;
                border-radius: 8px;
                margin-top: 20px;
            }
            
            QGroupBox::title {
                subcontrol-position: top;
                subcontrol-origin: margin;
                background-color: #1a202c;
                border-radius: 4px;
                font-weight: bold;
                margin-top: 10px;
                padding: 0 6px;
                color: #63b3ed;
            }
            QPushButton {
                background-color: #4299e1;
                padding: 12px 20px;
                border-radius: 8px;
                font-weight: bold;
                font-size: 15px;
                color: #ffffff;
                border: none;
            }
            QPushButton:hover {
                background-color: #3182ce;
            }
            QPushButton:pressed {
                background-color: #2b6cb0;
            }
            QPushButton:disabled {
                background-color: #2d3748;
                color: #a0aec0;
            }
            QListWidget, QTextEdit {
                background-color: #1a202c;
                border: 1px solid #4a5568;
                border-radius: 6px;
                color: #e2e8f0;
                padding: 8px;
            }
            QListWidget::item {
                padding: 5px;
            }
            QListWidget::indicator {
                width: 20px;
                height: 20px;
                border-radius: 5px;
                border: 2px solid #4299e1;
                background-color: #2d3748;
            }
            QListWidget::indicator:unchecked {
                border: 2px solid #4a5568;
            }
            QListWidget::indicator:checked {
                background-color: #63b3ed;
                border: 2px solid #63b3ed;
            }
            QListWidget::indicator:hover {
                border: 2px solid #63b3ed;
            }
        """)

    def init_ui(self):
        main_layout = QHBoxLayout(self)
        main_layout.setContentsMargins(15, 15, 15, 15)
        main_layout.setSpacing(15)

        left_panel = QVBoxLayout()
        left_panel.setSpacing(15)

        video_group = QGroupBox("Input Videos")
        vbox_videos = QVBoxLayout(video_group)
        vbox_videos.setContentsMargins(10, 10, 10, 10)
        self.video_list_widget = QListWidget()
        self.video_list_widget.setSelectionMode(QListWidget.NoSelection)
        vbox_videos.addWidget(self.video_list_widget)
        left_panel.addWidget(video_group, 1)

        res_group = QGroupBox("Resolutions")
        res_group.setSizePolicy(QSizePolicy.Preferred, QSizePolicy.Maximum)
        vbox_res = QVBoxLayout(res_group)
        vbox_res.setContentsMargins(10, 10, 10, 10)
        self.resolution_list_widget = QListWidget()

        row_height = 34
        row_count = len(RESOLUTIONS)
        self.resolution_list_widget.setFixedHeight(row_count * row_height + 8)

        vbox_res.addWidget(self.resolution_list_widget)
        left_panel.addWidget(res_group, 0)

        button_layout = QHBoxLayout()
        button_layout.setContentsMargins(0, 0, 0, 0)
        button_layout.setSpacing(10)

        self.convert_button = QPushButton("Convert Selected")
        self.convert_button.clicked.connect(self.start_conversion)

        self.stop_button = QPushButton("Stop All")
        self.stop_button.clicked.connect(self.stop_all_conversions)
        self.stop_button.setEnabled(False)

        button_layout.addWidget(self.convert_button)
        button_layout.addWidget(self.stop_button)

        button_container = QWidget()
        button_container.setLayout(button_layout)
        left_panel.addWidget(button_container, 0)

        right_panel = QVBoxLayout()
        right_panel.setSpacing(15)

        log_group = QGroupBox("Conversion Log")
        vbox_log = QVBoxLayout(log_group)
        vbox_log.setContentsMargins(10, 10, 10, 10)
        self.log_text_edit = QTextEdit()
        self.log_text_edit.setReadOnly(True)
        vbox_log.addWidget(self.log_text_edit)
        right_panel.addWidget(log_group)

        main_layout.addLayout(left_panel, 2)
        main_layout.addLayout(right_panel, 3)


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

    def load_resolutions(self):
        self.resolution_list_widget.clear()
        for res in RESOLUTIONS:
            item = QListWidgetItem(res)
            item.setFlags(item.flags() | Qt.ItemIsUserCheckable)
            item.setCheckState(Qt.Checked)
            self.resolution_list_widget.addItem(item)

    def start_conversion(self):
        if not check_ffmpeg_installed():
            QMessageBox.critical(self, "FFmpeg Missing", "FFmpeg is not installed or not found in PATH.")
            return
        selected_videos = [self.video_list_widget.item(i).text()
                           for i in range(self.video_list_widget.count())
                           if self.video_list_widget.item(i).checkState() == Qt.Checked]
        selected_res = [self.resolution_list_widget.item(i).text()
                        for i in range(self.resolution_list_widget.count())
                        if self.resolution_list_widget.item(i).checkState() == Qt.Checked]
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
