import sys
import os
import threading
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QPushButton,
    QListWidget, QListWidgetItem, QCheckBox, QLabel, QTextEdit, QGridLayout,
    QMessageBox, QGroupBox
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

        self.setFont(QFont("Roboto", 10)) # Changed font to Roboto
        self.set_dark_theme()
        self.init_ui()
        self.load_videos()

    def set_dark_theme(self):
        palette = QPalette()
        palette.setColor(QPalette.Window, QColor("#1a202c")) # Darker bluish background
        palette.setColor(QPalette.WindowText, QColor("#e2e8f0")) # Light text
        palette.setColor(QPalette.Base, QColor("#2d3748")) # Input fields, text edit background
        palette.setColor(QPalette.Text, QColor("#e2e8f0")) # General text color
        palette.setColor(QPalette.Button, QColor("#4299e1")) # Blue buttons
        palette.setColor(QPalette.ButtonText, QColor("#ffffff")) # White button text
        palette.setColor(QPalette.Highlight, QColor("#63b3ed")) # Highlight color
        palette.setColor(QPalette.HighlightedText, QColor("#ffffff")) # Highlighted text color
        self.setPalette(palette)

        self.setStyleSheet("""
            QWidget {
                background-color: #1a202c;
                color: #e2e8f0;
                font-family: 'Roboto';
            }
            QPushButton {
                background-color: #4299e1;
                color: #ffffff;
                border: none;
                padding: 12px 20px;
                border-radius: 8px;
                font-size: 15px;
                font-weight: bold;
                outline: none;
                
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
                background-color: #1a202c; /* Match QGroupBox background */
                border: 1px solid #4a5568;
                color: #e2e8f0;
                padding: 8px;
                border-radius: 6px;
                selection-background-color: #63b3ed;
                selection-color: #ffffff;
            }
            QListWidget::item {
                padding: 5px;
            }
            QListWidget::item:selected {
                background-color: #63b3ed;
                color: #ffffff;
            }
            QListWidget::indicator {
                width: 20px;
                height: 20px;
                border-radius: 5px;
                border: 2px solid #4299e1;
                background-color: #2d3748;
            }
            QListWidget::indicator:checked {
                background-color: #4299e1;
                border: 2px solid #4299e1;
            }
            QListWidget::indicator:hover {
                border: 2px solid #63b3ed;
            }
            QCheckBox {
                color: #e2e8f0;
                spacing: 8px;
                font-size: 14px;
            }
            QCheckBox::indicator {
                width: 20px;
                height: 20px;
                border-radius: 5px;
                border: 2px solid #4299e1;
                background-color: #2d3748;
            }
            QCheckBox::indicator:checked {
                background-color: #4299e1;
                border: 2px solid #4299e1;
            }
            QCheckBox::indicator:hover {
                border: 2px solid #63b3ed;
            }
            QLabel {
                font-weight: bold;
                color: #ffffff; /* Pure white for labels */
                margin-bottom: 5px;
            }
            QGroupBox {
                border: 1px solid #4a5568;
                border-radius: 8px;
                margin-top: 10px;
                padding-top: 15px;
                background-color: #1a202c; /* Darker background for containers */
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                subcontrol-position: top left;
                padding: 0 5px;
                color: #4299e1; /* Blue for group box titles */
                font-size: 16px;
                font-weight: bold;
                left: 10px;
            }
        """)

    def init_ui(self):
        main_layout = QHBoxLayout(self)

        # Left Panel: Video Selection
        left_panel = QVBoxLayout()
        video_group = QGroupBox("🎞️ Input Videos")
        video_group.setObjectName("videoGroup") # Object name for styling
        vbox_videos = QVBoxLayout(video_group)
        self.video_list_widget = QListWidget()
        self.video_list_widget.setSelectionMode(QListWidget.NoSelection)
        vbox_videos.addWidget(self.video_list_widget)
        left_panel.addWidget(video_group)

        # Right Panel: Resolutions and Controls
        right_panel = QVBoxLayout()
        res_group = QGroupBox("📐 Resolutions")
        res_group.setObjectName("resGroup") # Object name for styling
        vbox_res = QVBoxLayout(res_group)
        self.resolution_checkboxes = []
        for res in RESOLUTIONS:
            cb = QCheckBox(res)
            cb.setChecked(True)
            cb.stateChanged.connect(lambda state, c=cb, r=res: self.update_resolution_checkbox_text(state, c, r))
            self.resolution_checkboxes.append(cb)
            vbox_res.addWidget(cb)
        right_panel.addWidget(res_group)

        # Control Buttons
        button_layout = QHBoxLayout()
        self.convert_button = QPushButton("🚀 Convert Selected")
        self.convert_button.clicked.connect(self.start_conversion)
        self.stop_button = QPushButton("🛑 Stop All")
        self.stop_button.clicked.connect(self.stop_all_conversions)
        self.stop_button.setEnabled(False)
        button_layout.addWidget(self.convert_button)
        button_layout.addWidget(self.stop_button)
        right_panel.addLayout(button_layout)

        # Log Area
        log_group = QGroupBox("📋 Conversion Log")
        log_group.setObjectName("logGroup") # Object name for styling
        vbox_log = QVBoxLayout(log_group)
        self.log_text_edit = QTextEdit()
        self.log_text_edit.setReadOnly(True)
        vbox_log.addWidget(self.log_text_edit)
        right_panel.addWidget(log_group)

        main_layout.addLayout(left_panel)
        main_layout.addLayout(right_panel)

    def update_video_item_text(self, item):
        if item.checkState() == Qt.Checked:
            item.setText("✅ " + item.text().replace("✅ ", ""))
        else:
            item.setText(item.text().replace("✅ ", ""))

    def update_resolution_checkbox_text(self, state, checkbox, original_text):
        if state == Qt.Checked:
            checkbox.setText("✅ " + original_text)
        else:
            checkbox.setText(original_text)

    def load_videos(self):
        self.video_list_widget.clear()
        if not os.path.exists(INPUT_DIR):
            self.log_text_edit.append(f"⚠️ Input directory not found: {INPUT_DIR}")
            return

        videos = [f for f in os.listdir(INPUT_DIR)
                  if os.path.isfile(os.path.join(INPUT_DIR, f)) and os.path.splitext(f)[1].lower() in VIDEO_EXTENSIONS]

        for video in videos:
            item = QListWidgetItem(video)
            item.setFlags(item.flags() | Qt.ItemIsUserCheckable | Qt.ItemIsEnabled)
            item.setCheckState(Qt.Unchecked)
            self.video_list_widget.addItem(item)
        self.video_list_widget.itemChanged.connect(self.update_video_item_text)

    def start_conversion(self):
        if not check_ffmpeg_installed():
            QMessageBox.critical(self, "FFmpeg Missing", "FFmpeg is not installed or not found in PATH.")
            return

        selected_videos = [self.video_list_widget.item(i).text().replace("✅ ", "")
                           for i in range(self.video_list_widget.count())
                           if self.video_list_widget.item(i).checkState() == Qt.Checked]

        selected_res = [cb.text().replace("✅ ", "") for cb in self.resolution_checkboxes if cb.isChecked()]

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
