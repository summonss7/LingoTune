import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import '../models/song.dart';
import '../models/lyric_line.dart';
import '../models/translation.dart';
import '../services/translation_api_service.dart';
import '../services/translation_service.dart';
import '../services/lyrics_service.dart';
import '../services/database_service.dart';
import '../constants/generation_constants.dart';
import 'package:lingotune/l10n/app_localizations.dart';

class TranslationEditorScreen extends StatefulWidget {
  final Song song;
  final List<LyricLine> lyricLines;
  final TranslationService translationService;
  final LyricsService lyricsService;

  const TranslationEditorScreen({
    super.key,
    required this.song,
    required this.lyricLines,
    required this.translationService,
    required this.lyricsService,
  });

  @override
  State<TranslationEditorScreen> createState() => _TranslationEditorScreenState();
}

class _TranslationEditorScreenState extends State<TranslationEditorScreen> {
  final Map<String, String> _translations = {};
  final Map<int, String> _originalTexts = {};
  String _selectedLanguage = 'ru';
  String _languageName = 'Russian';
  int _selectedLanguageIndex = 0;
  final TranslationApiService _translationApiService = TranslationApiService();
  bool _isTranslating = false;
  final Map<String, TextEditingController> _translationControllers = {};
  final Map<int, TextEditingController> _originalTextControllers = {};
  bool _editOriginalText = false;

  final List<Map<String, String>> _availableLanguages = [
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'en', 'name': 'English'},
    {'code': 'ro', 'name': 'Romanian'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'zh', 'name': 'Chinese'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'sk', 'name': 'Slovak'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeTranslations();
  }

  void _initializeTranslations() {
    for (var i = 0; i < widget.lyricLines.length; i++) {
      final line = widget.lyricLines[i];
      _translations[line.text] = line.translatedText ?? '';
      _originalTexts[i] = line.text;
      _translationControllers[line.text] = TextEditingController(text: line.translatedText ?? '');
      _originalTextControllers[i] = TextEditingController(text: line.text);
    }

    if (widget.translationService.currentTranslation != null) {
      final currentTrans = widget.translationService.currentTranslation!;
      setState(() {
        _selectedLanguage = currentTrans.language;
        _languageName = currentTrans.languageName;
        _selectedLanguageIndex = widget.translationService.currentLanguageIndex;
      });
      _loadCurrentTranslation();
    }
  }

