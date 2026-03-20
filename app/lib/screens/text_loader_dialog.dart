import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:lingotune/l10n/app_localizations.dart';
import '../constants/generation_constants.dart';
import '../models/song.dart';
import '../models/lyric_line.dart';
import '../services/database_service.dart';
import '../services/folder_config_service.dart';
import '../services/lyrics_service.dart';
import '../services/translation_service.dart';
import '../services/settings_provider.dart';
import '../models/translation.dart' show Translation;
import '../utils/lrc_formatter.dart';

enum TextType { original, translation, transcript }

class TextLoaderDialog extends StatefulWidget {
  final Song song;
  final LyricsService lyricsService;
  final TranslationService translationService;

  const TextLoaderDialog({
    super.key,
    required this.song,
    required this.lyricsService,
    required this.translationService,
  });

  @override
  State<TextLoaderDialog> createState() => _TextLoaderDialogState();
}

class _TextLoaderDialogState extends State<TextLoaderDialog> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _startMinuteController = TextEditingController(text: '30');

  TextType _selectedType = TextType.original;
  String? _selectedFilePath;

  String _selectedOriginalLanguage = 'ro';
  String _selectedTranslationLanguage = 'ru';
  String _selectedTranscriptLanguage = 'ru';

  bool _isLoading = false;

  List<LyricLine> get originalLines => widget.lyricsService.lyricLines;

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _selectedOriginalLanguage = settingsProvider.defaultSourceLanguage;
    _loadExistingText();
    debugPrint('TextLoaderDialog: Initialized with default source language: $_selectedOriginalLanguage');
  }

  @override
  void dispose() {
    _textController.dispose();
    _startMinuteController.dispose();
    super.dispose();
  }

  bool get _hasOriginalText => widget.lyricsService.lyricLines.isNotEmpty;

  void _loadExistingText() {
    String? existingText;
    
    switch (_selectedType) {
      case TextType.original:
        if (_hasOriginalText) {
          existingText = widget.lyricsService.lyricLines
              .map((line) => line.text)
              .join('\n');
        }
        break;
        
      case TextType.translation:
        if (widget.translationService.currentTranslation != null) {
          existingText = widget.translationService.currentTranslation!.lines
              .map((line) => line.text)
              .join('\n');
        }
        break;
        
      case TextType.transcript:
        if (widget.translationService.currentTranslation != null) {
          final transcriptLines = widget.translationService.currentTranslation!.lines
              .map((line) => line.transcript)
              .where((transcript) => transcript != null && transcript.isNotEmpty)
              .toList();
          existingText = transcriptLines.join('\n');
        }
        break;
    }
    
    if (existingText != null) {
      _textController.text = existingText;
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      setState(() {
        _selectedFilePath = result.files.single.path;
        _textController.text = content;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData!.text != null) {
      final newText = clipboardData!.text!;
      
      setState(() {
        final currentText = _textController.text;
        if (currentText.isEmpty) {
          _textController.text = newText;
        } else {
          // Добавляем новый текст к существующему
          _textController.text = '$currentText\n$newText';
        }
      });
    }
  }

  String _getText() {
    return _textController.text.trim();
  }

  List<String> _getLines() {
    final text = _getText();
    if (text.isEmpty) return [];
    
    final lines = text.split('\n');
    return lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  Future<void> _loadOriginalText() async {
    final lines = _getLines();
    if (lines.isEmpty) {
      _showError('Text is empty');
      return;
    }

    final startMinute = double.tryParse(_startMinuteController.text) ?? 30.0;
    final startTimestamp = startMinute * 60.0;
    final lineInterval = 5.0;  // Интервал 5 секунд между строками

    setState(() {
      _isLoading = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;
      final lyricsFolder = await FolderConfigService.getConfiguredFolder();
      if (lyricsFolder == null) {
        throw Exception('No lyrics folder configured');
      }

      final songName = widget.song.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final lrcPath = '${lyricsFolder.path}/$songName.lrc';

      final newLines = lines.asMap().entries.map((entry) {
        final lineIndex = entry.key;
        final lineText = entry.value;
        final line = LyricLine(
          startTime: startTimestamp + (lineIndex * lineInterval),
          text: lineText,
          translatedText: null,
        );
        return line;
      }).toList();

      final lrcContent = _generateLrcContent(newLines);
      final lrcFile = File(lrcPath);
      await lrcFile.writeAsString(lrcContent);

      await widget.lyricsService.loadLrcFile(lrcPath);
      
      debugPrint('=== Original text loaded successfully ===');
      debugPrint('LRC path: $lrcPath');
      debugPrint('Lyrics lines count: ${widget.lyricsService.lyricLines.length}');
      debugPrint('Original language: $_selectedOriginalLanguage');
      
      final db = DatabaseService();
      await db.updateSongLrcPath(widget.song.id, lrcPath);
      await db.updateSongOriginalLanguage(widget.song.id, _selectedOriginalLanguage);

      debugPrint('=== Updated song in DB ===');
      debugPrint('Song ID: ${widget.song.id}');
      debugPrint('LRC path saved: $lrcPath');
      debugPrint('Original language saved: $_selectedOriginalLanguage');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.originalTextLoaded),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTranslation() async {
    if (!_hasOriginalText) {
      _showError(AppLocalizations.of(context)!.noOriginalTextWarning);
      return;
    }

    final lines = _getLines();
    final originalLines = widget.lyricsService.lyricLines;

    if (lines.isEmpty) {
      _showError('Translation is empty');
      return;
    }

    if (lines.length != originalLines.length) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.linesMismatchError(lines.length, originalLines.length));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;
      final lyricsFolder = await FolderConfigService.getConfiguredFolder();
      if (lyricsFolder == null) {
        throw Exception('No lyrics folder configured');
      }

      final songName = widget.song.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final languageName = GenerationConstants.supportedLanguages[_selectedTranslationLanguage] ?? _selectedTranslationLanguage;
      final jsonPath = '${lyricsFolder.path}/$songName\_${_selectedTranslationLanguage}.json';

      final translationLines = List.generate(originalLines.length, (index) {
        return {
          'startTime': originalLines[index].startTime,
          'text': (index < lines.length) ? lines[index] : '',
          'translatedText': null,
          'transcript': null,
          'originalStartTime': null,
        };
      });

      final jsonContent = {
        'title': songName,
        'artist': widget.song.artist,
        'originalLanguage': widget.song.originalLanguage,
        'translations': [
          {
            'language': _selectedTranslationLanguage,
            'languageName': languageName,
            'type': _selectedTranslationLanguage == 'trans' ? 'transcript' : null,
            'lines': translationLines,
          }
        ]
      };

      final jsonFile = File(jsonPath);
      await jsonFile.writeAsString(jsonEncode(jsonContent));

      final db = DatabaseService();
      await db.addTranslation(
        songId: widget.song.id,
        language: _selectedTranslationLanguage,
        languageName: languageName,
        filePath: jsonPath,
        type: _selectedTranslationLanguage == 'trans' ? 'transcript' : null,
      );

      widget.translationService.clear();
      await widget.translationService.loadTranslations(jsonPath);
      
      debugPrint('=== Translation loaded successfully ===');
      debugPrint('JSON path: $jsonPath');
      debugPrint('Language: $_selectedTranslationLanguage');
      debugPrint('Language name: $languageName');
      debugPrint('Translations in service: ${widget.translationService.translations.length}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translationLoaded),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTranscript() async {
    final lines = _getLines();
    final availableTranslations = widget.translationService.translations;

    if (availableTranslations.isEmpty) {
      _showError(AppLocalizations.of(context)!.noTranslationWarning);
      return;
    }

    if (lines.isEmpty) {
      _showError('Transcript is empty');
      return;
    }

    final selectedTranslation = widget.translationService.getTranslationByLanguageCode(_selectedTranscriptLanguage);
    if (selectedTranslation == null) {
      _showError('Translation not found for selected language');
      return;
    }

    if (lines.length != selectedTranslation.lines.length) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.linesMismatchError(lines.length, selectedTranslation.lines.length));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.translationService.updateTranscriptForTranslation(
        _selectedTranscriptLanguage,
        lines,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.transcriptLoaded),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateLrcContent(List<LyricLine> lines) {
    return LrcFormatter.generateLrcContent(lines);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.loadTextTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
              if (!_isLoading) ...[
                SegmentedButton<TextType>(
                  segments: const [
                    ButtonSegment(value: TextType.original, label: Text('Original')),
                    ButtonSegment(value: TextType.translation, label: Text('Translation')),
                    ButtonSegment(value: TextType.transcript, label: Text('Transcript')),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<TextType> selected) {
                    setState(() {
                      _selectedType = selected.first;
                      _textController.clear();
                      _selectedFilePath = null;
                      _loadExistingText();
                    });
                  },
                ),
                const SizedBox(height: 16),

                if (_selectedType == TextType.translation && !_hasOriginalText) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.noOriginalTextWarning,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_selectedType == TextType.transcript && widget.translationService.translations.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.noTranslationWarning,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_selectedType == TextType.original) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedOriginalLanguage,
                    decoration: InputDecoration(
                      labelText: l10n.selectLanguageOriginal,
                      border: const OutlineInputBorder(),
                    ),
                    items: GenerationConstants.sourceLanguages.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(GenerationConstants.sourceLanguageNames[lang] ?? lang),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOriginalLanguage = value ?? 'ro';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _startMinuteController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.startTimestampMinutes,
                      border: const OutlineInputBorder(),
                      suffixText: 'min',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_selectedType == TextType.translation) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${l10n.originalLanguage}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.song.originalLanguage == 'unknown'
                              ? 'Unknown'
                              : (GenerationConstants.sourceLanguageNames[widget.song.originalLanguage] ?? widget.song.originalLanguage),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTranslationLanguage,
                    decoration: InputDecoration(
                      labelText: l10n.selectLanguageTranslation,
                      border: const OutlineInputBorder(),
                    ),
                    items: GenerationConstants.defaultLanguages.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(GenerationConstants.supportedLanguages[lang] ?? lang),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTranslationLanguage = value ?? 'ru';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                if (_selectedType == TextType.transcript) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedTranscriptLanguage,
                    decoration: InputDecoration(
                      labelText: l10n.selectTranslationLanguage,
                      border: const OutlineInputBorder(),
                    ),
                    items: widget.translationService.translations.map((translation) {
                      return DropdownMenuItem(
                        value: translation.language,
                        child: Text('${translation.languageName} (${translation.language})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTranscriptLanguage = value ?? widget.translationService.translations.first.language;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: Text(l10n.loadFromFile),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.content_paste),
                        label: Text(l10n.pasteFromClipboard),
                      ),
                    ),
                  ],
                ),
                if (_textController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _textController.clear();
                        });
                      },
                      tooltip: l10n.cancel,
                    ),
                  ),
                ],
                TextField(
                  controller: _textController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: _selectedType == TextType.original
                        ? l10n.originalText
                        : (_selectedType == TextType.translation ? l10n.translation : l10n.transcript),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedType == TextType.translation && _hasOriginalText
                      ? 'Original: ${originalLines.length} lines'
                      : (_selectedType == TextType.transcript && widget.translationService.translations.isNotEmpty
                          ? '${widget.translationService.translations.first.languageName}: ${widget.translationService.translations.first.lines.length} lines'
                          : ''),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (!_isLoading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        if (!_isLoading)
          ElevatedButton(
            onPressed: _selectedType == TextType.original
                ? _loadOriginalText
                : (_selectedType == TextType.translation ? _loadTranslation : _loadTranscript),
            child: Text(_selectedType == TextType.original
                ? l10n.originalText
                : (_selectedType == TextType.translation ? l10n.translation : l10n.transcript)),
          ),
      ],
    );
  }
}
