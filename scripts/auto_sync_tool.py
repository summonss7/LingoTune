#!/usr/bin/env python3
"""
LingoTune Auto-Sync Tool
Automatic speech recognition and LRC timestamp generator using vosk
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import os
import json
import time
import threading

try:
    import vosk
    from vosk import Model, KaldiRecognizer
except ImportError:
    vosk = None

try:
    import wave
except ImportError:
    wave = None

class AutoSyncApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("LingoTune - Auto Sync Tool")
        self.root.geometry("1100x800")
        
        # Audio state
        self.audio_file = None
        self.duration = 0
        self.is_playing = False
        self.current_position = 0
        self.sample_rate = 16000
        
        # Recognition state
        self.recognizer = None
        self.model = None
        self.is_recognizing = False
        
        # LRC lines
        self.lines = []
        self.current_line_index = 0
        
        self._setup_ui()
        self._setup_models()
        
    def _setup_ui(self):
        # Main container
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky="nsew")
        
        # Audio file section
        audio_frame = ttk.LabelFrame(main_frame, text="Audio File", padding="10")
        audio_frame.grid(row=0, column=0, columnspan=2, sticky="ew", pady=5)
        
        ttk.Label(audio_frame, text="Audio File:").grid(row=0, column=0, sticky=tk.W)
        self.audio_entry = ttk.Entry(audio_frame, width=70)
        self.audio_entry.grid(row=0, column=1, sticky="ew", padx=5)
        ttk.Button(audio_frame, text="Browse", command=self._browse_audio).grid(row=0, column=2, padx=5)
        
        # Controls section
        control_frame = ttk.LabelFrame(main_frame, text="Audio Controls", padding="10")
        control_frame.grid(row=1, column=0, columnspan=2, sticky="ew", pady=5)
        
        self.play_button = ttk.Button(control_frame, text="Play", command=self._toggle_play)
        self.play_button.grid(row=0, column=0, padx=5)
        
        ttk.Button(control_frame, text="Stop", command=self._stop).grid(row=0, column=1, padx=5)
        
        self.rewind_button = ttk.Button(control_frame, text="-10s", command=self._rewind_10)
        self.rewind_button.grid(row=0, column=2, padx=5)
        
        ttk.Button(control_frame, text="+10s", command=self._forward_10).grid(row=0, column=3, padx=5)
        
        # Time display
        self.time_label = ttk.Label(control_frame, text="00:00", font=('Arial', 14, 'bold'))
        self.time_label.grid(row=1, column=4, padx=20)
        
        # Recognition section
        recog_frame = ttk.LabelFrame(main_frame, text="Speech Recognition", padding="10")
        recog_frame.grid(row=2, column=0, columnspan=2, sticky="ew", pady=5)
        
        # Model selection
        ttk.Label(recog_frame, text="Language:").grid(row=0, column=0, sticky=tk.W)
        self.language_var = tk.StringVar(value="ru")
        language_combo = ttk.Combobox(recog_frame, textvariable=self.language_var,
                                     values=["ru", "en", "de", "fr", "es", "it", "pt", "ro"],
                                     state="readonly", width=10)
        language_combo.grid(row=0, column=1, sticky=tk.W, padx=5)
        
        # Recognize button
        self.recognize_button = ttk.Button(recog_frame, text="Recognize Line (10s)", 
                                       command=self._recognize_current_segment)
        self.recognize_button.grid(row=0, column=2, padx=5)
        
        # Lyrics editor section
        lyrics_frame = ttk.LabelFrame(main_frame, text="Lyrics Editor", padding="10")
        lyrics_frame.grid(row=3, column=0, columnspan=2, sticky="nsew", pady=5)
        
        ttk.Label(lyrics_frame, text="Original:").grid(row=0, column=0, sticky=tk.W)
        self.original_entry = ttk.Entry(lyrics_frame, width=60)
        self.original_entry.grid(row=0, column=1, sticky="ew", padx=5)
        self.original_entry.bind('<Return>', lambda e: self._mark_timestamp())
        
        ttk.Label(lyrics_frame, text="Translation:").grid(row=1, column=0, sticky=tk.W)
        self.translation_entry = ttk.Entry(lyrics_frame, width=60)
        self.translation_entry.grid(row=1, column=1, sticky="ew", padx=5)
        
        ttk.Button(lyrics_frame, text="Mark Timestamp", command=self._mark_timestamp).grid(row=2, column=0, padx=5, pady=5)
        ttk.Button(lyrics_frame, text="Add Line", command=self._add_line).grid(row=2, column=1, padx=5, pady=5)
        ttk.Button(lyrics_frame, text="Delete Line", command=self._delete_line).grid(row=3, column=1, padx=5, pady=5)
        ttk.Button(lyrics_frame, text="Clear All", command=self._clear_lines).grid(row=3, column=2, padx=5, pady=5)
        
        # Lines list
        ttk.Label(lyrics_frame, text="Timestamped Lines:", font=('Arial', 10, 'bold')).grid(row=4, column=0, columnspan=3, sticky=tk.W, pady=5)
        
        columns = ("time", "original", "translation")
        self.lines_tree = ttk.Treeview(lyrics_frame, columns=columns, show='headings', height=15)
        self.lines_tree.heading("time", text="Time")
        self.lines_tree.heading("original", text="Original Text")
        self.lines_tree.heading("translation", text="Translation")
        
        self.lines_tree.column("time", width=80, anchor=tk.CENTER)
        self.lines_tree.column("original", width=300)
        self.lines_tree.column("translation", width=300)
        self.lines_tree.grid(row=5, column=0, columnspan=3, sticky="nsew")
        
        # Export section
        export_frame = ttk.LabelFrame(main_frame, text="Export", padding="10")
        export_frame.grid(row=4, column=0, columnspan=2, sticky="ew", pady=5)
        
        ttk.Button(export_frame, text="Export LRC", command=self._export_lrc).grid(row=0, column=0, padx=5)
        ttk.Button(export_frame, text="Export JSON", command=self._export_json).grid(row=0, column=1, padx=5)
        
        # Menu bar
        menubar = tk.Menu(self.root)
        file_menu = tk.Menu(menubar, tearoff=0)
        file_menu.add_command(label="Import JSON", command=self._import_json)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.root.quit)
        menubar.add_cascade(label="File", menu=file_menu)
        
        help_menu = tk.Menu(menubar, tearoff=0)
        help_menu.add_command(label="About", command=self._show_about)
        help_menu.add_command(label="Instructions", command=self._show_instructions)
        menubar.add_cascade(label="Help", menu=help_menu)
        
        self.root.config(menu=menubar)
        
        # Start time update
        self._start_time_update()
        
    def _setup_models(self):
        if vosk is None:
            messagebox.showerror("Error", 
                           "vosk library not found!\n\n"
                           "Please install vosk:\n"
                           "pip install vosk")
            return
        
        # Check for models
        models_dir = os.path.join(os.path.dirname(__file__), "models")
        if not os.path.exists(models_dir):
            os.makedirs(models_dir)
            messagebox.showinfo("Models", 
                             f"Models directory created: {models_dir}\n\n"
                             "Please download vosk models from:\n"
                             "https://alphacephei.com/vosk/models")
            return
        
        # Load available models
        self.models = {}
        for filename in os.listdir(models_dir):
            if filename.endswith('.tar.gz') or filename.endswith('.zip'):
                self.models[filename.replace('.tar.gz', '').replace('.zip', '')] = os.path.join(models_dir, filename)
    
    def _browse_audio(self):
        file_path = filedialog.askopenfilename(
            title="Select Audio File",
            filetypes=[
                ("Audio Files", "*.mp3 *.wav *.ogg *.m4a *.flac"),
                ("All Files", "*.*")
            ]
        )
        if file_path:
            self.audio_entry.delete(0, tk.END)
            self.audio_entry.insert(0, file_path)
            self._load_audio(file_path)
    
    def _load_audio(self, file_path):
        if not os.path.exists(file_path):
            messagebox.showerror("Error", "File not found")
            return
        
        self.audio_file = file_path
        
        # Extract title
        filename = os.path.basename(file_path)
        title = os.path.splitext(filename)[0]
        
        # Try to load from wave file
        if wave:
            try:
                with wave.open(file_path, 'rb') as wf:
                    self.sample_rate = wf.getframerate()
                    n_frames = wf.getnframes()
                    self.duration = n_frames / float(self.sample_rate)
                    self.time_label.config(text=self._format_time(0))
                    messagebox.showinfo("Success", f"Loaded: {filename}\nDuration: {self._format_time(self.duration)}")
            except Exception as e:
                messagebox.showwarning("Warning", f"Could not read WAV info: {e}")
                self.duration = 60  # Default 60 seconds
        
    def _toggle_play(self):
        if not self.audio_file:
            messagebox.showwarning("Warning", "Please select an audio file first")
            return
        
        if self.is_playing:
            self.is_playing = False
            self.play_button.config(text="Play")
        else:
            self.is_playing = True
            self.play_button.config(text="Pause")
            # Placeholder for actual audio playback
            # You can add pygame or another audio player here
            messagebox.showinfo("Audio Player", 
                             "Audio playback not implemented yet.\n\n"
                             "This is a recognition-focused tool.\n"
                             "Use another player for playback.")
            self.is_playing = False
            self.play_button.config(text="Play")
    
    def _stop(self):
        self.is_playing = False
        self.play_button.config(text="Play")
        self.time_label.config(text=self._format_time(0))
    
    def _rewind_10(self):
        self.current_position = max(0, self.current_position - 10)
        self._update_time_label()
    
    def _forward_10(self):
        self.current_position = min(self.duration, self.current_position + 10)
        self._update_time_label()
    
    def _update_time_label(self):
        self.time_label.config(text=self._format_time(self.current_position))
    
    def _format_time(self, seconds):
        minutes = int(seconds // 60)
        secs = int(seconds % 60)
        centis = int((seconds % 1) * 100)
        return f"{minutes:02d}:{secs:02d}.{centis:02d}"
    
    def _recognize_current_segment(self):
        if not self.audio_file:
            messagebox.showwarning("Warning", "Please select an audio file first")
            return
        
        if not self.models:
            messagebox.showwarning("Warning", 
                              "No models found!\n\n"
                              "Please download vosk models to the 'models' folder.")
            return
        
        # Get current position
        start_pos = self.current_position
        duration = 10  # Recognize 10 seconds
        
        if start_pos + duration > self.duration:
            messagebox.showwarning("Warning", "Cannot recognize beyond audio duration")
            return
        
        messagebox.showinfo("Speech Recognition", 
                         f"Recognizing from {self._format_time(start_pos)} to {self._format_time(start_pos + duration)}...\n\n"
                         "This feature requires vosk models and audio file in WAV format.\n\n"
                         "Please ensure:\n"
                         "1. vosk models are in 'models' folder\n"
                         "2. Audio file is WAV format\n\n"
                         "Note: Convert MP3 to WAV first if needed.")
        
        # TODO: Implement actual recognition
        # This would use the vosk recognizer to get speech text
        # and then suggest timestamps based on detected phrases
    
    def _mark_timestamp(self):
        original_text = self.original_entry.get().strip()
        translation_text = self.translation_entry.get().strip()
        
        if not original_text:
            messagebox.showwarning("Warning", "Please enter original text")
            return
        
        time_str = self._format_time(self.current_position)
        self.lines.append({
            "time": self.current_position,
            "time_str": time_str,
            "original": original_text,
            "translation": translation_text
        })
        
        self._refresh_tree()
        self.original_entry.delete(0, tk.END)
        self.translation_entry.delete(0, tk.END)
        messagebox.showinfo("Success", f"Line marked at {time_str}")
    
    def _add_line(self):
        original_text = self.original_entry.get().strip()
        translation_text = self.translation_entry.get().strip()
        
        if not original_text:
            messagebox.showwarning("Warning", "Please enter original text")
            return
        
        time_str = "--:--.--"
        self.lines.append({
            "time": None,
            "time_str": time_str,
            "original": original_text,
            "translation": translation_text
        })
        
        self._refresh_tree()
        self.original_entry.delete(0, tk.END)
        self.translation_entry.delete(0, tk.END)
    
    def _update_line(self):
        selection = self.lines_tree.selection()
        if not selection:
            return
        
        index = int(selection[0].replace('line_', '')) - 1
        original_text = self.original_entry.get().strip()
        translation_text = self.translation_entry.get().strip()
        
        self.lines[index]["original"] = original_text
        self.lines[index]["translation"] = translation_text
        self._refresh_tree()
    
    def _delete_line(self):
        selection = self.lines_tree.selection()
        if not selection:
            return
        
        index = int(selection[0].replace('line_', '')) - 1
        del self.lines[index]
        self._refresh_tree()
    
    def _clear_lines(self):
        if messagebox.askyesno("Confirm", "Are you sure you want to clear all lines?"):
            self.lines = []
            self._refresh_tree()
    
    def _refresh_tree(self):
        for item in self.lines_tree.get_children():
            self.lines_tree.delete(item)
        
        for i, line in enumerate(self.lines):
            self.lines_tree.insert('', 'end', iid=f'line_{i+1}', values=(
                line["time_str"],
                line["original"],
                line["translation"]
            ))
    
    def _export_lrc(self):
        if not self.lines:
            messagebox.showwarning("Warning", "No lyrics to export")
            return
        
        file_path = filedialog.asksaveasfilename(
            title="Save LRC File",
            defaultextension=".lrc",
            filetypes=[("LRC Files", "*.lrc"), ("All Files", "*.*")]
        )
        
        if file_path:
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    for line in self.lines:
                        if line["time"] is not None:
                            f.write(f"[{line['time_str']}] {line['original']}\n")
                        else:
                            f.write(f"{line['original']}\n")
                
                messagebox.showinfo("Success", "LRC file exported successfully")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to export LRC: {e}")
    
    def _export_json(self):
        if not self.lines:
            messagebox.showwarning("Warning", "No lyrics to export")
            return
        
        translations = {}
        for line in self.lines:
            if line["translation"] and line["time"] is not None:
                time_key = line["time"]
                translations[time_key] = line["translation"]
        
        data = {
            "title": os.path.splitext(os.path.basename(self.audio_file))[0] if self.audio_file else "",
            "artist": "Unknown Artist",
            "originalLanguage": "ru",
            "translations": [
                {
                    "language": "ru",
                    "languageName": "Russian",
                    "lines": [
                        {
                            "startTime": line["time"],
                            "text": line["translation"]
                        }
                        for line in self.lines
                        if line["translation"] and line["time"] is not None
                    ]
                }
            ]
        }
        
        file_path = filedialog.asksaveasfilename(
            title="Save JSON File",
            defaultextension=".json",
            filetypes=[("JSON Files", "*.json"), ("All Files", "*.*")]
        )
        
        if file_path:
            try:
                with open(file_path, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                messagebox.showinfo("Success", "JSON file exported successfully")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to export JSON: {e}")
    
    def _import_json(self):
        file_path = filedialog.askopenfilename(
            title="Open JSON File",
            filetypes=[("JSON Files", "*.json"), ("All Files", "*.*")]
        )
        
        if file_path:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                self.lines = []
                translations = data.get("translations", [])
                
                if translations:
                    translation_lines = translations[0].get("lines", [])
                    
                    for line in translation_lines:
                        self.lines.append({
                            "time": line["startTime"],
                            "time_str": self._format_time(line["startTime"]),
                            "original": "",
                            "translation": line["text"]
                        })
                
                self._refresh_tree()
                messagebox.showinfo("Success", "JSON file loaded successfully")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load JSON: {e}")
    
    def _show_about(self):
        about_text = """LingoTune Auto-Sync Tool v1.0
        
