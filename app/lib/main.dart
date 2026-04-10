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
import '../app_info.dart';
import '../models/lyric_line.dart';
import '../models/translation.dart' show Translation;
import 'screens/song_library_screen.dart';
import 'screens/player_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/playlist_screen.dart';
import 'widgets/mini_player_widget.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LingoTuneApp());
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

          return MaterialApp(
            key: const ValueKey('LingoTune'),
            title: AppInfo.appName,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeProvider.seedColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: fontFamily,
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontSize: settingsProvider.fontSize, fontFamily: fontFamily),
                bodyMedium: TextStyle(fontSize: settingsProvider.fontSize, fontFamily: fontFamily),
                bodySmall: TextStyle(fontSize: settingsProvider.fontSize - 2, fontFamily: fontFamily),
                displayLarge: TextStyle(fontSize: settingsProvider.fontSize + 8, fontFamily: fontFamily),
                displayMedium: TextStyle(fontSize: settingsProvider.fontSize + 6, fontFamily: fontFamily),
                displaySmall: TextStyle(fontSize: settingsProvider.fontSize + 4, fontFamily: fontFamily),
                headlineLarge: TextStyle(fontSize: settingsProvider.fontSize + 6, fontFamily: fontFamily),
                headlineMedium: TextStyle(fontSize: settingsProvider.fontSize + 4, fontFamily: fontFamily),
                headlineSmall: TextStyle(fontSize: settingsProvider.fontSize + 2, fontFamily: fontFamily),
                titleLarge: TextStyle(fontSize: settingsProvider.fontSize + 4, fontFamily: fontFamily),
                titleMedium: TextStyle(fontSize: settingsProvider.fontSize + 2, fontFamily: fontFamily),
                titleSmall: TextStyle(fontSize: settingsProvider.fontSize, fontFamily: fontFamily),
                labelLarge: TextStyle(fontSize: settingsProvider.fontSize, fontFamily: fontFamily),
                labelMedium: TextStyle(fontSize: settingsProvider.fontSize - 2, fontFamily: fontFamily),
                labelSmall: TextStyle(fontSize: settingsProvider.fontSize - 4, fontFamily: fontFamily),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeProvider.seedColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: fontFamily,
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontSize: settingsProvider.fontSize, fontFamily: fontFamily),
                bodyMedium: TextStyle(fontSize: settingsProvider.fontSize, fontFamily: fontFamily),
                bodySmall: TextStyle(fontSize: settingsProvider.fontSize - 2, fontFamily: fontFamily),
                displayLarge: TextStyle(fontSize: settingsProvider.fontSize + 8, fontFamily: fontFamily),
                displayMedium: TextStyle(fontSize: settingsProvider.fontSize + 6, fontFamily: fontFamily),
                displaySmall: TextStyle(fontSize: settingsProvider.fontSize + 4, fontFamily: fontFamily),
                headlineLarge: TextStyle(fontSize: settingsProvider.fontSize + 6, fontFamily: fontFamily),
                headlineMedium: TextStyle(fontSize: settingsProvider.fontSize + 4, fontFamily: fontFamily),
                headlineSmall: TextStyle(fontSize: settingsProvider.fontSize + 2, fontFamily: fontFamily),
                titleLarge: TextStyle(fontSize: settingsProvider.fontSize + 4, fontFamily: fontFamily),
                titleMedium: TextStyle(fontSize: settingsProvider.fontSize + 2, fontFamily: fontFamily),
                titleSmall: TextStyle(fontSize: settingsProvider.fontSize, fontFamily: fontFamily),
                labelLarge: TextStyle(fontSize: settingsProvider.fontSize, fontFamily: fontFamily),
                labelMedium: TextStyle(fontSize: settingsProvider.fontSize - 2, fontFamily: fontFamily),
                labelSmall: TextStyle(fontSize: settingsProvider.fontSize - 4, fontFamily: fontFamily),
              ),
            ),
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
          androidNotificationOngoing: true,
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
    });
  }

  @override
  void dispose() {
    _backgroundHandler?.dispose();
    _audioService.dispose();
    _lyricsService.dispose();
    _translationService.dispose();
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
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
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
      final isPlaying = await _audioService.player.playingStream.first;
      if (isPlaying) {
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
