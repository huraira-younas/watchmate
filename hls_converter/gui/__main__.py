import threading
import sys
import os
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout, QPushButton,
    QListWidget, QListWidgetItem, QCheckBox, QLabel, QTextEdit, QGridLayout,
    QMessageBox, QSizePolicy
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from PyQt5.QtGui import QPalette, QColor, QTextCursor

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from constants import INPUT_DIR, VIDEO_EXTENSIONS, RESOLUTIONS, OUTPUT_DIR
from core.convert import convert_to_hls
from core.helpers import check_ffmpeg_installed

class ConversionThread(QThread):
    """Thread to run the HLS conversion in the background."""
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
        self.stop_event = threading.Event() # Event to signal stopping

    def run(self):
        self.process_started.emit()
        try:
            self.log_message.emit(f"Starting conversion for: {os.path.basename(self.input_path)}")
            convert_to_hls(
                self.input_path,
                self.output_dir,
                self.selected_resolutions,
                log_callback=self.log_message.emit, # Pass the signal as a callback
                stop_event=self.stop_event # Pass the stop event
            )
            if not self.stop_event.is_set(): # Only emit finished if not stopped by user
                self.conversion_finished.emit(f"Successfully converted: {os.path.basename(self.input_path)}")
            else:
                self.log_message.emit(f"Conversion for {os.path.basename(self.input_path)} was stopped.")

        except Exception as e:
            self.conversion_error.emit(f"Error converting {os.path.basename(self.input_path)}: {e}")
            self.log_message.emit(f"Error: {e}")
        finally:
            self.process_finished.emit()

    def stop(self):
        self.stop_event.set() # Set the event to signal stopping