An automatic LRC timestamp generator using vosk speech recognition.

Features:
- Automatic speech recognition
- Manual timestamp marking
- Export to LRC and JSON formats

For more information:
https://github.com/LingoTune"""
        messagebox.showinfo("About", about_text)
    
    def _show_instructions(self):
        instructions = """LingoTune Auto-Sync Tool Instructions:

1. Select Audio File
   - Choose an MP3/WAV/OGG file from your computer
   - The tool will show the audio duration

2. Download Vosk Models
   - Download vosk models from: https://alphacephei.com/vosk/models
   - Place models in the 'models' folder next to this script
   - Recommended models: vosk-model-small-ru-0.22 (Russian)
                     vosk-model-small-en-us-0.22 (English)
                     vosk-model-small-de-0.22 (German)
                     vosk-model-small-fr-0.22 (French)

3. Use Speech Recognition
   - Play audio (or use another player)
   - Navigate to the desired position
   - Click "Recognize Line" to recognize speech (10 second segment)
   - Recognized text will appear in the Original field

4. Mark Timestamps
   - Type or paste the recognized text
   - Click "Mark Timestamp" to save with current time
   - Repeat for each line of the song

5. Add Lines
   - You can also add lines without recognition (use "Add Line")
   - Use "--:--.--" for lines without specific timing

6. Export
   - Use "Export LRC" to save original lyrics with timestamps
   - Use "Export JSON" to save translations

Tips:
- Convert MP3 to WAV for better recognition (use ffmpeg: ffmpeg -i input.mp3 output.wav)
- Use short recognition segments (10-20 seconds) for better accuracy
- Pause audio exactly when a line starts/ends for precision

Requirements:
- Python 3.7+
- vosk library (pip install vosk)
- Optional: wave library (for WAV file info)"""
        messagebox.showinfo("Instructions", instructions)
    
    def _start_time_update(self):
        def update():
            if self.is_playing:
                # Simulate playback
                self.current_position += 0.1
                if self.current_position >= self.duration:
                    self.current_position = self.duration
                self._update_time_label()
            self.root.after(100, update)
        
        update()

if __name__ == "__main__":
    app = AutoSyncApp()
    app.root.mainloop()
