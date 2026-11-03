import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart' as audio_pkg;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';
import '../services/translation_service.dart';
import '../services/theme_provider.dart';
import '../services/settings_provider.dart';
import '../services/background_audio_handler.dart';
import '../services/database_service.dart';
import '../services/tts_coordinator.dart';
import '../services/update_flow.dart';
import '../app_info.dart';
import '../models/lyric_line.dart';
import '../models/translation.dart' show Translation;
import 'screens/song_library_screen.dart';
import 'screens/player_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/playlist_screen.dart';
import 'widgets/mini_player_widget.dart';
import 'theme/app_gradients.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LingoTuneApp());
}

/// Масштаб типографики от пользовательского размера шрифта (бывший
/// дублировавшийся inline-TextTheme в light/dark темах).
TextTheme _buildTextTheme(double fontSize, String? fontFamily) {
  return TextTheme(
    bodyLarge: TextStyle(fontSize: fontSize, fontFamily: fontFamily),
    bodyMedium: TextStyle(fontSize: fontSize, fontFamily: fontFamily),
    bodySmall: TextStyle(fontSize: fontSize - 2, fontFamily: fontFamily),
    displayLarge: TextStyle(fontSize: fontSize + 8, fontFamily: fontFamily),
    displayMedium: TextStyle(fontSize: fontSize + 6, fontFamily: fontFamily),
    displaySmall: TextStyle(fontSize: fontSize + 4, fontFamily: fontFamily),
    headlineLarge: TextStyle(fontSize: fontSize + 6, fontFamily: fontFamily),
    headlineMedium: TextStyle(fontSize: fontSize + 4, fontFamily: fontFamily),
    headlineSmall: TextStyle(fontSize: fontSize + 2, fontFamily: fontFamily),
    titleLarge: TextStyle(fontSize: fontSize + 4, fontFamily: fontFamily),
    titleMedium: TextStyle(fontSize: fontSize + 2, fontFamily: fontFamily),
    titleSmall: TextStyle(fontSize: fontSize, fontFamily: fontFamily),
    labelLarge: TextStyle(fontSize: fontSize, fontFamily: fontFamily),
    labelMedium: TextStyle(fontSize: fontSize - 2, fontFamily: fontFamily),
    labelSmall: TextStyle(fontSize: fontSize - 4, fontFamily: fontFamily),
  );
}

/// Обычная seed-тема (13 цветовых пресетов настроек).
ThemeData _seededTheme(
  Color seed,
  Brightness brightness,
  TextTheme textTheme,
  String? fontFamily,
) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    useMaterial3: true,
    fontFamily: fontFamily,
    textTheme: textTheme,
  );
}

