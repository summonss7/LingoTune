import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../constants/generation_constants.dart';
import '../models/song.dart';
import '../services/lyrics_generator_service.dart';
import '../services/deepseek_api_service.dart';
import '../services/folder_config_service.dart';
import '../services/database_service.dart';
import '../services/settings_provider.dart';

class LyricGeneratorDialog extends StatefulWidget {
  final Song song;
  final String apiKey;
  final String prompt;
  final int timeout;
  final String model;
  final String promptPreset;
  final int maxTokensRegular;
  final int maxTokensJson;

  const LyricGeneratorDialog({
    super.key,
    required this.song,
    required this.apiKey,
    this.prompt = '',
    this.timeout = 180,
    this.model = 'deepseek-chat',
    this.promptPreset = 'balanced',
    this.maxTokensRegular = 500,
    this.maxTokensJson = 8000,
  });

  @override
  State<LyricGeneratorDialog> createState() => _LyricGeneratorDialogState();
}

class _LyricGeneratorDialogState extends State<LyricGeneratorDialog> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _startMinuteController = TextEditingController(text: '30');

  bool _useFile = true;
  String? _selectedFilePath;
  String _selectedSourceLanguage = 'ro';
  final Set<String> _selectedLanguages = {};
  String _selectedTranscriptionLanguage = 'ru';
  List<double>? _originalTimestamps;

  bool _isFirstGeneration = true;

  bool _isGenerating = false;
  double _progress = 0.0;
  String _status = '';

  late LyricsGeneratorService _generatorService;
  late DeepSeekApiService _apiService;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initializeServices();

      if (GenerationConstants.sourceLanguages.contains(widget.song.originalLanguage) &&
          widget.song.originalLanguage != 'unknown') {
        _selectedSourceLanguage = widget.song.originalLanguage;
        debugPrint('✓ Using song original language: $_selectedSourceLanguage');
      } else {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        _selectedSourceLanguage = settingsProvider.defaultSourceLanguage;
        debugPrint('✓ Using settings default source language: $_selectedSourceLanguage');
      }

      final hasTranslations = widget.song.lrcPath != null && widget.song.lrcPath!.isNotEmpty;
      _isFirstGeneration = !hasTranslations;

      if (_isFirstGeneration) {
        _selectedLanguages.addAll(['trans', 'ru']);
        debugPrint('✓ First generation: selected default languages (trans, ru)');
      } else {
        _selectedLanguages.clear();
        debugPrint('✓ Regeneration: cleared language selection, user must choose');
      }

      _loadExistingTranslationText();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _initializeServices() {
    _apiService = DeepSeekApiService(
      apiKey: widget.apiKey,
      customPrompt: widget.prompt,
      timeout: widget.timeout,
      model: widget.model,
      promptPreset: widget.promptPreset,
      maxTokensRegular: widget.maxTokensRegular,
      maxTokensJson: widget.maxTokensJson,
    );
    _generatorService = LyricsGeneratorService(apiService: _apiService);
  }

  Future<void> _loadExistingTranslationText() async {
    try {
      // ПРИОРИТЕТ 1: LRC файл - всегда загружаем из него при повторной генерации
      if (widget.song.lrcPath != null && widget.song.lrcPath!.isNotEmpty) {
        final lrcFile = File(widget.song.lrcPath!);
        if (await lrcFile.exists()) {
          final lrcContent = await lrcFile.readAsString();
          
          // Извлекаем текст без timestamps
          final textLines = _parseLrcText(lrcContent);
          
          // Извлекаем timestamps из LRC файла
          _originalTimestamps = _extractLrcTimestamps(lrcContent);
          
          if (textLines.isNotEmpty) {
            setState(() {
              _textController.text = textLines.join('\n');
            });
            debugPrint('✓ Loaded text from LRC file');
            debugPrint('✓ Extracted ${_originalTimestamps!.length} timestamps from LRC');
            return;
          }
        }
      }
      
      final database = DatabaseService();
      final translationFiles = await database.getTranslationFiles(widget.song.id);

      if (translationFiles.isEmpty) {
        debugPrint('No existing translations found');
        return;
      }

      final originalLanguage = widget.song.originalLanguage;

      debugPrint('=== Loading existing translation text ===');
      debugPrint('Original language: $originalLanguage');
      debugPrint('Available translations: ${translationFiles.map((f) => f['language']).toList()}');

      for (final file in translationFiles) {
        final language = file['language'] as String?;
        final type = file['type'] as String?;

        if (type == 'transcript') {
          continue;
        }

        if (language == originalLanguage) {
          final text = await _loadTextFromTranslation(file['filePath'] as String);
          if (text != null) {
            setState(() {
              _textController.text = text;
            });
            
            // Автоматическая настройка языка по загруженному тексту
            if (originalLanguage != _selectedSourceLanguage) {
              setState(() {
                _selectedSourceLanguage = originalLanguage;
              });
              debugPrint('⚠ Auto-switched source language to match loaded text: $originalLanguage');
            }
            
            debugPrint('✓ Loaded text from original language: $originalLanguage');
            return;
          }
        }
      }

      debugPrint('Original language translation not found, checking transcript...');

      for (final file in translationFiles) {
        final type = file['type'] as String?;

        if (type == 'transcript') {
          final filePath = file['filePath'] as String;
          final jsonFile = File(filePath);

          if (await jsonFile.exists()) {
            final content = await jsonFile.readAsString();
            final data = json.decode(content) as Map<String, dynamic>;
            final translations = data['translations'] as List?;

            if (translations != null && translations.isNotEmpty) {
              final translation = translations[0] as Map<String, dynamic>;
              final lines = translation['lines'] as List?;

              if (lines != null && lines.isNotEmpty) {
                final textLines = lines.map((line) {
                  final lineData = line as Map<String, dynamic>;
                  return (lineData['text'] as String? ?? '').trim();
                }).where((line) => line.isNotEmpty).toList();

                if (textLines.isNotEmpty) {
                  setState(() {
                    _textController.text = textLines.join('\n');
                  });
                  
                  // Текст из transcript использует originalLanguage из файла
                  if (originalLanguage != null && originalLanguage != _selectedSourceLanguage) {
                    setState(() {
                      _selectedSourceLanguage = originalLanguage;
                    });
                    debugPrint('⚠ Auto-switched source language to match transcript original: $originalLanguage');
                  }
                  
                  debugPrint('✓ Loaded text from transcript (original IPA)');
                  return;
                }
              }
            }
          }
        }
      }

      debugPrint('Transcript not found, using first available translation...');

      for (final file in translationFiles) {
        final type = file['type'] as String?;

        if (type == 'transcript') {
          continue;
        }

        final text = await _loadTextFromTranslation(file['filePath'] as String);
        if (text != null) {
          final language = file['language'] as String?;
          setState(() {
            _textController.text = text;
            if (language != null) {
              _selectedSourceLanguage = language;
            }
          });
          debugPrint('⚠ Loaded text from available language: $language (not original)');
          if (language != null && language != _selectedSourceLanguage) {
            debugPrint('⚠ Auto-switched source language to: $language');
          }
          return;
        }
      }

      debugPrint('✗ No valid translation text found');
    } catch (e) {
      debugPrint('Error loading existing translation: $e');
    }
  }

  Future<String?> _loadTextFromTranslation(String filePath) async {
    try {
      final jsonFile = File(filePath);

      if (await jsonFile.exists()) {
        final content = await jsonFile.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        final translations = data['translations'] as List?;

        if (translations != null && translations.isNotEmpty) {
          final translation = translations[0] as Map<String, dynamic>;
          final lines = translation['lines'] as List?;

          if (lines != null && lines.isNotEmpty) {
            final textLines = lines.map((line) {
              final lineData = line as Map<String, dynamic>;
              return (lineData['text'] as String? ?? lineData['translatedText'] as String? ?? '').trim();
            }).where((line) => line.isNotEmpty).toList();

            if (textLines.isNotEmpty) {
              return textLines.join('\n');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading translation from file: $e');
    }
    return null;
  }

  /// Парсит LRC файл и извлекает текст без временных меток
  List<String> _parseLrcText(String lrcContent) {
    final lines = lrcContent.split('\n');
    final textLines = <String>[];
    
    for (final line in lines) {
      // LRC формат: [00:30.00]Текст
      // Убираем timestamp в начале
      final text = line.replaceFirst(RegExp(r'^\[\d{2}:\d{2}\.\d{2,3}\]'), '').trim();
      if (text.isNotEmpty) {
        textLines.add(text);
      }
    }
    
    return textLines;
  }

  /// Извлекает timestamps из LRC файла
  List<double> _extractLrcTimestamps(String lrcContent) {
    final lines = lrcContent.split('\n');
    final timestamps = <double>[];

    for (final line in lines) {
      try {
        final match = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2,3})\]').firstMatch(line);
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final fraction = match.group(3)!;
          final milliseconds = fraction.length == 2
              ? int.parse(fraction) * 10
              : int.parse(fraction);

          final totalSeconds = (minutes * 60.0) + seconds.toDouble() + (milliseconds / 1000.0);
          timestamps.add(totalSeconds);
        }
      } catch (e) {
        debugPrint('Warning: Failed to parse LRC timestamp from line: $line, Error: $e');
      }
    }

    return timestamps;
  }

  @override
  void dispose() {
    _textController.dispose();
    _startMinuteController.dispose();
    super.dispose();
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

  String _getText() {
    return _textController.text.trim();
  }

  void _showLanguageSelectionDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.translationLanguages),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: GenerationConstants.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = GenerationConstants.supportedLanguages.keys.elementAt(index);
                    final languageName = GenerationConstants.supportedLanguages[lang] ?? lang;
                    final isSelected = _selectedLanguages.contains(lang);

                    return CheckboxListTile(
                      title: Text(languageName),
                      value: isSelected,
                      onChanged: (value) {
                        setDialogState(() {
                          setState(() {
                            if (value == true) {
                              _selectedLanguages.add(lang);
                            } else {
                              _selectedLanguages.remove(lang);
                            }
                          });
                        });
                      },
                      controlAffinity: ListTileControlAffinity.platform,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generate() async {
    final text = _getText();

    if (text.isEmpty) {
      _showError('Please provide text');
      return;
    }

    if (_selectedLanguages.isEmpty) {
      _showError('Please select at least one language');
      return;
    }

    final startMinute = double.tryParse(_startMinuteController.text) ?? 30.0;

    setState(() {
      _isGenerating = true;
      _progress = 0.0;
      _status = AppLocalizations.of(context)!.generating;
    });

    try {
      final apiResult = await _apiService.generateAllTranslations(
        text: text,
        languages: _selectedLanguages.toList(),
        sourceLanguage: _selectedSourceLanguage,
        transcriptionLanguage: _selectedTranscriptionLanguage,
        onProgress: (progress) {
          setState(() {
            _progress = progress * 0.5;
            _status = '${(progress * 100).toInt()}%';
          });
        },
      );

      if (apiResult.isEmpty) {
        _showError('Failed to generate translations');
        setState(() {
          _isGenerating = false;
        });
        return;
      }

      setState(() {
        _progress = 0.5;
        _status = AppLocalizations.of(context)!.savingFiles;
      });

      await _saveGeneratedFiles(apiResult, startMinute);

      // Обновляем язык оригинала в БД песни
      final database = DatabaseService();
      if (widget.song.originalLanguage != _selectedSourceLanguage) {
        await database.updateSongOriginalLanguage(widget.song.id, _selectedSourceLanguage);
        debugPrint('✓ Updated song original language in DB: $_selectedSourceLanguage');
      }

      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.setDefaultSourceLanguage(_selectedSourceLanguage);
      
      setState(() {
        _progress = 1.0;
        _status = AppLocalizations.of(context)!.lyricsGenerationSuccess;
      });

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('Error: $e');
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _saveGeneratedFiles(Map<String, dynamic> apiResult, double startMinute) async {
    final l10n = AppLocalizations.of(context)!;
    final songName = widget.song.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    final lyricsFolder = await FolderConfigService.getConfiguredFolder();
    if (lyricsFolder == null) {
      throw Exception('No lyrics folder configured');
    }

    final textLines = _getText().split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    double startTime;

    // Если есть оригинальные timestamps из LRC файла, используем их
    if (_originalTimestamps != null && _originalTimestamps!.isNotEmpty) {
      debugPrint('✓ Using original timestamps from LRC file (${_originalTimestamps!.length} timestamps)');
      startTime = _originalTimestamps!.first;
    } else {
      // Иначе используем startMinute из настроек
      startTime = startMinute * 60.0;
      debugPrint('✓ Using start minute from settings: $startMinute');
    }

    final lrcPath = '${lyricsFolder.path}/$songName.lrc';
    await _saveLrcFile(lrcPath, textLines, startTime);

    final database = DatabaseService();
    await database.updateSongLrcPath(widget.song.id, lrcPath);

    final transcriptions = apiResult['transcriptions'] as Map<String, dynamic>? ?? {};
    final transcriptionRu = transcriptions['ru'] as String? ?? '';
    final transcriptionEn = transcriptions['en'] as String? ?? '';
    final transcriptionLatin = transcriptions['latin'] as String? ?? '';

    for (final lang in _selectedLanguages) {
      if (!apiResult.containsKey(lang) && lang != 'trans') continue;

      if (lang == 'trans') {
        final transcriptionTargetMap = {
          'ru': transcriptionRu,
          'en': transcriptionEn,
          'de': transcriptionEn,
          'es': transcriptionEn,
          'fr': transcriptionEn,
          'it': transcriptionEn,
          'pt': transcriptionEn
        };
        final transcriptionTarget = transcriptionTargetMap[_selectedTranscriptionLanguage] ?? transcriptionEn;

        final lines = _createTranscriptionLines(transcriptionLatin, transcriptionTarget, startTime);
        final jsonPath = '${lyricsFolder.path}/$songName\_trans.json';
        await _saveJsonFile(jsonPath, songName, 'trans', l10n.transcript, 'transcript', lines);

        await database.addTranslation(
          songId: widget.song.id,
          language: 'trans',
          languageName: l10n.transcript,
          filePath: jsonPath,
          type: 'transcript',
        );
      } else {
        final langData = apiResult[lang] as Map<String, dynamic>;
        final translation = langData['translation'] as String? ?? '';

        final transcript = (lang == 'ru' || lang == 'ru_literal') ? transcriptionRu : transcriptionLatin;
        final lines = _createTranslationLines(translation, transcript, startTime);

        final type = lang == 'ru_literal' ? 'literal' : null;
        final languageName = GenerationConstants.supportedLanguages[lang] ?? lang;

        final jsonPath = '${lyricsFolder.path}/$songName\_$lang.json';
        await _saveJsonFile(jsonPath, songName, lang, languageName, type, lines);

        await database.addTranslation(
          songId: widget.song.id,
          language: lang,
          languageName: languageName,
          filePath: jsonPath,
          type: type,
        );
      }
    }

    setState(() {
      _progress = 1.0;
    });
  }

  Future<void> _saveLrcFile(String path, List<String> lines, double startTime) async {
    final file = File(path);
    final buffer = StringBuffer();

      if (_originalTimestamps != null && _originalTimestamps!.length == lines.length) {
      debugPrint('✓ Using original timestamps from LRC file for ${lines.length} lines');
      for (int i = 0; i < lines.length; i++) {
        final currentStartTime = _originalTimestamps![i];
        final minutes = currentStartTime ~/ 60;
        final seconds = (currentStartTime % 60).toInt();
        final milliseconds = ((currentStartTime % 1) * 1000).round().clamp(0, 999);

        buffer.write('[${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}.'
            '${milliseconds.toString().padLeft(3, '0')}]');
        buffer.writeln(lines[i]);
      }
    } else {
      debugPrint('✓ Generating new timestamps with start time: $startTime');
      for (final line in lines) {
        final minutes = startTime ~/ 60;
        final seconds = (startTime % 60).toInt();
        final milliseconds = ((startTime % 1) * 1000).truncate().clamp(0, 999);

        buffer.write('[${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}.'
            '${milliseconds.toString().padLeft(3, '0')}]');
        buffer.writeln(line);
        startTime += GenerationConstants.timingStep;
      }
    }

    await file.writeAsString(buffer.toString());
  }

  List<Map<String, dynamic>> _createTranscriptionLines(String text, String transcript, double startTime) {
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    final transcripts = transcript.split('\n').map((line) => line.trim()).toList();
    return List.generate(lines.length, (index) {
      double currentStartTime;
      double? originalTimestamp;
      
      // Если есть оригинальные timestamps из LRC файла, используем их
      if (_originalTimestamps != null && _originalTimestamps!.length > index) {
        currentStartTime = _originalTimestamps![index];
        originalTimestamp = currentStartTime;
        debugPrint('✓ Using original timestamp for transcription line $index: ${currentStartTime}s');
      } else {
        // Иначе генерируем timestamps с шагом timingStep
        currentStartTime = startTime;
        startTime += GenerationConstants.timingStep;
      }
      
      final result = {
        'startTime': currentStartTime,
        'text': lines[index],
        'translatedText': null,
        'transcript': index < transcripts.length ? transcripts[index] : '',
        'originalStartTime': originalTimestamp,
      };
      
      return result;
    });
  }

  List<Map<String, dynamic>> _createTranslationLines(String translation, String transcript, double startTime) {
    final lines = translation.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    final transcripts = transcript.split('\n').map((line) => line.trim()).toList();
    
    return List.generate(lines.length, (index) {
      double currentStartTime;
      double? originalTimestamp;
      
      // Если есть оригинальные timestamps из LRC файла, используем их
      if (_originalTimestamps != null && _originalTimestamps!.length > index) {
        currentStartTime = _originalTimestamps![index];
        originalTimestamp = currentStartTime;
        debugPrint('✓ Using original timestamp for line $index: ${currentStartTime}s');
      } else {
        // Иначе генерируем timestamps с шагом timingStep
        currentStartTime = startTime;
        startTime += GenerationConstants.timingStep;
      }
      
      final result = {
        'startTime': currentStartTime,
        'text': lines[index],
        'translatedText': null,
        'transcript': index < transcripts.length ? transcripts[index] : '',
        'originalStartTime': originalTimestamp,
      };
      
      return result;
    });
  }

  Future<void> _saveJsonFile(String path, String songTitle, String language, String languageName, String? type, List<Map<String, dynamic>> lines) async {
    final file = File(path);
    final data = {
      'title': songTitle,
      'artist': widget.song.artist,
      'originalLanguage': _selectedSourceLanguage,
      'translations': [
        {
          'language': language,
          'languageName': languageName,
          if (type != null) 'type': type,
          'lines': lines,
        }
      ]
    };

    final jsonString = jsonEncode(data);
    await file.writeAsString(jsonString);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.generateLyrics),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isGenerating) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text(_status, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
              ],
              if (!_isGenerating) ...[
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('File')),
                    ButtonSegment(value: false, label: Text('Text')),
                  ],
                  selected: {_useFile},
                  onSelectionChanged: (Set<bool> selected) {
                    setState(() {
                      _useFile = selected.first;
                      if (!_useFile) {
                        _selectedFilePath = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_useFile)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedFilePath ?? l10n.noFileSelected,
                          style: TextStyle(
                            color: _selectedFilePath != null ? Colors.black : Colors.grey,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.folder_open),
                        onPressed: _pickFile,
                      ),
                    ],
                  ),
                if (!_useFile)
                  TextField(
                    controller: _textController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      labelText: l10n.enterText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSourceLanguage,
                  decoration: InputDecoration(
                    labelText: l10n.originalLanguage,
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
                      _selectedSourceLanguage = value ?? 'ro';
                    });
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _showLanguageSelectionDialog,
                  borderRadius: BorderRadius.circular(4),
                   child: InputDecorator(
                     decoration: InputDecoration(
                       labelText: l10n.translationLanguages,
                       border: const OutlineInputBorder(),
                       suffixIcon: const Icon(Icons.arrow_drop_down),
                     ),
                     child: Text(
                       _selectedLanguages.isEmpty 
                         ? l10n.selectLanguages
                         : l10n.selectedLanguagesCount(_selectedLanguages.length),
                     ),
                   ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _startMinuteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.startMinuteForTimestamps,
                    border: const OutlineInputBorder(),
                    suffixText: 'min',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTranscriptionLanguage,
                  decoration: InputDecoration(
                    labelText: l10n.transcriptionLanguage,
                    border: const OutlineInputBorder(),
                  ),
                  items: ['ru', 'en', 'de'].map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(lang.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTranscriptionLanguage = value ?? 'ru';
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (!_isGenerating)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        if (!_isGenerating)
          ElevatedButton(
            onPressed: _generate,
            child: Text(l10n.generate),
          ),
      ],
    );
  }
}