class HLSConverterGUI(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("HLS Converter")
        self.setGeometry(100, 100, 900, 700) # Increased size for logs
        self.conversion_threads = []
        self.active_conversions = 0

        self.apply_dark_theme()
        self.init_ui()
        self.load_videos()

    def apply_dark_theme(self):
        """Applies a dark bluish theme to the application."""
        palette = QPalette()
        palette.setColor(QPalette.Window, QColor(45, 45, 55))  # Dark bluish background
        palette.setColor(QPalette.WindowText, Qt.white)
        palette.setColor(QPalette.Base, QColor(30, 30, 40))   # Darker input fields/text areas
        palette.setColor(QPalette.AlternateBase, QColor(45, 45, 55))
        palette.setColor(QPalette.ToolTipBase, Qt.white)
        palette.setColor(QPalette.ToolTipText, Qt.white)
        palette.setColor(QPalette.Text, Qt.white)
        palette.setColor(QPalette.Button, QColor(60, 60, 70)) # Slightly lighter buttons
        palette.setColor(QPalette.ButtonText, Qt.white)
        palette.setColor(QPalette.BrightText, Qt.red)
        palette.setColor(QPalette.Link, QColor(70, 170, 255)) # Brighter blue links
        palette.setColor(QPalette.Highlight, QColor(70, 170, 255)) # Highlight color
        palette.setColor(QPalette.HighlightedText, Qt.black)
        self.setPalette(palette)

        # Apply stylesheet for more granular control and modern look
        self.setStyleSheet("""
            QWidget {
                background-color: #2D2D37; /* Dark bluish background */
                color: #FFFFFF;
            }
            QPushButton {
                background-color: #3C3C46; /* Darker button */
                border: 1px solid #4A4A55;
                border-radius: 5px;
                padding: 8px 15px;
                font-size: 14px;
            }
            QPushButton:hover {
                background-color: #4A4A55;
            }
            QPushButton:pressed {
                background-color: #2D2D37;
            }
            QPushButton:disabled {
                background-color: #25252D;
                color: #888888;
                border: 1px solid #303038;
            }
            QListWidget {
                background-color: #1E1E28; /* Even darker for list/text areas */
                border: 1px solid #3A3A45;
                border-radius: 5px;
                padding: 5px;
            }
            QListWidget::item {
                padding: 3px;
            }
            QListWidget::item:selected {
                background-color: #4682B4; /* SteelBlue for selection */
            }
            QCheckBox {
                spacing: 5px;
            }
            QCheckBox::indicator {
                width: 16px;
                height: 16px;
            }
            QCheckBox::indicator:unchecked {
                border: 1px solid #555560;
                background-color: #25252D;
            }
            QCheckBox::indicator:checked {
                background-color: #4682B4; /* SteelBlue for checked */
                border: 1px solid #4682B4;
            }
            QLabel {
                font-weight: bold;
                margin-bottom: 5px;
            }
            QTextEdit {
                background-color: #1E1E28;
                border: 1px solid #3A3A45;
                border-radius: 5px;
                padding: 5px;
            }
        """
        )

    def init_ui(self):
        """Initializes the user interface components with a grid layout."""
        main_layout = QGridLayout()

        # --- Video Selection (Top Left) ---
        video_group_box = QVBoxLayout()
        video_group_box.addWidget(QLabel("<h3>Input Videos:</h3>"))
        self.video_list_widget = QListWidget()
        self.video_list_widget.setSelectionMode(QListWidget.NoSelection) # Use checkboxes for selection
        self.video_list_widget.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        video_group_box.addWidget(self.video_list_widget)
        main_layout.addLayout(video_group_box, 0, 0, 2, 1) # Row 0, Col 0, Span 2 rows, 1 col

        # --- Resolution Selection (Top Right) ---
        resolution_group_box = QVBoxLayout()
        resolution_group_box.addWidget(QLabel("<h3>Select Resolutions:</h3>"))
        self.resolution_checkboxes = []
        for res in RESOLUTIONS:
            checkbox = QCheckBox(res)
            checkbox.setChecked(True) # Default to all resolutions selected
            self.resolution_checkboxes.append(checkbox)
            resolution_group_box.addWidget(checkbox)
        resolution_group_box.addStretch() # Pushes content to the top
        main_layout.addLayout(resolution_group_box, 0, 1, 1, 1) # Row 0, Col 1, Span 1 row, 1 col

        # --- Control Buttons (Middle Right) ---
        control_buttons_layout = QVBoxLayout()
        self.convert_button = QPushButton("Convert Selected Videos")
        self.convert_button.clicked.connect(self.start_conversion)
        control_buttons_layout.addWidget(self.convert_button)

        self.stop_button = QPushButton("Stop All Conversions")
        self.stop_button.clicked.connect(self.stop_all_conversions)
        self.stop_button.setEnabled(False) # Disabled by default
        control_buttons_layout.addWidget(self.stop_button)
        control_buttons_layout.addStretch()
        main_layout.addLayout(control_buttons_layout, 1, 1, 1, 1) # Row 1, Col 1, Span 1 row, 1 col

        # --- Log Output (Bottom, spans all columns) ---
        log_group_box = QVBoxLayout()
        log_group_box.addWidget(QLabel("<h3>Conversion Log:</h3>"))
        self.log_text_edit = QTextEdit()
        self.log_text_edit.setReadOnly(True)
        self.log_text_edit.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        log_group_box.addWidget(self.log_text_edit)
        main_layout.addLayout(log_group_box, 2, 0, 1, 2) # Row 2, Col 0, Span 1 row, 2 cols

        self.setLayout(main_layout)

    def load_videos(self):
        """Loads video files from the INPUT_DIR."""
        self.video_list_widget.clear()
        if not os.path.exists(INPUT_DIR):
            self.log_text_edit.append(f"Error: Input directory '{INPUT_DIR}' does not exist.")
            QMessageBox.warning(self, "Error", f"Input directory '{INPUT_DIR}' does not exist.")
            return

        videos = [
            f for f in os.listdir(INPUT_DIR)
            if os.path.isfile(os.path.join(INPUT_DIR, f)) and os.path.splitext(f)[1].lower() in VIDEO_EXTENSIONS
        ]

        if not videos:
            self.log_text_edit.append("No video files found in 'inputs/'.")
            return

        for video in videos:
            item = QListWidgetItem(video)
            item.setFlags(item.flags() | Qt.ItemIsUserCheckable | Qt.ItemIsEnabled)
            item.setCheckState(Qt.Unchecked) # Initially unchecked
            self.video_list_widget.addItem(item)

    def start_conversion(self):
        """Starts the HLS conversion process for selected videos and resolutions."""
        if not check_ffmpeg_installed():
            self.log_text_edit.append("Error: 'ffmpeg' command not found. Please ensure FFmpeg is installed and in your system's PATH.")
            QMessageBox.critical(self, "Error", "FFmpeg is not installed or not found in PATH. Please install it.")
            return

        selected_videos = []
        for i in range(self.video_list_widget.count()):
            item = self.video_list_widget.item(i)
            if item.checkState() == Qt.Checked:
                selected_videos.append(item.text())

        if not selected_videos:
            QMessageBox.warning(self, "No Selection", "Please select at least one video to convert.")
            return

        selected_resolutions = []
        for checkbox in self.resolution_checkboxes:
            if checkbox.isChecked():
                selected_resolutions.append(checkbox.text())

        if not selected_resolutions:
            QMessageBox.warning(self, "No Resolution Selected", "Please select at least one resolution to convert to.")
            return

        self.log_text_edit.clear()
        self.log_text_edit.append(f"Starting conversions for {len(selected_videos)} video(s) to {len(selected_resolutions)} resolution(s)...")
        self.convert_button.setEnabled(False)
        self.stop_button.setEnabled(True)

        self.active_conversions = len(selected_videos)

        for video_name in selected_videos:
            input_path = os.path.join(INPUT_DIR, video_name)
            thread = ConversionThread(input_path, OUTPUT_DIR, selected_resolutions)
            thread.conversion_finished.connect(self.on_conversion_finished)
            thread.conversion_error.connect(self.on_conversion_error)
            thread.log_message.connect(self.append_log)
            thread.process_finished.connect(self.on_process_finished)
            self.conversion_threads.append(thread)
            thread.start()

    def stop_all_conversions(self):
        """Stops all active conversion threads."""
        self.log_text_edit.append("Stopping all active conversions...")
        for thread in self.conversion_threads:
            if thread.isRunning():
                thread.stop()
                # No need to wait() here, as the thread's run method will exit
                # once the stop_event is set and FFmpeg process is terminated.
        # Clear the list of threads, as they will eventually finish and clean up.
        self.conversion_threads.clear()
        self.active_conversions = 0
        self.convert_button.setEnabled(True)
        self.stop_button.setEnabled(False)
        self.log_text_edit.append("All conversions stopped.")

    def on_conversion_finished(self, message):
        """Handles successful conversion messages."""
        self.append_log(f"SUCCESS: {message}")

    def on_conversion_error(self, message):
        """Handles conversion error messages."""
        self.append_log(f"ERROR: {message}")
        QMessageBox.critical(self, "Conversion Error", message)

    def append_log(self, message):
        """Appends a message to the log text edit."""
        self.log_text_edit.append(message)
        # Scroll to the bottom automatically
        self.log_text_edit.verticalScrollBar().setValue(self.log_text_edit.verticalScrollBar().maximum())

    def on_process_finished(self):
        """Decrements active conversion count and re-enables buttons when all are done."""
        self.active_conversions -= 1
        if self.active_conversions <= 0:
            self.convert_button.setEnabled(True)
            self.stop_button.setEnabled(False)
            self.log_text_edit.append("All pending conversions have finished.")
            # It's important to clear the list of threads only when all are truly finished
            # or when explicitly stopped by the user. The current logic handles this.


def main():
    app = QApplication(sys.argv)
    gui = HLSConverterGUI()
    gui.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