class LingoTuneApp extends StatelessWidget {
  const LingoTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, _) {
          final fontFamily = settingsProvider.fontFamily.isEmpty ? null : settingsProvider.fontFamily;
          final textTheme = _buildTextTheme(settingsProvider.fontSize, fontFamily);
          final isAmethyst = themeProvider.isAmethystSkin;

          return MaterialApp(
            key: const ValueKey('LingoTune'),
            title: AppInfo.appName,
            theme: isAmethyst
                ? AmethystPalette.buildTheme(
                    darkVariant: false, textTheme: textTheme, fontFamily: fontFamily)
                : _seededTheme(themeProvider.seedColor, Brightness.light, textTheme, fontFamily),
            darkTheme: isAmethyst
                ? AmethystPalette.buildTheme(
                    darkVariant: true, textTheme: textTheme, fontFamily: fontFamily)
                : _seededTheme(themeProvider.seedColor, Brightness.dark, textTheme, fontFamily),
            // Тема «Аметист»: один полноэкранный градиент за всеми экранами —
            // Scaffold'ы прозрачны, фон течёт от статус-бара до нав-бара
            // (как full-screen Box в Ai-LeCards). Остальные темы — без обёртки.
            builder: (context, child) {
              final gradients = Theme.of(context).extension<AppGradients>();
              if (gradients == null) return child ?? const SizedBox.shrink();
              return DecoratedBox(
                decoration: BoxDecoration(gradient: gradients.backdrop),
                child: child ?? const SizedBox.shrink(),
              );
            },
            themeMode: themeProvider.themeMode,
            locale: Locale(settingsProvider.appLanguage),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AudioService _audioService = AudioService();
  final LyricsService _lyricsService = LyricsService();
  final TranslationService _translationService = TranslationService();

  int _currentIndex = 0;
  String _defaultStartScreen = 'library';
  bool _backgroundAudioInitialized = false;
  BackgroundAudioHandler? _backgroundHandler;

  Future<bool> _requestNotificationPermission() async {
    if (!mounted) return false;
    
    try {
      final permissionStatus = await Permission.notification.status;
      debugPrint('Notification permission status: $permissionStatus');
      
      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        final result = await Permission.notification.request();
        debugPrint('Notification permission request result: $result');
        return result.isGranted;
      } else if (permissionStatus.isGranted) {
        debugPrint('✓ Notification permission already granted');
        return true;
      } else {
        debugPrint('✗ Notification permission not available: $permissionStatus');
        return false;
      }
    } catch (e) {
      debugPrint('✗ Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> _initBackgroundAudioService() async {
    if (_backgroundAudioInitialized) return;
    
    try {
      debugPrint('=== MainScreen: Initializing background audio service ===');
      
      final notificationGranted = await _requestNotificationPermission();
      debugPrint('Notification permission granted: $notificationGranted');
      
      final prefs = await SharedPreferences.getInstance();
      
      debugPrint('✓ MainScreen: Initializing AudioService with notifications...');
      _backgroundHandler = await audio_pkg.AudioService.init(
        builder: () => BackgroundAudioHandler(_audioService.player),
        config: audio_pkg.AudioServiceConfig(
          androidNotificationChannelId: 'com.lingotune.app.channel.audio',
          androidNotificationChannelName: 'LingoTune Music',
          // androidNotificationOngoing убран (v5.12.2, lingotune-011): флаг
          // игнорируется при androidStopForegroundOnPause: false (сервис
          // остаётся foreground и на паузе — уведомление и так ongoing), но
          // его assert валил AudioService.init в DEBUG-сборках с первого
          // коммита: BackgroundAudioHandler не создавался, фоновое
          // воспроизведение и обработка звонков/beep'ов были мертвы.
          androidShowNotificationBadge: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          fastForwardInterval: const Duration(seconds: 10),
          rewindInterval: const Duration(seconds: 10),
          androidStopForegroundOnPause: false,
        ),
      );
      _audioService.setBackgroundHandler(_backgroundHandler!);
      debugPrint('✓ MainScreen: AudioService initialized, handler connected');
      await prefs.setBool('audioServiceInitialized', true);
      await prefs.setBool('notificationPermissionGranted', notificationGranted);
      await prefs.setString('audioServiceError', '');

      _backgroundAudioInitialized = true;
    } catch (e) {
      debugPrint('✗ Error initializing background audio service: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('audioServiceInitialized', false);
      await prefs.setString('audioServiceError', e.toString());
      
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) {
            _showAudioServiceErrorDialog(e.toString());
          }
        });
      }
    }
  }

  void _showAudioServiceErrorDialog(String error) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Text(l10n.errorAudioService, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.audioServiceFailed),
              const SizedBox(height: 8),
              Text(l10n.notificationMayNotAppear),
              const SizedBox(height: 16),
              Text(l10n.errorLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(error, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadInitialScreen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBackgroundAudioService();
      // Тихая проверка обновлений через 5 с после старта (не чаще раза в
      // сутки); диалог «доступна новая версия» всплывает поверх текущего
      // экрана, если вышла новая версия.
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          UpdateFlow.maybeAutoCheck(context);
        }
      });
    });
  }

  @override
  void dispose() {
    _backgroundHandler?.dispose();
    _audioService.dispose();
    _lyricsService.dispose();
    _translationService.dispose();
    // TtsCoordinator — синглтон, переживает rebuild. В production не диспозим
    // (процесс всё равно убивается), но при hot-restart во время разработки
    // без этого теряется ~63 МБ sherpa_onnx-модели на каждой итерации.
    // Диспозим последним: к этому моменту StudyModeService (если был активен)
    // уже освобождён своим владельцем.
    TtsCoordinator.instance.dispose();
    super.dispose();
  }

  Future<void> _loadInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final savedScreen = prefs.getString('defaultStartScreen') ?? 'playlists';
    if (mounted) {
      setState(() {
        _defaultStartScreen = savedScreen;
        _currentIndex = savedScreen == 'playlists' ? 1 : 0;
      });
    }
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return SongLibraryScreen(
          audioService: _audioService,
          lyricsService: _lyricsService,
          translationService: _translationService,
        );
      case 1:
        return PlaylistScreen(
          audioService: _audioService,
          lyricsService: _lyricsService,
          translationService: _translationService,
        );
      case 2:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _getCurrentScreen()),
          if (_currentIndex != 2)
            ListenableBuilder(
              listenable: _audioService,
              builder: (context, _) => MiniPlayerWidget(
                audioService: _audioService,
                onTap: _openCurrentPlayer,
                onPlayPause: _togglePlayback,
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.library_music, l10n.library),
            _buildNavItem(1, Icons.playlist_play, l10n.playlists),
            _buildNavItem(2, Icons.settings, l10n.settings),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    // «Аметист»: выбранный пункт — градиентная карточка темнее фона.
    final skinCard = isSelected ? amethystCardDecoration(context, radius: 20) : null;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: skinCard ??
            BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlayback() async {
    try {
      // Синхронный снапшот состояния плеера. Раньше здесь использовался
      // `await _audioService.player.playingStream.first` — это открывало окно
      // гонки между чтением состояния и вызовом pause()/play(): за время
      // await состояние могло измениться (фоновый handler, study mode, звонок),
      // что приводило к инверсии/«мерцанию» кнопки play/pause. Текущее значение
      // `player.playing` — синхронный геттер just_audio, отражающий последний
      // известный статус — достаточно для toggle.
      if (_audioService.player.playing) {
        await _audioService.pause();
      } else {
        if (_audioService.isInitialized) {
          await _audioService.play();
        }
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
    }
  }

  Future<void> _openCurrentPlayer() async {
    final song = _audioService.currentSong;
    if (song == null || !_audioService.hasActiveSong) return;

    try {
      final db = DatabaseService();
      final updatedSong = await db.getSong(song.id);
      if (updatedSong == null) return;

      if (_lyricsService.lyricLines.isEmpty && updatedSong.lrcPath != null && updatedSong.lrcPath!.isNotEmpty) {
        await _lyricsService.loadLrcFile(updatedSong.lrcPath!);
      }

      if (_translationService.translations.isEmpty) {
        final translationFiles = await db.getTranslationFiles(song.id);
        for (final tf in translationFiles) {
          final filePath = tf['filePath'] as String;
          final language = tf['language'] as String;
          final languageName = tf['languageName'] as String;
          final type = tf['type'] as String?;

          try {
            final file = File(filePath);
            if (await file.exists()) {
              final content = await file.readAsString();
              final data = json.decode(content) as Map<String, dynamic>;
              if (data.containsKey('translations')) {
                final translations = data['translations'] as List;
                for (final t in translations) {
                  final translationData = t as Map<String, dynamic>;
                  final lines = (translationData['lines'] as List?)
                      ?.map((l) => LyricLine.fromJson(l as Map<String, dynamic>))
                      .toList() ?? [];
                  _translationService.addTranslation(Translation(
                    language: language,
                    languageName: languageName,
                    type: type,
                    lines: lines,
                    filePath: filePath,
                  ));
                }
              }
            }
          } catch (e) {
            debugPrint('Error loading translation for resume: $e');
          }
        }
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(
            song: updatedSong,
            audioService: _audioService,
            lyricsService: _lyricsService,
            translationService: _translationService,
            playlistSongs: _audioService.currentPlaylist,
            shouldResume: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error opening current player: $e');
    }
  }
}