  void _loadCurrentTranslation() {
    final translation = widget.translationService.currentTranslation;
    if (translation == null) return;

    for (final line in widget.lyricLines) {
      for (final translationLine in translation.lines) {
        if ((translationLine.startTime - line.startTime).abs() < 0.1) {
          _translations[line.text] = translationLine.text;
          _translationControllers[line.text] = TextEditingController(text: translationLine.text);
          break;
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _translationControllers.values) {
      controller.dispose();
    }
    for (final controller in _originalTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveTranslations() async {
    try {
      if (_editOriginalText) {
        for (var i = 0; i < widget.lyricLines.length; i++) {
          final newText = _originalTextControllers[i]?.text ?? widget.lyricLines[i].text;
          final currentText = widget.lyricLines[i].text;
          if (newText != currentText) {
            final oldText = widget.lyricLines[i].text;
            final translation = _translations[oldText];
            _translations.remove(oldText);
            _translations[newText] = translation ?? '';
            _originalTexts[i] = newText;
            widget.lyricsService.updateLineText(i, newText);
          }
        }
        await _saveLrcFile();
      }

      if (widget.translationService.currentTranslation == null) {
        await _createAndSaveNewTranslation();
      } else {
        for (var line in widget.lyricLines) {
          final translatedText = _translations[line.text] ?? '';
          widget.translationService.updateTranslationText(line.startTime, translatedText);
        }
        await widget.translationService.saveCurrentTranslation();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translationSaved),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error saving translations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.translationSaveFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _getTranslationsFilePath() async {
    if (widget.song.translationsPath != null &&
        widget.song.translationsPath!.isNotEmpty) {
      return widget.song.translationsPath!;
    }

    String basePath;
    if (widget.song.lrcPath != null && widget.song.lrcPath!.isNotEmpty) {
      basePath = widget.song.lrcPath!;
    } else {
      basePath = widget.song.audioPath;
    }

    final dir = p.dirname(basePath);
    final baseName = p.basenameWithoutExtension(basePath);
    return p.join(dir, '${baseName}_${_selectedLanguage}.json');
  }

  Future<void> _createAndSaveNewTranslation() async {
    final lines = <LyricLine>[];
    for (var i = 0; i < widget.lyricLines.length; i++) {
      final line = widget.lyricLines[i];
      final translatedText = _translations[line.text] ?? '';
      lines.add(LyricLine(
        startTime: line.startTime,
        text: translatedText,
        originalStartTime: line.originalStartTime ?? line.startTime,
      ));
    }

    final filePath = await _getTranslationsFilePath();

    final data = <String, dynamic>{
      'title': widget.song.title,
      'artist': widget.song.artist,
      'originalLanguage': widget.song.originalLanguage,
      'translations': [],
    };

    final file = File(filePath);
    if (await file.exists()) {
      try {
        final existing = json.decode(await file.readAsString()) as Map<String, dynamic>;
        if (existing.containsKey('title')) data['title'] = existing['title'];
        if (existing.containsKey('artist')) data['artist'] = existing['artist'];
        if (existing.containsKey('originalLanguage')) {
          data['originalLanguage'] = existing['originalLanguage'];
        }
        data['translations'] = (existing['translations'] as List?) ?? [];
      } catch (_) {}
    }

    final newTranslationData = Translation(
      language: _selectedLanguage,
      languageName: _languageName,
      lines: lines,
      filePath: filePath,
    );

    final translations = data['translations'] as List;
    final existingIndex = translations.indexWhere(
      (t) => (t as Map<String, dynamic>)['language'] == _selectedLanguage,
    );
    final jsonData = newTranslationData.toJson();
    if (existingIndex != -1) {
      translations[existingIndex] = jsonData;
    } else {
      translations.add(jsonData);
    }

    await file.writeAsString(
      json.encode(data),
      encoding: utf8,
    );

    widget.translationService.addTranslation(newTranslationData);

    try {
      final db = DatabaseService();
      await db.addTranslationFile(
        widget.song.id,
        _selectedLanguage,
        _languageName,
        filePath,
      );
    } catch (e) {
      debugPrint('Warning: could not register translation in DB: $e');
    }

    debugPrint('New translation created and saved to: $filePath');
  }

  Future<void> _saveLrcFile() async {
    if (widget.song.lrcPath == null) return;

    try {
      final lrcPath = widget.song.lrcPath!;
      final file = File(lrcPath);

      final buffer = StringBuffer();
      for (final line in widget.lyricLines) {
        final minutes = (line.startTime ~/ 60).toInt();
        final seconds = (line.startTime % 60).toInt();
        final milliseconds = ((line.startTime % 1) * 1000).round().clamp(0, 999);
        buffer.writeln('[${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}]${line.text}');
      }

      await file.writeAsString(buffer.toString());
      debugPrint('LRC file saved to: $lrcPath');
    } catch (e) {
      debugPrint('Error saving LRC file: $e');
      rethrow;
    }
  }

  Future<void> _loadLrcFile() async {
    try {
      debugPrint('=== DEBUG: Loading LRC file manually ===');
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['lrc'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final String filePath = (file.path ?? file.identifier) as String;
        
        debugPrint('LRC file path: $filePath');
        
        final fileToRead = File(filePath);
        final content = await fileToRead.readAsString();
        
        debugPrint('LRC content length: ${content.length}');
        
        final lrcLines = _parseLrc(content);
        debugPrint('Parsed ${lrcLines.length} lines from LRC');
        
        setState(() {
          for (var i = 0; i < widget.lyricLines.length && i < lrcLines.length; i++) {
            _translations[widget.lyricLines[i].text] = lrcLines[i];
            _translationControllers[widget.lyricLines[i].text]?.text = lrcLines[i];
            debugPrint('Added translation for line $i');
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('LRC file loaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('No file selected');
      }
    } catch (e) {
      debugPrint('Error loading LRC file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load LRC file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<String> _parseLrc(String content) {
    final lines = <String>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final line in content.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final text = match.group(4)!.trim();
        if (text.isNotEmpty) {
          lines.add(text);
        }
      }
    }

    return lines;
  }

  Future<void> _loadTranslations() async {
    try {
      debugPrint('=== DEBUG: Loading translations from JSON file ===');
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        final String filePath = (file.path ?? file.identifier) as String;
        
        debugPrint('File path: $filePath');
        
        final fileToRead = File(filePath);
        final content = await fileToRead.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;

        debugPrint('JSON data keys: ${data.keys}');

        if (data.containsKey('translations') && data['translations'] is List) {
          final translationsList = data['translations'] as List;
          debugPrint('Translations list length: ${translationsList.length}');
          
          if (translationsList.isNotEmpty) {
            final firstTranslation = translationsList[0] as Map<String, dynamic>;
            
            setState(() {
              _selectedLanguage = firstTranslation['language'] as String? ?? 'ru';
              _languageName = firstTranslation['languageName'] as String? ?? 'Unknown';
            });

            if (firstTranslation.containsKey('lines') && firstTranslation['lines'] is List) {
              final lines = firstTranslation['lines'] as List;
              debugPrint('Lines count: ${lines.length}');
              
              for (var lineData in lines) {
                if (lineData is Map<String, dynamic>) {
                  final startTimeNum = lineData['startTime'] as num?;
                  final startTime = startTimeNum?.toDouble();
                  final translatedText = lineData['text'] as String?;

                  if (startTime != null) {
                    try {
                      final originalLine = widget.lyricLines.firstWhere(
                        (l) => (l.startTime - startTime).abs() < 0.1,
                        orElse: () => widget.lyricLines.first,
                      );
                      _translations[originalLine.text] = translatedText ?? '';
                      _translationControllers[originalLine.text]?.text = translatedText ?? '';
                      debugPrint('Translation added for line at $startTime');
                    } catch (e) {
                      debugPrint('Error finding matching line: $e');
                    }
                  }
                }
              }
            }

            setState(() {});

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Translations loaded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            debugPrint('Translations list is empty');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No translations found in file'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } else {
          debugPrint('Invalid JSON structure: missing translations key or not a list');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid JSON format'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading translations: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load translations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _autoTranslate() async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final originalTexts = widget.lyricLines.map((line) => line.text).toList();
      final fromLang = widget.song.originalLanguage == 'unknown' ? 'en' : widget.song.originalLanguage;
      
      final translations = await _translationApiService.translateBatch(
        originalTexts,
        fromLang,
        _selectedLanguage,
      );

      for (var i = 0; i < widget.lyricLines.length; i++) {
        _translations[widget.lyricLines[i].text] = translations[i];
        _translationControllers[widget.lyricLines[i].text]?.text = translations[i];
      }

      setState(() {
        _isTranslating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto-translated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to auto-translate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableLanguages.length,
            itemBuilder: (context, index) {
              final lang = _availableLanguages[index];
              return ListTile(
                title: Text(lang['name']!),
                onTap: () {
                  setState(() {
                    _selectedLanguage = lang['code']!;
                    _languageName = lang['name']!;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _moveTranslationDown(int index) {
    if (index < 0 || index >= widget.lyricLines.length) return;

    setState(() {
      for (int j = widget.lyricLines.length - 1; j > index; j--) {
        final currentLine = widget.lyricLines[j];
        final prevLine = widget.lyricLines[j - 1];

        final prevTrans = _translations[prevLine.text] ?? '';
        _translations[currentLine.text] = prevTrans;
        _translationControllers[currentLine.text]?.text = prevTrans;
      }

      final currentLine = widget.lyricLines[index];
      _translations[currentLine.text] = '';
      _translationControllers[currentLine.text]?.text = '';
    });
  }

  Future<void> _showResetTimestampsDialog() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetTimestamps),
        content: Text(l10n.resetTimestampsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.resetTimestamps),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final defaultOffset = prefs.getDouble('defaultTimestampOffset') ?? 1800.0;
    final timingStep = GenerationConstants.timingStep;

    setState(() {
      for (var i = 0; i < widget.lyricLines.length; i++) {
        final newStartTime = defaultOffset + (i * timingStep);
        widget.lyricLines[i] = widget.lyricLines[i].copyWith(
          startTime: newStartTime,
          originalStartTime: newStartTime,
        );
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.resetTimestampsSuccess),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.saveAfterReset),
        content: Text(l10n.saveAfterResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveLrcFile();
    }
  }

  void _selectTranslation(int index) {
    if (index < 0 || index >= widget.translationService.translations.length) return;

    setState(() {
      _selectedLanguageIndex = index;
      final trans = widget.translationService.translations[index];
      _selectedLanguage = trans.language;
      _languageName = trans.languageName;
    });

    widget.translationService.selectLanguage(index);
    _loadCurrentTranslation();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Editor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isTranslating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: _autoTranslate,
              tooltip: 'Auto-translate',
            ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _showResetTimestampsDialog,
            tooltip: 'Reset timestamps',
          ),
          IconButton(
            icon: const Icon(Icons.lyrics),
            onPressed: _loadLrcFile,
            tooltip: 'Load LRC file',
          ),
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: _loadTranslations,
            tooltip: 'Load translations from JSON file',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTranslations,
            tooltip: 'Save translations',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.song.title} - ${widget.song.artist}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showLanguageDialog,
                        icon: const Icon(Icons.translate),
                        label: Text(_languageName),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _editOriginalText,
                      onChanged: (value) {
                        setState(() {
                          _editOriginalText = value ?? false;
                        });
                      },
                    ),
                    Text(l10n.originalTextEditable),
                  ],
                ),
                if (widget.translationService.translations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.selectLanguageToEdit,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedLanguageIndex,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: widget.translationService.translations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final trans = entry.value;

                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text('${trans.languageName} (${trans.language})'),
                        );
                      }).toList(),
                      onChanged: (index) {
                        if (index != null) {
                          _selectTranslation(index);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: widget.lyricLines.length,
              itemBuilder: (context, index) {
                final line = widget.lyricLines[index];
                final translation = _translations[line.text] ?? '';
                final controller = _translationControllers[line.text];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(line.startTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_editOriginalText)
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Original',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.orange.shade50,
                            ),
                            controller: _originalTextControllers[index],
                            onChanged: (value) {
                              _originalTexts[index] = value;
                            },
                          )
                        else
                          Text(
                            line.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Translation',
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                ),
                                controller: controller,
                                onChanged: (value) {
                                  _translations[line.text] = value;
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward, size: 20),
                              onPressed: index < widget.lyricLines.length - 1 ? () => _moveTranslationDown(index) : null,
                              tooltip: l10n.moveLineDown,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(double seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toStringAsFixed(2).padLeft(5, '0')}';
  }
}
