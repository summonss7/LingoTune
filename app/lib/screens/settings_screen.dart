import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../services/settings_provider.dart';
import '../theme/app_gradients.dart';
import '../services/settings_dialogs.dart';
import '../app_info.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../widgets/settings/theme_settings_tile.dart';
import '../widgets/settings/language_settings_tile.dart';
import '../widgets/settings/folder_settings_tile.dart';
import '../widgets/settings/api_settings_tile.dart';
import '../widgets/settings/text_settings_section.dart';
import '../widgets/settings/font_size_control.dart';
import '../widgets/settings/scroll_offset_control.dart';
import '../widgets/settings/default_auto_scroll_focus_offset_control.dart';
import '../widgets/settings/timestamp_offset_control.dart';
import '../widgets/settings/lyrics_position_offset_control.dart';
import '../widgets/settings/tts_engine_settings_tile.dart';
import '../widgets/settings/tts_source_tile.dart';
import '../widgets/settings/voice_packages_tile.dart';
import '../widgets/settings/car_detection_settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useCustomFolder = true;
  String _customLrcJsonFolder = '';
  double _scrollOffset = 50.0;
  double _autoScrollFocusOffset = 50.0;
  bool _audioServiceInitialized = false;
  String _audioServiceError = '';

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _migrateSettings();
    await _loadFolderConfig();
    await _loadAudioServiceStatus();
  }

  Future<void> _migrateSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final defaultOffset = prefs.getDouble('defaultAutoScrollFocusOffset');

    // Если defaultAutoScrollFocusOffset отсутствует
    if (defaultOffset == null) {
      final oldOffset = prefs.getDouble('autoScrollFocusOffset');
      final newOffset = oldOffset ?? 50.0;
      await prefs.setDouble('defaultAutoScrollFocusOffset', newOffset);
      await prefs.remove('autoScrollFocusOffset');
      debugPrint('=== Migrated autoScrollFocusOffset to defaultAutoScrollFocusOffset: $newOffset ===');
    } else {
      // Если ключ существует но значение <= 0, сбросить на 50
      if (defaultOffset <= 0) {
        await prefs.setDouble('defaultAutoScrollFocusOffset', 50.0);
        await prefs.remove('autoScrollFocusOffset');
        debugPrint('=== Reset defaultAutoScrollFocusOffset from $defaultOffset to 50.0 ===');
      }
    }
  }

  Future<void> _loadAudioServiceStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _audioServiceInitialized = prefs.getBool('audioServiceInitialized') ?? false;
      _audioServiceError = prefs.getString('audioServiceError') ?? '';
    });
  }

  Future<void> _loadFolderConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useCustomFolder = prefs.getBool('useCustomFolder') ?? true;
      _customLrcJsonFolder = prefs.getString('customLrcJsonFolder') ?? '';
      _scrollOffset = prefs.getDouble('scrollOffset') ?? 50.0;
      _autoScrollFocusOffset = prefs.getDouble('defaultAutoScrollFocusOffset') ?? 50.0;
    });
  }

  Future<void> _saveFolderConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCustomFolder', _useCustomFolder);
    await prefs.setString('customLrcJsonFolder', _customLrcJsonFolder);
    debugPrint('=== Settings: Folder config saved ===');
    debugPrint('Use custom folder: $_useCustomFolder');
    debugPrint('Custom folder path: $_customLrcJsonFolder');
  }

  Future<void> _clearCache() async {
    final l10n = AppLocalizations.of(context)!;
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cacheCleared)),
      );
    }
  }

  Future<void> _selectCustomFolder() async {
    final result = await SettingsDialogs.selectCustomFolder(
      context,
      _customLrcJsonFolder,
    );
    if (result != null) {
      setState(() {
        _customLrcJsonFolder = result;
        _useCustomFolder = true;
      });
      await _saveFolderConfig();
    }
  }

  Future<void> _resetToDefaultFolder() async {
    await SettingsDialogs.resetToDefaultFolder(
      context,
      (path) => setState(() => _customLrcJsonFolder = path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: context.appBarColor(Theme.of(context).colorScheme.inversePrimary),
      ),
      body: ListView(
        children: [
          const ThemeSettingsTile(),
          const ColorThemeTile(),
          const AppLanguageTile(),
          const TranslationLanguageTile(),
          const SourceLanguageTile(),
          FolderUsageTile(
            useCustomFolder: _useCustomFolder,
            onChanged: (value) async {
              setState(() => _useCustomFolder = value);
              await _saveFolderConfig();
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(l10n.fontSize),
            subtitle: Text('${settingsProvider.fontSize.toInt()} px'),
            trailing: FontSizeControl(
              fontSize: settingsProvider.fontSize,
              minSize: 12,
              maxSize: 24,
              onChanged: (value) => settingsProvider.setFontSize(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(l10n.defaultStartScreen),
            subtitle: Text(l10n.defaultStartScreenSubtitle),
            trailing: DropdownButton<String>(
              value: settingsProvider.defaultStartScreen,
              icon: const Icon(Icons.arrow_drop_down),
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: 'library',
                  child: Row(
                    children: [
                      const Icon(Icons.library_music, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.library),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'playlists',
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_play, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.playlists),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setDefaultStartScreen(value);
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: Text(l10n.autoScroll),
            subtitle: Text(l10n.autoScrollSubtitle),
            trailing: Switch(
              value: settingsProvider.autoScroll,
              onChanged: (value) => settingsProvider.setAutoScroll(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.view_sidebar_outlined),
            title: Text(l10n.showVerticalSlider),
            subtitle: Text(l10n.showVerticalSliderSubtitle),
            trailing: Switch(
              value: settingsProvider.showVerticalSlider,
              onChanged: (value) => settingsProvider.setShowVerticalSlider(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_add),
            title: Text(l10n.addToLibraryWhenAddingToPlaylist),
            subtitle: Text(l10n.addToLibraryWhenAddingToPlaylistSubtitle),
            trailing: Switch(
              value: settingsProvider.addToLibraryWhenAddingToPlaylist,
              onChanged: (value) => settingsProvider.setAddToLibraryWhenAddingToPlaylist(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(l10n.timestampOffset),
            subtitle: Text(l10n.timestampOffsetSubtitle),
            trailing: TimestampOffsetControl(
              offset: (settingsProvider.defaultTimestampOffset / 60.0).clamp(0, 180),
            ),
          ),
          const Divider(),
          const ApiSettingsTile(),
          const Divider(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _audioServiceInitialized 
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _audioServiceInitialized 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _audioServiceInitialized ? Icons.music_note : Icons.error_outline,
                      color: _audioServiceInitialized 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      size: 28,
                    ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             l10n.audioNotificationService,
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                               color: Theme.of(context).colorScheme.onSecondaryContainer,
                             ),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             _audioServiceInitialized 
                                 ? l10n.audioNotificationServiceActive
                                 : l10n.audioNotificationServiceError,
                             style: TextStyle(
                               fontSize: 13,
                               color: _audioServiceInitialized 
                                   ? Colors.green
                                   : Colors.red,
                             ),
                           ),
                         ],
                       ),
                     ),
                  ],
                 ),
                 if (_audioServiceError.isNotEmpty) ...[
                   const SizedBox(height: 8),
                   Text(
                     '${l10n.errorLabel} $_audioServiceError',
                     style: const TextStyle(fontSize: 11, color: Colors.red),
                   ),
                 ],
                 const SizedBox(height: 8),
                 Text(
                   l10n.audioNotificationServiceDescription,
                   style: TextStyle(
                     fontSize: 12,
                     color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
                   ),
                 ),
               ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.format_color_fill),
            title: Text(l10n.highlightNextLine),
            subtitle: Text(l10n.highlightNextLineSubtitle),
            trailing: Switch(
              value: settingsProvider.highlightNextLine,
              onChanged: (value) => settingsProvider.setHighlightNextLine(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vertical_align_top),
            title: Text(l10n.scrollOffset),
            subtitle: Text(
                '${l10n.scrollOffsetSubtitle}: ${_scrollOffset.toInt()} px'),
            trailing: ScrollOffsetControl(offset: _scrollOffset),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: Text(l10n.lyricsPositionOffset),
            subtitle: Text(
                '${l10n.lyricsPositionOffsetSubtitle}: ${settingsProvider.lyricsPositionOffset.toStringAsFixed(2)}s'),
            trailing: LyricsPositionOffsetControl(
                offset: settingsProvider.lyricsPositionOffset),
          ),
          ListTile(
            leading: const Icon(Icons.center_focus_strong),
            title: Text(l10n.autoScrollFocusOffset),
            subtitle: Text(
                '${l10n.autoScrollFocusOffsetSubtitle}: ${_autoScrollFocusOffset.toInt()} px'),
            trailing: DefaultAutoScrollFocusOffsetControl(offset: _autoScrollFocusOffset),
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: Text(l10n.showTranscription),
            subtitle: Text(l10n.showTranscriptionSubtitle),
            trailing: Switch(
              value: settingsProvider.showTranscript,
              onChanged: (value) {
                settingsProvider.setShowTranscript(value);
                if (settingsProvider.showTranslationMessages && mounted) {
                  final l10n = AppLocalizations.of(context)!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? l10n.transcriptionEnabled
                          : l10n.transcriptionDisabled),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: Text(l10n.showTranslationFirst),
            subtitle: Text(l10n.showTranslationFirstSubtitle),
            trailing: Switch(
              value: settingsProvider.showTranslationFirst,
              onChanged: (value) => settingsProvider.setShowTranslationFirst(value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: Text(l10n.serviceMessages),
            subtitle: Text(l10n.serviceMessagesSubtitle),
            trailing: Switch(
              value: settingsProvider.showTranslationMessages,
              onChanged: (value) => settingsProvider.setShowTranslationMessages(value),
            ),
          ),
          const TtsEngineSettingsTile(),
          const TtsSourceSettingsTile(),
          const VoicePackagesTile(),
          const Divider(),
          const CarDetectionSettingsTile(),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(l10n.serviceData),
            subtitle: Text(l10n.serviceDataSubtitle),
            trailing: Switch(
              value: settingsProvider.showServiceData,
              onChanged: (value) => settingsProvider.setShowServiceData(value),
            ),
          ),
          const Divider(),
          const TextSettingsSection(),
          const Divider(),
          FolderSettingsTile(
            customFolder: _customLrcJsonFolder,
            onReset: _resetToDefaultFolder,
            onShowCurrent: () => SettingsDialogs.showCurrentFolder(context),
            onEdit: _selectCustomFolder,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: Text(l10n.clearCache),
            subtitle: Text(l10n.clearCacheSubtitle),
            onTap: _clearCache,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () => SettingsDialogs.showAboutDialog2(context),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'LingoTune v${AppInfo.version}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
