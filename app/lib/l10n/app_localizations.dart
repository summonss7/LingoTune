import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('uk'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LingoTune'**
  String get appTitle;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @allSongs.
  ///
  /// In en, this message translates to:
  /// **'All Songs'**
  String get allSongs;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get createPlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist Name'**
  String get playlistName;

  /// No description provided for @iconOptional.
  ///
  /// In en, this message translates to:
  /// **'Icon (optional)'**
  String get iconOptional;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addToPlaylist;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from Playlist'**
  String get removeFromPlaylist;

  /// No description provided for @addSongsToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add songs from Library'**
  String get addSongsToLibrary;

  /// No description provided for @noSongsToAdd.
  ///
  /// In en, this message translates to:
  /// **'No songs to add'**
  String get noSongsToAdd;

  /// No description provided for @addButtonText.
  ///
  /// In en, this message translates to:
  /// **'Add {count}'**
  String addButtonText(Object count);

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @autoScroll.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll'**
  String get autoScroll;

  /// No description provided for @autoScrollSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically scroll to current line'**
  String get autoScrollSubtitle;

  /// No description provided for @highlightNextLine.
  ///
  /// In en, this message translates to:
  /// **'Highlight Next Line'**
  String get highlightNextLine;

  /// No description provided for @highlightNextLineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show next line with subtle highlight'**
  String get highlightNextLineSubtitle;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @scrollOffset.
  ///
  /// In en, this message translates to:
  /// **'Scroll Offset'**
  String get scrollOffset;

  /// No description provided for @scrollOffsetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Distance from top of screen in pixels'**
  String get scrollOffsetSubtitle;

  /// No description provided for @autoScrollFocusOffset.
  ///
  /// In en, this message translates to:
  /// **'Auto Scroll Focus Offset'**
  String get autoScrollFocusOffset;

  /// No description provided for @autoScrollFocusOffsetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default focus position for auto-scroll (default: +50)'**
  String get autoScrollFocusOffsetSubtitle;

  /// No description provided for @defaultTranslationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default Translation Language'**
  String get defaultTranslationLanguage;

  /// No description provided for @defaultOriginalLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default Original Language'**
  String get defaultOriginalLanguage;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @romanian.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get romanian;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// No description provided for @lyricsFolder.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Folder'**
  String get lyricsFolder;

  /// No description provided for @useLyricsFolder.
  ///
  /// In en, this message translates to:
  /// **'Use Lyrics Folder'**
  String get useLyricsFolder;

  /// No description provided for @useLyricsFolderDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled - files must be selected with audio'**
  String get useLyricsFolderDisabled;

  /// No description provided for @setLyricsFolder.
  ///
  /// In en, this message translates to:
  /// **'Set Lyrics Folder'**
  String get setLyricsFolder;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Folder'**
  String get selectFolder;

  /// No description provided for @folderPath.
  ///
  /// In en, this message translates to:
  /// **'Folder path'**
  String get folderPath;

  /// No description provided for @examples.
  ///
  /// In en, this message translates to:
  /// **'Examples:'**
  String get examples;

  /// No description provided for @defaultFolder.
  ///
  /// In en, this message translates to:
  /// **'Default: /LingoTune_Lyrics'**
  String get defaultFolder;

  /// No description provided for @currentFolder.
  ///
  /// In en, this message translates to:
  /// **'Current folder:'**
  String get currentFolder;

  /// No description provided for @folderSetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Folder set: {path}'**
  String folderSetSuccessfully(Object path);

  /// No description provided for @folderSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Folder does not exist or no access'**
  String get folderSetFailed;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @showCurrentFolder.
  ///
  /// In en, this message translates to:
  /// **'Show current folder'**
  String get showCurrentFolder;

  /// No description provided for @changeFolder.
  ///
  /// In en, this message translates to:
  /// **'Change folder'**
  String get changeFolder;

  /// No description provided for @resetToDefaultFolder.
  ///
  /// In en, this message translates to:
  /// **'Reset to default folder'**
  String get resetToDefaultFolder;

  /// No description provided for @folderReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to default folder'**
  String get folderReset;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear temporary files'**
  String get clearCacheSubtitle;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @resetSongLanguages.
  ///
  /// In en, this message translates to:
  /// **'Reset Song Languages'**
  String get resetSongLanguages;

  /// No description provided for @resetSongLanguagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use default language from settings'**
  String get resetSongLanguagesSubtitle;

  /// No description provided for @songLanguagesReset.
  ///
  /// In en, this message translates to:
  /// **'Song languages reset'**
  String get songLanguagesReset;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @translationsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Translations loaded successfully!'**
  String get translationsLoaded;

  /// No description provided for @failedToLoadTranslations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load translations: {error}'**
  String failedToLoadTranslations(Object error);

  /// No description provided for @editTranslations.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTranslations;

  /// No description provided for @loadTranslationsFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import ZIP archive'**
  String get loadTranslationsFromFile;

  /// No description provided for @loadTextMenu.
  ///
  /// In en, this message translates to:
  /// **'Load text'**
  String get loadTextMenu;

  /// No description provided for @loadTranslations.
  ///
  /// In en, this message translates to:
  /// **'Load Translations'**
  String get loadTranslations;

  /// No description provided for @deleteTranslation.
  ///
  /// In en, this message translates to:
  /// **'Delete translation'**
  String get deleteTranslation;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @noLrcFileAssociated.
  ///
  /// In en, this message translates to:
  /// **'No LRC file associated with this song'**
  String get noLrcFileAssociated;

  /// No description provided for @lrcFileSaved.
  ///
  /// In en, this message translates to:
  /// **'LRC file saved successfully!'**
  String get lrcFileSaved;

  /// No description provided for @failedToSaveLrcFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save LRC file: {error}'**
  String failedToSaveLrcFile(Object error);

  /// No description provided for @exitEditMode.
  ///
  /// In en, this message translates to:
  /// **'Exit edit mode'**
  String get exitEditMode;

  /// No description provided for @editTimestamps.
  ///
  /// In en, this message translates to:
  /// **'Edit timestamps'**
  String get editTimestamps;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noSongsFound.
  ///
  /// In en, this message translates to:
  /// **'No songs found'**
  String get noSongsFound;

  /// No description provided for @noPlaylistsFound.
  ///
  /// In en, this message translates to:
  /// **'No playlists found'**
  String get noPlaylistsFound;

  /// No description provided for @selectSong.
  ///
  /// In en, this message translates to:
  /// **'Select a song to play'**
  String get selectSong;

  /// No description provided for @song.
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get song;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @rewind10.
  ///
  /// In en, this message translates to:
  /// **'-10s'**
  String get rewind10;

  /// No description provided for @forward10.
  ///
  /// In en, this message translates to:
  /// **'+10s'**
  String get forward10;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @translations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translations;

  /// No description provided for @originalText.
  ///
  /// In en, this message translates to:
  /// **'Original Text'**
  String get originalText;

  /// No description provided for @translatedText.
  ///
  /// In en, this message translates to:
  /// **'Translated Text'**
  String get translatedText;

  /// No description provided for @showTranscription.
  ///
  /// In en, this message translates to:
  /// **'Show Transcription'**
  String get showTranscription;

  /// No description provided for @showTranscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display pronunciation guide'**
  String get showTranscriptionSubtitle;

  /// No description provided for @showTranslationFirst.
  ///
  /// In en, this message translates to:
  /// **'Translation First'**
  String get showTranslationFirst;

  /// No description provided for @showTranslationFirstSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show translation before original text'**
  String get showTranslationFirstSubtitle;

  /// No description provided for @italianLang.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italianLang;

  /// No description provided for @portugueseLang.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portugueseLang;

  /// No description provided for @lyricsEditor.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Editor'**
  String get lyricsEditor;

  /// No description provided for @addLine.
  ///
  /// In en, this message translates to:
  /// **'Add Line'**
  String get addLine;

  /// No description provided for @updateLine.
  ///
  /// In en, this message translates to:
  /// **'Update Line'**
  String get updateLine;

  /// No description provided for @deleteLine.
  ///
  /// In en, this message translates to:
  /// **'Delete Line'**
  String get deleteLine;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get moveDown;

  /// No description provided for @autoSyncLyrics.
  ///
  /// In en, this message translates to:
  /// **'Auto Sync Lyrics'**
  String get autoSyncLyrics;

  /// No description provided for @exportLrc.
  ///
  /// In en, this message translates to:
  /// **'Export LRC (Original)'**
  String get exportLrc;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON (Translations)'**
  String get exportJson;

  /// No description provided for @markTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Mark Timestamp (Enter)'**
  String get markTimestamp;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @audioFile.
  ///
  /// In en, this message translates to:
  /// **'Audio File'**
  String get audioFile;

  /// No description provided for @songTitle.
  ///
  /// In en, this message translates to:
  /// **'Song Title'**
  String get songTitle;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @audioControls.
  ///
  /// In en, this message translates to:
  /// **'Audio Controls'**
  String get audioControls;

  /// No description provided for @addEditLine.
  ///
  /// In en, this message translates to:
  /// **'Add/Edit Line'**
  String get addEditLine;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @lyricsEditorInstructions.
  ///
  /// In en, this message translates to:
  /// **'LRC Synchronizer Instructions:\n\n1. Select an audio file using Browse button\n2. Enter song title and artist (optional)\n3. Click Play to start audio\n4. When a line is sung, type original text in \'Original\' field\n5. Press Enter or click \'Mark Timestamp\' to record timestamp\n6. Optionally add a translation in \'Translation\' field\n7. Repeat steps 4-6 for each line\n8. Use \'Export LRC\' to save original lyrics with timestamps\n9. Use \'Export JSON\' to save translations\n\nTips:\n- Use -10s/+10s to navigate quickly through the song\n- You can reorder lines using Move Up/Down\n- Load previously saved JSON files to edit translations'**
  String get lyricsEditorInstructions;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Start your language learning journey with music!'**
  String get welcomeMessage;

  /// No description provided for @importSongs.
  ///
  /// In en, this message translates to:
  /// **'Import Songs'**
  String get importSongs;

  /// No description provided for @importSongsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add audio files from your device'**
  String get importSongsSubtitle;

  /// No description provided for @manageLibrary.
  ///
  /// In en, this message translates to:
  /// **'Manage Library'**
  String get manageLibrary;

  /// No description provided for @manageLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your songs and playlists'**
  String get manageLibrarySubtitle;

  /// No description provided for @syncLyrics.
  ///
  /// In en, this message translates to:
  /// **'Sync Lyrics'**
  String get syncLyrics;

  /// No description provided for @syncLyricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically sync lyrics with audio'**
  String get syncLyricsSubtitle;

  /// No description provided for @languageLearning.
  ///
  /// In en, this message translates to:
  /// **'Language Learning • Music • Translations'**
  String get languageLearning;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developer;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @failedToCreatePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Failed to create playlist: {error}'**
  String failedToCreatePlaylist(Object error);

  /// No description provided for @playlistCreated.
  ///
  /// In en, this message translates to:
  /// **'Playlist created successfully!'**
  String get playlistCreated;

  /// No description provided for @playlistDeleted.
  ///
  /// In en, this message translates to:
  /// **'Playlist deleted successfully!'**
  String get playlistDeleted;

  /// No description provided for @playlistUpdated.
  ///
  /// In en, this message translates to:
  /// **'Playlist updated successfully!'**
  String get playlistUpdated;

  /// No description provided for @songAdded.
  ///
  /// In en, this message translates to:
  /// **'Song added successfully!'**
  String get songAdded;

  /// No description provided for @songRemoved.
  ///
  /// In en, this message translates to:
  /// **'Song removed successfully!'**
  String get songRemoved;

  /// No description provided for @songDeleted.
  ///
  /// In en, this message translates to:
  /// **'Song deleted successfully!'**
  String get songDeleted;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Continue?'**
  String get unsavedChanges;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @englishLang.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLang;

  /// No description provided for @russianLang.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russianLang;

  /// No description provided for @romanianLang.
  ///
  /// In en, this message translates to:
  /// **'Română'**
  String get romanianLang;

  /// No description provided for @frenchLang.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get frenchLang;

  /// No description provided for @germanLang.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get germanLang;

  /// No description provided for @spanishLang.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanishLang;

  /// No description provided for @chineseLang.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chineseLang;

  /// No description provided for @arabicLang.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabicLang;

  /// No description provided for @welcomeToLingoTune.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LingoTune'**
  String get welcomeToLingoTune;

  /// No description provided for @folderSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a folder to store lyrics and translations (LRC and JSON files). This makes it easy to organize your music library.'**
  String get folderSetupMessage;

  /// No description provided for @selectFolderNow.
  ///
  /// In en, this message translates to:
  /// **'Select Folder Now'**
  String get selectFolderNow;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @setupLater.
  ///
  /// In en, this message translates to:
  /// **'Setup Later'**
  String get setupLater;

  /// No description provided for @useDefaultFolder.
  ///
  /// In en, this message translates to:
  /// **'Use Default Folder'**
  String get useDefaultFolder;

  /// No description provided for @databaseFound.
  ///
  /// In en, this message translates to:
  /// **'Database found in import file'**
  String get databaseFound;

  /// No description provided for @importDatabaseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to import the database too?'**
  String get importDatabaseQuestion;

  /// No description provided for @mergeDatabase.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mergeDatabase;

  /// No description provided for @replaceDatabase.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceDatabase;

  /// No description provided for @importDatabase.
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get importDatabase;

  /// No description provided for @skipDatabase.
  ///
  /// In en, this message translates to:
  /// **'Skip Database'**
  String get skipDatabase;

  /// No description provided for @mergeDatabaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Merge imported songs with your library (adds new items only)'**
  String get mergeDatabaseDescription;

  /// No description provided for @replaceDatabaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Replace your entire library with the imported database (you will lose all existing data)'**
  String get replaceDatabaseDescription;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @exportingProgress.
  ///
  /// In en, this message translates to:
  /// **'Exporting {current} of {total} songs'**
  String exportingProgress(Object current, Object total);

  /// No description provided for @exportDatabaseIncluded.
  ///
  /// In en, this message translates to:
  /// **'Database included in export'**
  String get exportDatabaseIncluded;

  /// No description provided for @importSuccessWithDatabase.
  ///
  /// In en, this message translates to:
  /// **'Imported {fileCount} file(s) and database'**
  String importSuccessWithDatabase(Object fileCount);

  /// No description provided for @importSuccessNoDatabase.
  ///
  /// In en, this message translates to:
  /// **'Imported {fileCount} file(s)'**
  String importSuccessNoDatabase(Object fileCount);

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// No description provided for @themeNameAmethyst.
  ///
  /// In en, this message translates to:
  /// **'Amethyst'**
  String get themeNameAmethyst;

  /// No description provided for @themeColorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get themeColorPurple;

  /// No description provided for @themeColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get themeColorBlue;

  /// No description provided for @themeColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get themeColorGreen;

  /// No description provided for @themeColorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get themeColorOrange;

  /// No description provided for @themeColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get themeColorRed;

  /// No description provided for @themeColorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get themeColorPink;

  /// No description provided for @themeColorDeepOrange.
  ///
  /// In en, this message translates to:
  /// **'Deep Orange'**
  String get themeColorDeepOrange;

  /// No description provided for @themeColorDarkRed.
  ///
  /// In en, this message translates to:
  /// **'Dark Red'**
  String get themeColorDarkRed;

  /// No description provided for @themeColorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get themeColorTeal;

  /// No description provided for @themeColorCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get themeColorCyan;

  /// No description provided for @themeColorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get themeColorAmber;

  /// No description provided for @themeColorLime.
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get themeColorLime;

  /// No description provided for @ukrainianLang.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get ukrainianLang;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @fontSettings.
  ///
  /// In en, this message translates to:
  /// **'Font Settings'**
  String get fontSettings;

  /// No description provided for @systemFont.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemFont;

  /// No description provided for @fontRoboto.
  ///
  /// In en, this message translates to:
  /// **'Roboto'**
  String get fontRoboto;

  /// No description provided for @fontOpenSans.
  ///
  /// In en, this message translates to:
  /// **'Open Sans'**
  String get fontOpenSans;

  /// No description provided for @fontLato.
  ///
  /// In en, this message translates to:
  /// **'Lato'**
  String get fontLato;

  /// No description provided for @mainTextSize.
  ///
  /// In en, this message translates to:
  /// **'Main Text Size'**
  String get mainTextSize;

  /// No description provided for @mainTextBold.
  ///
  /// In en, this message translates to:
  /// **'Bold Main Text'**
  String get mainTextBold;

  /// No description provided for @translationSize.
  ///
  /// In en, this message translates to:
  /// **'Translation Size'**
  String get translationSize;

  /// No description provided for @translationBold.
  ///
  /// In en, this message translates to:
  /// **'Bold Translation'**
  String get translationBold;

  /// No description provided for @transcriptSize.
  ///
  /// In en, this message translates to:
  /// **'Transcript Size'**
  String get transcriptSize;

  /// No description provided for @transcriptBold.
  ///
  /// In en, this message translates to:
  /// **'Bold Transcript'**
  String get transcriptBold;

  /// No description provided for @defaultStartScreen.
  ///
  /// In en, this message translates to:
  /// **'Default Start Screen'**
  String get defaultStartScreen;

  /// No description provided for @defaultStartScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Screen to show when app starts'**
  String get defaultStartScreenSubtitle;

  /// No description provided for @addToLibraryWhenAddingToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Library When Adding to Playlist'**
  String get addToLibraryWhenAddingToPlaylist;

  /// No description provided for @addToLibraryWhenAddingToPlaylistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically add songs to library when added to a playlist'**
  String get addToLibraryWhenAddingToPlaylistSubtitle;

  /// No description provided for @serviceMessages.
  ///
  /// In en, this message translates to:
  /// **'Service Messages'**
  String get serviceMessages;

  /// No description provided for @serviceMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show service notifications about translation and transcription'**
  String get serviceMessagesSubtitle;

  /// No description provided for @serviceData.
  ///
  /// In en, this message translates to:
  /// **'Service Data'**
  String get serviceData;

  /// No description provided for @serviceDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show diagnostic overlay in study mode'**
  String get serviceDataSubtitle;

  /// No description provided for @ttsEngine.
  ///
  /// In en, this message translates to:
  /// **'TTS Engine'**
  String get ttsEngine;

  /// No description provided for @ttsEngineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No TTS engines detected — the app may not see system speech engines.'**
  String get ttsEngineSubtitle;

  /// No description provided for @ttsEngineAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (recommended)'**
  String get ttsEngineAuto;

  /// No description provided for @ttsEngineReloadHint.
  ///
  /// In en, this message translates to:
  /// **'Engine changed — takes effect on next study session'**
  String get ttsEngineReloadHint;

  /// No description provided for @includeMp3Files.
  ///
  /// In en, this message translates to:
  /// **'Include MP3 files'**
  String get includeMp3Files;

  /// No description provided for @includeMp3FilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will increase the archive size'**
  String get includeMp3FilesSubtitle;

  /// No description provided for @importMp3Files.
  ///
  /// In en, this message translates to:
  /// **'Import MP3 files'**
  String get importMp3Files;

  /// No description provided for @importMp3FilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add music files to library'**
  String get importMp3FilesSubtitle;

  /// No description provided for @exportSongs.
  ///
  /// In en, this message translates to:
  /// **'Export Songs'**
  String get exportSongs;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @addMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select multiple'**
  String get addMultiple;

  /// No description provided for @addToPlaylistShort.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToPlaylistShort;

  /// No description provided for @deleteShort.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteShort;

  /// No description provided for @selectAllShort.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get selectAllShort;

  /// No description provided for @deselectAllShort.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get deselectAllShort;

  /// No description provided for @exitSelectionMode.
  ///
  /// In en, this message translates to:
  /// **'Exit selection mode'**
  String get exitSelectionMode;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @addMultipleToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addMultipleToPlaylist;

  /// No description provided for @coverArt.
  ///
  /// In en, this message translates to:
  /// **'Cover Art'**
  String get coverArt;

  /// No description provided for @playlistCover.
  ///
  /// In en, this message translates to:
  /// **'Playlist Cover'**
  String get playlistCover;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @removeCover.
  ///
  /// In en, this message translates to:
  /// **'Remove Cover'**
  String get removeCover;

  /// No description provided for @coverUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cover updated'**
  String get coverUpdated;

  /// No description provided for @coverRemoved.
  ///
  /// In en, this message translates to:
  /// **'Cover removed'**
  String get coverRemoved;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(Object error);

  /// No description provided for @importFolders.
  ///
  /// In en, this message translates to:
  /// **'Import Folders'**
  String get importFolders;

  /// No description provided for @selectMusicFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Music Folder'**
  String get selectMusicFolder;

  /// No description provided for @folderWithAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'Folder with MP3/WAV files'**
  String get folderWithAudioFiles;

  /// No description provided for @sameFolderForLyrics.
  ///
  /// In en, this message translates to:
  /// **'Same folder for lyrics'**
  String get sameFolderForLyrics;

  /// No description provided for @selectLyricsFolder.
  ///
  /// In en, this message translates to:
  /// **'Select Lyrics Folder'**
  String get selectLyricsFolder;

  /// No description provided for @folderWithLyricsFiles.
  ///
  /// In en, this message translates to:
  /// **'Folder with LRC/JSON files (optional)'**
  String get folderWithLyricsFiles;

  /// No description provided for @pleaseEnterPlaylistName.
  ///
  /// In en, this message translates to:
  /// **'Please enter playlist name'**
  String get pleaseEnterPlaylistName;

  /// No description provided for @pleaseSelectMusicFolder.
  ///
  /// In en, this message translates to:
  /// **'Please select music folder'**
  String get pleaseSelectMusicFolder;

  /// No description provided for @cropImage.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropImage;

  /// No description provided for @photoPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo access permission required'**
  String get photoPermissionRequired;

  /// No description provided for @photoPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo access denied'**
  String get photoPermissionDenied;

  /// No description provided for @imageProcessingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image'**
  String get imageProcessingError;

  /// No description provided for @scanningFolder.
  ///
  /// In en, this message translates to:
  /// **'Scanning folder...'**
  String get scanningFolder;

  /// No description provided for @importingFiles.
  ///
  /// In en, this message translates to:
  /// **'Importing files...'**
  String get importingFiles;

  /// No description provided for @importingFolderProgress.
  ///
  /// In en, this message translates to:
  /// **'Importing {current}/{total} files... Found {songs} songs'**
  String importingFolderProgress(Object current, Object songs, Object total);

  /// No description provided for @processingFile.
  ///
  /// In en, this message translates to:
  /// **'Processing {file}...'**
  String processingFile(Object file);

  /// No description provided for @addToPlaylistDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addToPlaylistDialogTitle;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to \"{playlist}\"'**
  String addedToPlaylist(Object playlist);

  /// No description provided for @failedToAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to playlist: {error}'**
  String failedToAddToPlaylist(Object error);

  /// No description provided for @deleteSong.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteSong;

  /// No description provided for @importSongDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Song'**
  String get importSongDialogTitle;

  /// No description provided for @audioOnly.
  ///
  /// In en, this message translates to:
  /// **'Audio only'**
  String get audioOnly;

  /// No description provided for @addLyricsLater.
  ///
  /// In en, this message translates to:
  /// **'I will add lyrics later'**
  String get addLyricsLater;

  /// No description provided for @audioWithLyricsZIP.
  ///
  /// In en, this message translates to:
  /// **'Audio + Lyrics ZIP'**
  String get audioWithLyricsZIP;

  /// No description provided for @importWithAllTranslations.
  ///
  /// In en, this message translates to:
  /// **'Import with all translations'**
  String get importWithAllTranslations;

  /// No description provided for @importTranslationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Translation'**
  String get importTranslationDialogTitle;

  /// No description provided for @loadTranslationFromZip.
  ///
  /// In en, this message translates to:
  /// **'Load from ZIP archive'**
  String get loadTranslationFromZip;

  /// No description provided for @loadTranslationFromJson.
  ///
  /// In en, this message translates to:
  /// **'Load from JSON file'**
  String get loadTranslationFromJson;

  /// No description provided for @noAudioFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'No audio files selected'**
  String get noAudioFilesSelected;

  /// No description provided for @failedToImportSongs.
  ///
  /// In en, this message translates to:
  /// **'Failed to import songs: {error}'**
  String failedToImportSongs(Object error);

  /// No description provided for @failedToImportSong.
  ///
  /// In en, this message translates to:
  /// **'Failed to import song: {error}'**
  String failedToImportSong(Object error);

  /// No description provided for @musicFolderNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Music folder not selected'**
  String get musicFolderNotSelected;

  /// No description provided for @generateLyrics.
  ///
  /// In en, this message translates to:
  /// **'Generate Lyrics'**
  String get generateLyrics;

  /// No description provided for @selectTextFileOrEnterText.
  ///
  /// In en, this message translates to:
  /// **'Select text file or enter text'**
  String get selectTextFileOrEnterText;

  /// No description provided for @originalLanguage.
  ///
  /// In en, this message translates to:
  /// **'Original language'**
  String get originalLanguage;

  /// No description provided for @translationLanguages.
  ///
  /// In en, this message translates to:
  /// **'Translation languages'**
  String get translationLanguages;

  /// No description provided for @startMinuteForTimestamps.
  ///
  /// In en, this message translates to:
  /// **'Start minute for timestamps'**
  String get startMinuteForTimestamps;

  /// No description provided for @transcriptionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Transcription language'**
  String get transcriptionLanguage;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @deepseekApiKey.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek API Key'**
  String get deepseekApiKey;

  /// No description provided for @validateKey.
  ///
  /// In en, this message translates to:
  /// **'Validate key'**
  String get validateKey;

  /// No description provided for @keyIsValid.
  ///
  /// In en, this message translates to:
  /// **'Key is valid'**
  String get keyIsValid;

  /// No description provided for @keyIsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Key is invalid'**
  String get keyIsInvalid;

  /// No description provided for @lyricsGenerationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Lyrics generated successfully'**
  String get lyricsGenerationSuccess;

  /// No description provided for @lyricsGenerationError.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate lyrics'**
  String get lyricsGenerationError;

  /// No description provided for @savingFiles.
  ///
  /// In en, this message translates to:
  /// **'Saving files...'**
  String get savingFiles;

  /// No description provided for @enterText.
  ///
  /// In en, this message translates to:
  /// **'Enter text'**
  String get enterText;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @originalTextEditable.
  ///
  /// In en, this message translates to:
  /// **'Original Text (editable)'**
  String get originalTextEditable;

  /// No description provided for @selectLanguageToEdit.
  ///
  /// In en, this message translates to:
  /// **'Select language to edit'**
  String get selectLanguageToEdit;

  /// No description provided for @moveLineUp.
  ///
  /// In en, this message translates to:
  /// **'Move line up'**
  String get moveLineUp;

  /// No description provided for @moveLineDown.
  ///
  /// In en, this message translates to:
  /// **'Move line down'**
  String get moveLineDown;

  /// No description provided for @moveAllTranslationsUp.
  ///
  /// In en, this message translates to:
  /// **'Move all translations up'**
  String get moveAllTranslationsUp;

  /// No description provided for @moveAllTranslationsDown.
  ///
  /// In en, this message translates to:
  /// **'Move all translations down'**
  String get moveAllTranslationsDown;

  /// No description provided for @translationSaved.
  ///
  /// In en, this message translates to:
  /// **'Translation saved!'**
  String get translationSaved;

  /// No description provided for @translationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save translation'**
  String get translationSaveFailed;

  /// No description provided for @loadTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Load Text'**
  String get loadTextTitle;

  /// No description provided for @noOriginalTextWarning.
  ///
  /// In en, this message translates to:
  /// **'Please load original text first'**
  String get noOriginalTextWarning;

  /// No description provided for @selectLanguageOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original language'**
  String get selectLanguageOriginal;

  /// No description provided for @startTimestampMinutes.
  ///
  /// In en, this message translates to:
  /// **'Start timestamp (minutes)'**
  String get startTimestampMinutes;

  /// No description provided for @selectLanguageTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation language'**
  String get selectLanguageTranslation;

  /// No description provided for @originalTextLoaded.
  ///
  /// In en, this message translates to:
  /// **'Original text loaded successfully!'**
  String get originalTextLoaded;

  /// No description provided for @translationLoaded.
  ///
  /// In en, this message translates to:
  /// **'Translation loaded successfully!'**
  String get translationLoaded;

  /// No description provided for @transcriptLoaded.
  ///
  /// In en, this message translates to:
  /// **'Transcript loaded successfully!'**
  String get transcriptLoaded;

  /// No description provided for @selectTranslationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Translation language for transcript'**
  String get selectTranslationLanguage;

  /// No description provided for @noTranslationWarning.
  ///
  /// In en, this message translates to:
  /// **'No translations loaded'**
  String get noTranslationWarning;

  /// No description provided for @linesMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Lines mismatch: {loaded} lines, expected {expected}'**
  String linesMismatchError(Object expected, Object loaded);

  /// No description provided for @loadTextTooltip.
  ///
  /// In en, this message translates to:
  /// **'Load text or translation'**
  String get loadTextTooltip;

  /// No description provided for @loadFromFile.
  ///
  /// In en, this message translates to:
  /// **'Load from file'**
  String get loadFromFile;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @audioNotificationService.
  ///
  /// In en, this message translates to:
  /// **'Audio Notification Service'**
  String get audioNotificationService;

  /// No description provided for @audioNotificationServiceActive.
  ///
  /// In en, this message translates to:
  /// **'Status: ✅ Active'**
  String get audioNotificationServiceActive;

  /// No description provided for @audioNotificationServiceError.
  ///
  /// In en, this message translates to:
  /// **'Status: ❌ Error'**
  String get audioNotificationServiceError;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorLabel;

  /// No description provided for @audioNotificationServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'This service provides notifications when app is minimized'**
  String get audioNotificationServiceDescription;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selectMultiple.
  ///
  /// In en, this message translates to:
  /// **'Select multiple'**
  String get selectMultiple;

  /// No description provided for @sortSongs.
  ///
  /// In en, this message translates to:
  /// **'Sort songs'**
  String get sortSongs;

  /// No description provided for @importSong.
  ///
  /// In en, this message translates to:
  /// **'Import Song'**
  String get importSong;

  /// No description provided for @sortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get sortDefault;

  /// No description provided for @sortAlphabeticalAsc.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAlphabeticalAsc;

  /// No description provided for @sortAlphabeticalDesc.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get sortAlphabeticalDesc;

  /// No description provided for @sortDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortDateDesc;

  /// No description provided for @sortDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortDateAsc;

  /// No description provided for @importingSongs.
  ///
  /// In en, this message translates to:
  /// **'Importing songs...'**
  String get importingSongs;

  /// No description provided for @noSongsInPlaylist.
  ///
  /// In en, this message translates to:
  /// **'No songs in this playlist'**
  String get noSongsInPlaylist;

  /// No description provided for @addSongsFromLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Add songs from your library'**
  String get addSongsFromLibraryHint;

  /// No description provided for @removedSongsFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Removed songs from playlist'**
  String get removedSongsFromPlaylist;

  /// No description provided for @failedToRemoveSongs.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete songs: {error}'**
  String failedToRemoveSongs(Object error);

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Playlist'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{playlist}\"?'**
  String deletePlaylistConfirm(Object playlist);

  /// No description provided for @failedToDeletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete playlist:'**
  String get failedToDeletePlaylist;

  /// No description provided for @specifyTranslationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Specify translation language'**
  String get specifyTranslationLanguage;

  /// No description provided for @languageNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Language name'**
  String get languageNameLabel;

  /// No description provided for @languageNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Russian, Author\'s, Poetic'**
  String get languageNameHint;

  /// No description provided for @translationTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation type:'**
  String get translationTypeLabel;

  /// No description provided for @translationTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get translationTypeNormal;

  /// No description provided for @translationTypeAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author\'s'**
  String get translationTypeAuthor;

  /// No description provided for @translationTypePoetic.
  ///
  /// In en, this message translates to:
  /// **'Poetic'**
  String get translationTypePoetic;

  /// No description provided for @translationTypeLiteral.
  ///
  /// In en, this message translates to:
  /// **'Literal'**
  String get translationTypeLiteral;

  /// No description provided for @mp3FilesCount.
  ///
  /// In en, this message translates to:
  /// **'MP3 files: {count}'**
  String mp3FilesCount(Object count);

  /// No description provided for @importedFilesWithSkippedDatabase.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} file(s) (database skipped)'**
  String importedFilesWithSkippedDatabase(Object count);

  /// No description provided for @databaseMerged.
  ///
  /// In en, this message translates to:
  /// **'Database merged'**
  String get databaseMerged;

  /// No description provided for @databaseMergedWithMp3.
  ///
  /// In en, this message translates to:
  /// **'Database merged, MP3 files: {count}'**
  String databaseMergedWithMp3(Object count);

  /// No description provided for @databaseReplaced.
  ///
  /// In en, this message translates to:
  /// **'Database replaced'**
  String get databaseReplaced;

  /// No description provided for @databaseReplacedWithMp3.
  ///
  /// In en, this message translates to:
  /// **'Database replaced, MP3 files: {count}'**
  String databaseReplacedWithMp3(Object count);

  /// No description provided for @confirmReplaceDatabase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Replace'**
  String get confirmReplaceDatabase;

  /// No description provided for @confirmReplaceDatabaseWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? You will lose all existing songs and playlists!'**
  String get confirmReplaceDatabaseWarning;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get replaceAll;

  /// No description provided for @selectLanguages.
  ///
  /// In en, this message translates to:
  /// **'Select languages'**
  String get selectLanguages;

  /// No description provided for @selectedLanguagesCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count} languages'**
  String selectedLanguagesCount(Object count);

  /// No description provided for @selectedSongsCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String selectedSongsCount(Object count);

  /// No description provided for @promptPreset.
  ///
  /// In en, this message translates to:
  /// **'Prompt Preset'**
  String get promptPreset;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @poetic.
  ///
  /// In en, this message translates to:
  /// **'Poetic'**
  String get poetic;

  /// No description provided for @literal.
  ///
  /// In en, this message translates to:
  /// **'Literal'**
  String get literal;

  /// No description provided for @customPromptOption.
  ///
  /// In en, this message translates to:
  /// **'Custom...'**
  String get customPromptOption;

  /// No description provided for @editPrompt.
  ///
  /// In en, this message translates to:
  /// **'Edit Prompt'**
  String get editPrompt;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @showOrEditApiKey.
  ///
  /// In en, this message translates to:
  /// **'Show/Edit API key'**
  String get showOrEditApiKey;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get timeout;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @resetToPreset.
  ///
  /// In en, this message translates to:
  /// **'Reset to preset'**
  String get resetToPreset;

  /// No description provided for @customPrompt.
  ///
  /// In en, this message translates to:
  /// **'Custom prompt'**
  String get customPrompt;

  /// No description provided for @customPromptChars.
  ///
  /// In en, this message translates to:
  /// **'Custom prompt ({count} chars)'**
  String customPromptChars(Object count);

  /// No description provided for @usingPreset.
  ///
  /// In en, this message translates to:
  /// **'Using preset: {preset}'**
  String usingPreset(Object preset);

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'characters'**
  String get characters;

  /// No description provided for @deepSeekPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'DeepSeek Prompt'**
  String get deepSeekPromptTitle;

  /// No description provided for @customPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Prompt'**
  String get customPromptLabel;

  /// No description provided for @leaveEmptyToUseDefault.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use default prompt'**
  String get leaveEmptyToUseDefault;

  /// No description provided for @leaveEmptyToUseDefaultPrompt.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use the default prompt built into the app'**
  String get leaveEmptyToUseDefaultPrompt;

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API key saved'**
  String get apiKeySaved;

  /// No description provided for @enterTimeout.
  ///
  /// In en, this message translates to:
  /// **'Enter timeout in seconds'**
  String get enterTimeout;

  /// No description provided for @validTimeoutRange.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid timeout (1-3600 seconds)'**
  String get validTimeoutRange;

  /// No description provided for @customTimeout.
  ///
  /// In en, this message translates to:
  /// **'Custom Timeout'**
  String get customTimeout;

  /// No description provided for @timeoutSeconds.
  ///
  /// In en, this message translates to:
  /// **'Timeout (seconds)'**
  String get timeoutSeconds;

  /// No description provided for @timeoutSetTo.
  ///
  /// In en, this message translates to:
  /// **'Timeout set to {value} seconds'**
  String timeoutSetTo(Object value);

  /// No description provided for @customModel.
  ///
  /// In en, this message translates to:
  /// **'Custom Model'**
  String get customModel;

  /// No description provided for @modelName.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelName;

  /// No description provided for @enterModelName.
  ///
  /// In en, this message translates to:
  /// **'Enter the exact model name as provided by DeepSeek API'**
  String get enterModelName;

  /// No description provided for @pleaseEnterModelName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a model name'**
  String get pleaseEnterModelName;

  /// No description provided for @modelSetTo.
  ///
  /// In en, this message translates to:
  /// **'Model set to {value}'**
  String modelSetTo(Object value);

  /// No description provided for @editCustomPrompt.
  ///
  /// In en, this message translates to:
  /// **'Edit Custom Prompt'**
  String get editCustomPrompt;

  /// No description provided for @editPresetPrompt.
  ///
  /// In en, this message translates to:
  /// **'Edit Preset Prompt'**
  String get editPresetPrompt;

  /// No description provided for @editingPreset.
  ///
  /// In en, this message translates to:
  /// **'Editing Preset'**
  String get editingPreset;

  /// No description provided for @anyChangesSaveAsCustom.
  ///
  /// In en, this message translates to:
  /// **'Any changes will save as a custom prompt. Use \'Reset\' button to restore the original preset.'**
  String get anyChangesSaveAsCustom;

  /// No description provided for @useResetToRestorePreset.
  ///
  /// In en, this message translates to:
  /// **'Use \'Reset\' button to restore the original preset'**
  String get useResetToRestorePreset;

  /// No description provided for @prompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get prompt;

  /// No description provided for @promptSaved.
  ///
  /// In en, this message translates to:
  /// **'Prompt saved'**
  String get promptSaved;

  /// No description provided for @usingPresetPrompt.
  ///
  /// In en, this message translates to:
  /// **'Using preset prompt'**
  String get usingPresetPrompt;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKeyHint;

  /// No description provided for @modelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. deepseek-v3'**
  String get modelHint;

  /// No description provided for @enterExactModelName.
  ///
  /// In en, this message translates to:
  /// **'Enter the exact model name as provided by DeepSeek API.'**
  String get enterExactModelName;

  /// No description provided for @pleaseEnterApiKeyFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter API key first'**
  String get pleaseEnterApiKeyFirst;

  /// No description provided for @maxTokensRegular.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens (Regular)'**
  String get maxTokensRegular;

  /// No description provided for @maxTokensJson.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens (JSON)'**
  String get maxTokensJson;

  /// No description provided for @maxTokensRegularHint.
  ///
  /// In en, this message translates to:
  /// **'Token limit for regular translation requests'**
  String get maxTokensRegularHint;

  /// No description provided for @maxTokensJsonHint.
  ///
  /// In en, this message translates to:
  /// **'Token limit for full generation (JSON) requests'**
  String get maxTokensJsonHint;

  /// No description provided for @maxTokensRegularSetTo.
  ///
  /// In en, this message translates to:
  /// **'Max tokens (regular) set to {value}'**
  String maxTokensRegularSetTo(Object value);

  /// No description provided for @maxTokensJsonSetTo.
  ///
  /// In en, this message translates to:
  /// **'Max tokens (JSON) set to {value}'**
  String maxTokensJsonSetTo(Object value);

  /// No description provided for @refreshFolder.
  ///
  /// In en, this message translates to:
  /// **'Refresh Folder'**
  String get refreshFolder;

  /// No description provided for @refreshingFolder.
  ///
  /// In en, this message translates to:
  /// **'Refreshing folder...'**
  String get refreshingFolder;

  /// No description provided for @playlistCreatedWithLink.
  ///
  /// In en, this message translates to:
  /// **'Playlist created! Press \"Refresh\" to load songs from folder'**
  String get playlistCreatedWithLink;

  /// No description provided for @refreshedPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Refreshed: {count} songs'**
  String refreshedPlaylist(Object count);

  /// No description provided for @refreshPlaylistError.
  ///
  /// In en, this message translates to:
  /// **'Refresh error: {error}'**
  String refreshPlaylistError(Object error);

  /// No description provided for @failedToLoadSongs.
  ///
  /// In en, this message translates to:
  /// **'Failed to load songs: {error}'**
  String failedToLoadSongs(Object error);

  /// No description provided for @musicFolderDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Music folder does not exist'**
  String get musicFolderDoesNotExist;

  /// No description provided for @successfullyImportedSongs.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {count} song(s)'**
  String successfullyImportedSongs(Object count);

  /// No description provided for @noAudioFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No audio file selected'**
  String get noAudioFileSelected;

  /// No description provided for @noZipArchiveSelected.
  ///
  /// In en, this message translates to:
  /// **'No ZIP archive selected'**
  String get noZipArchiveSelected;

  /// No description provided for @noFolderConfigured.
  ///
  /// In en, this message translates to:
  /// **'No folder configured'**
  String get noFolderConfigured;

  /// No description provided for @missingLyricsTranslations.
  ///
  /// In en, this message translates to:
  /// **'Missing Lyrics/Translations'**
  String get missingLyricsTranslations;

  /// No description provided for @missingForSong.
  ///
  /// In en, this message translates to:
  /// **'For \"{songName}\"'**
  String missingForSong(Object songName);

  /// No description provided for @missingFilesList.
  ///
  /// In en, this message translates to:
  /// **'Missing: {files}'**
  String missingFilesList(Object files);

  /// No description provided for @whatWouldYouLikeToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// No description provided for @lyricsGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Lyrics generated successfully'**
  String get lyricsGeneratedSuccessfully;

  /// No description provided for @setDeepSeekApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please set DeepSeek API key in settings'**
  String get setDeepSeekApiKey;

  /// No description provided for @failedToOpenSong.
  ///
  /// In en, this message translates to:
  /// **'Failed to open song: {error}'**
  String failedToOpenSong(Object error);

  /// No description provided for @alsoDeleteLrcJsonFiles.
  ///
  /// In en, this message translates to:
  /// **'Also delete LRC and JSON files'**
  String get alsoDeleteLrcJsonFiles;

  /// No description provided for @addedToPlaylistWithQuotes.
  ///
  /// In en, this message translates to:
  /// **'Added to \"{playlist}\"'**
  String addedToPlaylistWithQuotes(Object playlist);

  /// No description provided for @failedToAddToPlaylistError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to playlist: {error}'**
  String failedToAddToPlaylistError(Object error);

  /// No description provided for @exportedSongsCount.
  ///
  /// In en, this message translates to:
  /// **'Exported {count} songs'**
  String exportedSongsCount(Object count);

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @selectZipFileNotJson.
  ///
  /// In en, this message translates to:
  /// **'Please select a ZIP file, not JSON or LRC'**
  String get selectZipFileNotJson;

  /// No description provided for @noFilesFoundInZip.
  ///
  /// In en, this message translates to:
  /// **'No files found in ZIP'**
  String get noFilesFoundInZip;

  /// No description provided for @invalidZipFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid ZIP file format: {error}'**
  String invalidZipFileFormat(Object error);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(Object error);

  /// No description provided for @foundTranslationsCount.
  ///
  /// In en, this message translates to:
  /// **'Found {count} translation(s)'**
  String foundTranslationsCount(Object count);

  /// No description provided for @mp3ImportError.
  ///
  /// In en, this message translates to:
  /// **'MP3 import error: {error}'**
  String mp3ImportError(Object error);

  /// No description provided for @importSongFirstToSearch.
  ///
  /// In en, this message translates to:
  /// **'Import a song first to search for lyrics'**
  String get importSongFirstToSearch;

  /// No description provided for @lyricsFetched.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Fetched'**
  String get lyricsFetched;

  /// No description provided for @lyricsFoundUseCreate.
  ///
  /// In en, this message translates to:
  /// **'Lyrics found! Use to create a synchronized LRC file'**
  String get lyricsFoundUseCreate;

  /// No description provided for @deleteSelectedSongs.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Songs'**
  String get deleteSelectedSongs;

  /// No description provided for @deleteMultipleSongsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} song(s)?'**
  String deleteMultipleSongsConfirm(Object count);

  /// No description provided for @songsDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Songs deleted successfully'**
  String get songsDeletedSuccessfully;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to access folders.'**
  String get storagePermissionRequired;

  /// No description provided for @enableStoragePermission.
  ///
  /// In en, this message translates to:
  /// **'Please enable storage permission in app settings.'**
  String get enableStoragePermission;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @unableToSelectFolder.
  ///
  /// In en, this message translates to:
  /// **'Unable to select folder. Please try alternative:'**
  String get unableToSelectFolder;

  /// No description provided for @selectFilesInstead.
  ///
  /// In en, this message translates to:
  /// **'Select Files Instead'**
  String get selectFilesInstead;

  /// No description provided for @enterFolderPath.
  ///
  /// In en, this message translates to:
  /// **'Please enter a folder path'**
  String get enterFolderPath;

  /// No description provided for @folderDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'✗ Folder does not exist'**
  String get folderDoesNotExist;

  /// No description provided for @folderSetWithPath.
  ///
  /// In en, this message translates to:
  /// **'Folder set: {path}'**
  String folderSetWithPath(Object path);

  /// No description provided for @errorSettingFolder.
  ///
  /// In en, this message translates to:
  /// **'Error setting folder: {error}'**
  String errorSettingFolder(Object error);

  /// No description provided for @unableToSelectLyricsFolder.
  ///
  /// In en, this message translates to:
  /// **'Unable to select lyrics folder. Please try alternative:'**
  String get unableToSelectLyricsFolder;

  /// No description provided for @useManualPath.
  ///
  /// In en, this message translates to:
  /// **'Use manual path (for testing)'**
  String get useManualPath;

  /// No description provided for @enterFolderPathManually.
  ///
  /// In en, this message translates to:
  /// **'Enter folder path manually instead of using folder picker'**
  String get enterFolderPathManually;

  /// No description provided for @folderPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder Path'**
  String get folderPathLabel;

  /// No description provided for @folderPathHint.
  ///
  /// In en, this message translates to:
  /// **'Example: /storage/emulated/0/Music'**
  String get folderPathHint;

  /// No description provided for @fullPathToMusicFolder.
  ///
  /// In en, this message translates to:
  /// **'Full path to your music folder'**
  String get fullPathToMusicFolder;

  /// No description provided for @setPath.
  ///
  /// In en, this message translates to:
  /// **'Set Path'**
  String get setPath;

  /// No description provided for @selectZipArchiveWithLyrics.
  ///
  /// In en, this message translates to:
  /// **'Select ZIP archive with lyrics for \"{title}\"'**
  String selectZipArchiveWithLyrics(Object title);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @failedToCopyLrcFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy LRC file'**
  String get failedToCopyLrcFile;

  /// No description provided for @copiedJsonFiles.
  ///
  /// In en, this message translates to:
  /// **'Copied {count} JSON file(s)'**
  String copiedJsonFiles(Object count);

  /// No description provided for @failedToCopyJsonFiles.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy JSON files'**
  String get failedToCopyJsonFiles;

  /// No description provided for @failedToDeleteSong.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete song: {error}'**
  String failedToDeleteSong(Object error);

  /// No description provided for @addedMultipleSongsToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added {count} song(s) to \"{playlist}\"'**
  String addedMultipleSongsToPlaylist(Object count, Object playlist);

  /// No description provided for @addMultipleSongsToPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Add {count} song(s) to Playlist'**
  String addMultipleSongsToPlaylistTitle(Object count);

  /// No description provided for @failedToExportSongs.
  ///
  /// In en, this message translates to:
  /// **'Failed to export songs'**
  String get failedToExportSongs;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @deleteSongConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{song}\"?'**
  String deleteSongConfirm(Object song);

  /// No description provided for @selectMusicFolderForPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Select music folder for this playlist'**
  String get selectMusicFolderForPlaylist;

  /// No description provided for @folderLinkedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Folder linked to playlist'**
  String get folderLinkedToPlaylist;

  /// No description provided for @folderUnlinkedFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Folder unlinked from playlist'**
  String get folderUnlinkedFromPlaylist;

  /// No description provided for @checkFolderAccess.
  ///
  /// In en, this message translates to:
  /// **'Check Folder Access'**
  String get checkFolderAccess;

  /// No description provided for @checkingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Checking permissions...'**
  String get checkingPermissions;

  /// No description provided for @folderAccessible.
  ///
  /// In en, this message translates to:
  /// **'✓ Folder accessible'**
  String get folderAccessible;

  /// No description provided for @folderNotAccessible.
  ///
  /// In en, this message translates to:
  /// **'✗ Folder not accessible'**
  String get folderNotAccessible;

  /// No description provided for @audioFilesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} audio file(s) found'**
  String audioFilesFound(Object count);

  /// No description provided for @lyricsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} lyrics file(s) found'**
  String lyricsFound(Object count);

  /// No description provided for @noAudioFiles.
  ///
  /// In en, this message translates to:
  /// **'No audio files found'**
  String get noAudioFiles;

  /// No description provided for @noLyricsFiles.
  ///
  /// In en, this message translates to:
  /// **'No lyrics files found'**
  String get noLyricsFiles;

  /// No description provided for @errorCheckingAccess.
  ///
  /// In en, this message translates to:
  /// **'Error checking folder access: {error}'**
  String errorCheckingAccess(Object error);

  /// No description provided for @folderPathColon.
  ///
  /// In en, this message translates to:
  /// **'Folder path:'**
  String get folderPathColon;

  /// No description provided for @permissionsStatus.
  ///
  /// In en, this message translates to:
  /// **'Permissions status:'**
  String get permissionsStatus;

  /// No description provided for @folderContent.
  ///
  /// In en, this message translates to:
  /// **'Folder content:'**
  String get folderContent;

  /// No description provided for @accessGranted.
  ///
  /// In en, this message translates to:
  /// **'✓ Access granted'**
  String get accessGranted;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'✗ Access denied'**
  String get accessDenied;

  /// No description provided for @permissionRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to request permissions'**
  String get permissionRequestFailed;

  /// No description provided for @pleaseGrantPermissions.
  ///
  /// In en, this message translates to:
  /// **'Please grant storage permissions to check folder access'**
  String get pleaseGrantPermissions;

  /// No description provided for @refreshOnlySongs.
  ///
  /// In en, this message translates to:
  /// **'Only songs'**
  String get refreshOnlySongs;

  /// No description provided for @refreshEverything.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get refreshEverything;

  /// No description provided for @refreshDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'What would you like to update? \"Only songs\" speeds up process by skipping lyrics.'**
  String get refreshDialogDescription;

  /// No description provided for @mostSongs.
  ///
  /// In en, this message translates to:
  /// **'Most Songs'**
  String get mostSongs;

  /// No description provided for @playlistPlay.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistPlay;

  /// No description provided for @musicNote.
  ///
  /// In en, this message translates to:
  /// **'Music Note'**
  String get musicNote;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @libraryMusic.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryMusic;

  /// No description provided for @tapToSelectFolder.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a folder with audio files'**
  String get tapToSelectFolder;

  /// No description provided for @showVerticalSlider.
  ///
  /// In en, this message translates to:
  /// **'Show Vertical Slider'**
  String get showVerticalSlider;

  /// No description provided for @showVerticalSliderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display vertical focus offset slider in player'**
  String get showVerticalSliderSubtitle;

  /// No description provided for @transcriptionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Transcription enabled'**
  String get transcriptionEnabled;

  /// No description provided for @transcriptionDisabled.
  ///
  /// In en, this message translates to:
  /// **'Transcription disabled'**
  String get transcriptionDisabled;

  /// No description provided for @languageSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected language: {language}'**
  String languageSelected(String language);

  /// No description provided for @noTranslationsScanning.
  ///
  /// In en, this message translates to:
  /// **'No translations found, scanning folder...'**
  String get noTranslationsScanning;

  /// No description provided for @translationsLoadedCount.
  ///
  /// In en, this message translates to:
  /// **'Loaded translations: {count}'**
  String translationsLoadedCount(int count);

  /// No description provided for @translationsNotFound.
  ///
  /// In en, this message translates to:
  /// **'No translations found for this song'**
  String get translationsNotFound;

  /// No description provided for @errorLoadingTranslations.
  ///
  /// In en, this message translates to:
  /// **'Error loading translations: {error}'**
  String errorLoadingTranslations(String error);

  /// No description provided for @languageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'{settingLang} selected in settings but not available. Opening: {availableLang}'**
  String languageNotAvailable(String settingLang, String availableLang);

  /// No description provided for @errorAudioService.
  ///
  /// In en, this message translates to:
  /// **'Audio Service Error'**
  String get errorAudioService;

  /// No description provided for @audioServiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize background audio playback.'**
  String get audioServiceFailed;

  /// No description provided for @notificationMayNotAppear.
  ///
  /// In en, this message translates to:
  /// **'Player notification may not appear.'**
  String get notificationMayNotAppear;

  /// No description provided for @lrcAndTranslationsSaved.
  ///
  /// In en, this message translates to:
  /// **'LRC and all translations saved!'**
  String get lrcAndTranslationsSaved;

  /// No description provided for @translationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Translation \"{name}\" deleted'**
  String translationDeleted(String name);

  /// No description provided for @failedToDeleteTranslation.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete translation: {error}'**
  String failedToDeleteTranslation(String error);

  /// No description provided for @generatingTranslations.
  ///
  /// In en, this message translates to:
  /// **'Generating translations'**
  String get generatingTranslations;

  /// No description provided for @generatingProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing:'**
  String get generatingProcessing;

  /// No description provided for @generatingLines.
  ///
  /// In en, this message translates to:
  /// **'Lines:'**
  String get generatingLines;

  /// No description provided for @generatingLinesOf.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String generatingLinesOf(int current, int total);

  /// No description provided for @generatingErrors.
  ///
  /// In en, this message translates to:
  /// **'Errors: {count}'**
  String generatingErrors(int count);

  /// No description provided for @selectedLanguagesCountGen.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String selectedLanguagesCountGen(int count);

  /// No description provided for @transcriptionSection.
  ///
  /// In en, this message translates to:
  /// **'Transcription'**
  String get transcriptionSection;

  /// No description provided for @translationsSection.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translationsSection;

  /// No description provided for @translationLoadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Translation loaded successfully!'**
  String get translationLoadedSuccess;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Export successful!'**
  String get exportSuccessful;

  /// No description provided for @failedToExportSong.
  ///
  /// In en, this message translates to:
  /// **'Failed to export song'**
  String get failedToExportSong;

  /// No description provided for @deleteTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Translation'**
  String get deleteTranslationTitle;

  /// No description provided for @deleteTranslationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the \"{name}\" translation?'**
  String deleteTranslationConfirm(String name);

  /// No description provided for @lrcLoaded.
  ///
  /// In en, this message translates to:
  /// **'LRC file loaded'**
  String get lrcLoaded;

  /// No description provided for @noFilesLoaded.
  ///
  /// In en, this message translates to:
  /// **'No files loaded from archive'**
  String get noFilesLoaded;

  /// No description provided for @failedToProcessArchive.
  ///
  /// In en, this message translates to:
  /// **'Failed to process archive: {error}'**
  String failedToProcessArchive(String error);

  /// No description provided for @failedToLoadTranslationsShort.
  ///
  /// In en, this message translates to:
  /// **'Failed to load translations: {error}'**
  String failedToLoadTranslationsShort(String error);

  /// No description provided for @noFolderConfiguredMsg.
  ///
  /// In en, this message translates to:
  /// **'No folder configured'**
  String get noFolderConfiguredMsg;

  /// No description provided for @failedToPlaySongMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to play song: {error}'**
  String failedToPlaySongMsg(String error);

  /// No description provided for @addedSongsToPlaylistMsg.
  ///
  /// In en, this message translates to:
  /// **'Added {count} song(s) to \"{playlist}\"'**
  String addedSongsToPlaylistMsg(int count, String playlist);

  /// No description provided for @failedToAddSongsMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to add songs: {error}'**
  String failedToAddSongsMsg(String error);

  /// No description provided for @addSongsButton.
  ///
  /// In en, this message translates to:
  /// **'Add {count} song(s)'**
  String addSongsButton(int count);

  /// No description provided for @removeSong.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeSong;

  /// No description provided for @failedToRemoveSongMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove song: {error}'**
  String failedToRemoveSongMsg(String error);

  /// No description provided for @failedToReorderSongsMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to reorder songs: {error}'**
  String failedToReorderSongsMsg(String error);

  /// No description provided for @failedToLoadSongsMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to load songs: {error}'**
  String failedToLoadSongsMsg(String error);

  /// No description provided for @errorLoadingText.
  ///
  /// In en, this message translates to:
  /// **'Error loading text: {error}'**
  String errorLoadingText(String error);

  /// No description provided for @lrcAndTranslationsLoaded.
  ///
  /// In en, this message translates to:
  /// **'LRC and {count} translation(s) loaded'**
  String lrcAndTranslationsLoaded(int count);

  /// No description provided for @translationsOnlyLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count} translation(s) loaded'**
  String translationsOnlyLoaded(int count);

  /// No description provided for @pleaseSetDeepSeekApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please set DeepSeek API key in settings'**
  String get pleaseSetDeepSeekApiKey;

  /// No description provided for @lyricsGeneratedSuccessfullyMsg.
  ///
  /// In en, this message translates to:
  /// **'Lyrics generated successfully'**
  String get lyricsGeneratedSuccessfullyMsg;

  /// No description provided for @exportShareSubject.
  ///
  /// In en, this message translates to:
  /// **'LingoTune export: {title} with lyrics and translations'**
  String exportShareSubject(String title);

  /// No description provided for @timestampOffset.
  ///
  /// In en, this message translates to:
  /// **'Timestamp Offset'**
  String get timestampOffset;

  /// No description provided for @timestampOffsetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default offset in minutes for generated timestamps'**
  String get timestampOffsetSubtitle;

  /// No description provided for @resetTimestamps.
  ///
  /// In en, this message translates to:
  /// **'Reset Timestamps'**
  String get resetTimestamps;

  /// No description provided for @resetTimestampsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset all timestamps to default values?'**
  String get resetTimestampsConfirm;

  /// No description provided for @resetTimestampsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Timestamps reset to default values'**
  String get resetTimestampsSuccess;

  /// No description provided for @saveAfterReset.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveAfterReset;

  /// No description provided for @saveAfterResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save changes after resetting timestamps?'**
  String get saveAfterResetConfirm;

  /// No description provided for @repeatOff.
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get repeatOff;

  /// No description provided for @repeatAll.
  ///
  /// In en, this message translates to:
  /// **'Repeat all'**
  String get repeatAll;

  /// No description provided for @repeatOne.
  ///
  /// In en, this message translates to:
  /// **'Repeat one'**
  String get repeatOne;

  /// No description provided for @repeatAllPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Repeat all playlists'**
  String get repeatAllPlaylists;

  /// No description provided for @playFavoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Play favorites only'**
  String get playFavoritesOnly;

  /// No description provided for @noFavoriteSongs.
  ///
  /// In en, this message translates to:
  /// **'No favorite songs yet'**
  String get noFavoriteSongs;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get playbackSpeed;

  /// No description provided for @speedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get speedNormal;

  /// No description provided for @lyricsPositionOffset.
  ///
  /// In en, this message translates to:
  /// **'Lyrics Sync Delay'**
  String get lyricsPositionOffset;

  /// No description provided for @lyricsPositionOffsetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight delay in seconds (increase if highlight jumps ahead)'**
  String get lyricsPositionOffsetSubtitle;

  /// No description provided for @studyMode.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyMode;

  /// No description provided for @studyModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Study mode: speak translation then play each line'**
  String get studyModeTooltip;

  /// No description provided for @studyModeStarted.
  ///
  /// In en, this message translates to:
  /// **'Study mode started'**
  String get studyModeStarted;

  /// No description provided for @studyModeStartedNoVoice.
  ///
  /// In en, this message translates to:
  /// **'Study mode started (segments only — no voice)'**
  String get studyModeStartedNoVoice;

  /// No description provided for @ttsLangMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'No voice for this language'**
  String get ttsLangMissingTitle;

  /// No description provided for @ttsLangMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Your device has no installed TTS voice for the translation language. Install a TTS engine with this language (e.g. Google or Yandex) under Settings → Text-to-speech, or continue in segments-only mode (no voiceover).'**
  String get ttsLangMissingBody;

  /// No description provided for @ttsContinueNoVoice.
  ///
  /// In en, this message translates to:
  /// **'Continue without voice'**
  String get ttsContinueNoVoice;

  /// No description provided for @studyModeStopped.
  ///
  /// In en, this message translates to:
  /// **'Study mode stopped'**
  String get studyModeStopped;

  /// No description provided for @studyModeNoLyrics.
  ///
  /// In en, this message translates to:
  /// **'No timed lyrics for this song'**
  String get studyModeNoLyrics;

  /// No description provided for @studyModeSettings.
  ///
  /// In en, this message translates to:
  /// **'Study Mode Settings'**
  String get studyModeSettings;

  /// No description provided for @studyPerSongOverride.
  ///
  /// In en, this message translates to:
  /// **'Custom settings for this song'**
  String get studyPerSongOverride;

  /// No description provided for @studyPerSongOverrideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When off, the app-wide defaults are used'**
  String get studyPerSongOverrideSubtitle;

  /// No description provided for @studyModeOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get studyModeOrder;

  /// No description provided for @studyModeOrderTranslationFirst.
  ///
  /// In en, this message translates to:
  /// **'Translation first'**
  String get studyModeOrderTranslationFirst;

  /// No description provided for @studyModeOrderOriginalFirst.
  ///
  /// In en, this message translates to:
  /// **'Original first'**
  String get studyModeOrderOriginalFirst;

  /// No description provided for @studyModeOrderOverlay.
  ///
  /// In en, this message translates to:
  /// **'Overlay (quiet original)'**
  String get studyModeOrderOverlay;

  /// No description provided for @studyModeSpeechRate.
  ///
  /// In en, this message translates to:
  /// **'Speech rate'**
  String get studyModeSpeechRate;

  /// No description provided for @studyModeSpeechVolume.
  ///
  /// In en, this message translates to:
  /// **'Speech volume'**
  String get studyModeSpeechVolume;

  /// No description provided for @studyModeLongPressHint.
  ///
  /// In en, this message translates to:
  /// **'Long press for settings'**
  String get studyModeLongPressHint;

  /// No description provided for @exportCurrentSong.
  ///
  /// In en, this message translates to:
  /// **'Export song'**
  String get exportCurrentSong;

  /// No description provided for @studyModeOverlayTiming.
  ///
  /// In en, this message translates to:
  /// **'When to speak'**
  String get studyModeOverlayTiming;

  /// No description provided for @studyModeOverlayAtStart.
  ///
  /// In en, this message translates to:
  /// **'At line start'**
  String get studyModeOverlayAtStart;

  /// No description provided for @studyModeOverlayAtEnd.
  ///
  /// In en, this message translates to:
  /// **'At line end'**
  String get studyModeOverlayAtEnd;

  /// No description provided for @studyModeOverlayAtBoth.
  ///
  /// In en, this message translates to:
  /// **'Start and end'**
  String get studyModeOverlayAtBoth;

  /// No description provided for @studyModeDuckVolume.
  ///
  /// In en, this message translates to:
  /// **'Original volume'**
  String get studyModeDuckVolume;

  /// No description provided for @studyModeTtsOffset.
  ///
  /// In en, this message translates to:
  /// **'Speech timing offset'**
  String get studyModeTtsOffset;

  /// No description provided for @studyModeTtsOffsetHint.
  ///
  /// In en, this message translates to:
  /// **'Negative — speak earlier, positive — later (sec). Overlay mode only'**
  String get studyModeTtsOffsetHint;

  /// No description provided for @studyModeOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Study mode settings'**
  String get studyModeOpenSettings;

  /// No description provided for @carDetectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Car Detection'**
  String get carDetectionTitle;

  /// No description provided for @carDetectionEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get carDetectionEnabled;

  /// No description provided for @carDetectionDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get carDetectionDisabled;

  /// No description provided for @carDetectionSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Sensitivity'**
  String get carDetectionSensitivity;

  /// No description provided for @carDetectionSensitivityHint.
  ///
  /// In en, this message translates to:
  /// **'Higher = more alerts (may cause false positives). Lower = only strong signals.'**
  String get carDetectionSensitivityHint;

  /// No description provided for @carAlertSound.
  ///
  /// In en, this message translates to:
  /// **'Sound alert'**
  String get carAlertSound;

  /// No description provided for @carAlertSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Beep over the music'**
  String get carAlertSoundSubtitle;

  /// No description provided for @carAlertVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration alert'**
  String get carAlertVibration;

  /// No description provided for @carAlertVibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback on detection'**
  String get carAlertVibrationSubtitle;

  /// No description provided for @carAlertVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice alert'**
  String get carAlertVoice;

  /// No description provided for @carAlertVoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spoken warning via TTS'**
  String get carAlertVoiceSubtitle;

  /// No description provided for @carDetectionPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Audio is analyzed on-device only — nothing is recorded or sent anywhere.'**
  String get carDetectionPrivacyNote;

  /// No description provided for @carDetectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Car detection via microphone'**
  String get carDetectionTooltip;

  /// No description provided for @carDetectionStarted.
  ///
  /// In en, this message translates to:
  /// **'Car detection started — listening for vehicles'**
  String get carDetectionStarted;

  /// No description provided for @carDetectionMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied — cannot detect cars'**
  String get carDetectionMicDenied;

  /// No description provided for @carCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Detector calibration'**
  String get carCalibrationTitle;

  /// No description provided for @carCalibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Train detector on your sounds'**
  String get carCalibrationSubtitle;

  /// No description provided for @carCalibrationMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied — calibration impossible'**
  String get carCalibrationMicDenied;

  /// No description provided for @carCalibrationLive.
  ///
  /// In en, this message translates to:
  /// **'Live spectrum'**
  String get carCalibrationLive;

  /// No description provided for @carCalibrationModeClassify.
  ///
  /// In en, this message translates to:
  /// **'Mode: classify'**
  String get carCalibrationModeClassify;

  /// No description provided for @carCalibrationModeThreshold.
  ///
  /// In en, this message translates to:
  /// **'Mode: threshold'**
  String get carCalibrationModeThreshold;

  /// No description provided for @carCalibrationNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest: {cls} (d={dist})'**
  String carCalibrationNearest(String cls, String dist);

  /// No description provided for @carCalibrationNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get carCalibrationNoMatch;

  /// No description provided for @carCalibrationThresholdScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String carCalibrationThresholdScore(String score);

  /// No description provided for @carCalibrationRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record sample'**
  String get carCalibrationRecordTitle;

  /// No description provided for @carCalibrationClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get carCalibrationClass;

  /// No description provided for @carCalibrationName.
  ///
  /// In en, this message translates to:
  /// **'Sample name'**
  String get carCalibrationName;

  /// No description provided for @carCalibrationRecord.
  ///
  /// In en, this message translates to:
  /// **'Record 5 sec'**
  String get carCalibrationRecord;

  /// No description provided for @carCalibrationRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording... {s}s'**
  String carCalibrationRecording(int s);

  /// No description provided for @carCalibrationProfilesCount.
  ///
  /// In en, this message translates to:
  /// **'Profiles ({n})'**
  String carCalibrationProfilesCount(int n);

  /// No description provided for @carCalibrationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No samples yet — record your first'**
  String get carCalibrationEmpty;

  /// No description provided for @carCalibrationDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get carCalibrationDelete;

  /// No description provided for @carCalibrationDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String carCalibrationDeleteConfirm(String name);

  /// No description provided for @carCalibrationReset.
  ///
  /// In en, this message translates to:
  /// **'Reset all'**
  String get carCalibrationReset;

  /// No description provided for @carCalibrationResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all calibration profiles?'**
  String get carCalibrationResetConfirm;

  /// No description provided for @carCalibrationCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get carCalibrationCancel;

  /// No description provided for @carCalibrationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get carCalibrationConfirm;

  /// No description provided for @carCalibrationLoadDemo.
  ///
  /// In en, this message translates to:
  /// **'Load demo profiles'**
  String get carCalibrationLoadDemo;

  /// No description provided for @carCalibrationDemoPrefix.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get carCalibrationDemoPrefix;

  /// No description provided for @carCalibrationDemoLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded {n} demo profiles'**
  String carCalibrationDemoLoaded(int n);

  /// No description provided for @profileClassCarClose.
  ///
  /// In en, this message translates to:
  /// **'Car close'**
  String get profileClassCarClose;

  /// No description provided for @profileClassCarFar.
  ///
  /// In en, this message translates to:
  /// **'Car far'**
  String get profileClassCarFar;

  /// No description provided for @profileClassCarTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get profileClassCarTruck;

  /// No description provided for @profileClassCarMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get profileClassCarMotorcycle;

  /// No description provided for @profileClassWind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get profileClassWind;

  /// No description provided for @profileClassSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get profileClassSteps;

  /// No description provided for @profileClassVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get profileClassVoice;

  /// No description provided for @profileClassStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get profileClassStreet;

  /// No description provided for @profileClassMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get profileClassMusic;

  /// No description provided for @profileClassOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileClassOther;

  /// No description provided for @ttsSource.
  ///
  /// In en, this message translates to:
  /// **'TTS source'**
  String get ttsSource;

  /// No description provided for @ttsSourceOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get ttsSourceOffline;

  /// No description provided for @ttsSourceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get ttsSourceSystem;

  /// No description provided for @ttsSourceOfflineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built-in neural TTS (recommended, stable on all devices)'**
  String get ttsSourceOfflineSubtitle;

  /// No description provided for @ttsSourceSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Android system TTS engine'**
  String get ttsSourceSystemSubtitle;

  /// No description provided for @ttsSourceSwitchedHint.
  ///
  /// In en, this message translates to:
  /// **'TTS source switched'**
  String get ttsSourceSwitchedHint;

  /// No description provided for @voicePackages.
  ///
  /// In en, this message translates to:
  /// **'Voice packages'**
  String get voicePackages;

  /// No description provided for @voicePackagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline TTS models for languages'**
  String get voicePackagesSubtitle;

  /// No description provided for @voicePackagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Download offline neural TTS models so speech works without internet and stays stable on any device. The Russian model is bundled with the app; others can be downloaded here.'**
  String get voicePackagesDescription;

  /// No description provided for @voicePackageReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get voicePackageReady;

  /// No description provided for @voicePackageBundled.
  ///
  /// In en, this message translates to:
  /// **'Bundled with the app'**
  String get voicePackageBundled;

  /// No description provided for @voicePackageDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get voicePackageDownload;

  /// No description provided for @voicePackageInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get voicePackageInstall;

  /// No description provided for @voicePackageRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get voicePackageRetry;

  /// No description provided for @voicePackageDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get voicePackageDownloading;

  /// No description provided for @voicePackageExtracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting...'**
  String get voicePackageExtracting;

  /// No description provided for @voicePackageError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get voicePackageError;

  /// No description provided for @voicePackageDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get voicePackageDelete;

  /// No description provided for @voicePackageInstalledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Model for \"{lang}\" installed'**
  String voicePackageInstalledSuccess(Object lang);

  /// No description provided for @voicePackageInstalledFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to install model for \"{lang}\"'**
  String voicePackageInstalledFailed(Object lang);

  /// No description provided for @voicePackageDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete model for \"{lang}\"? This frees up disk space.'**
  String voicePackageDeleteConfirm(Object lang);

  /// No description provided for @lyricColors.
  ///
  /// In en, this message translates to:
  /// **'Line colors'**
  String get lyricColors;

  /// No description provided for @lyricColorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Line colors'**
  String get lyricColorsTitle;

  /// No description provided for @lyricColorsUseCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom colors'**
  String get lyricColorsUseCustom;

  /// No description provided for @lyricColorsPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get lyricColorsPresets;

  /// No description provided for @lyricColorsOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get lyricColorsOriginal;

  /// No description provided for @lyricColorsTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get lyricColorsTranslation;

  /// No description provided for @lyricColorsActive.
  ///
  /// In en, this message translates to:
  /// **'Active line'**
  String get lyricColorsActive;

  /// No description provided for @lyricColorsPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get lyricColorsPreview;

  /// No description provided for @lyricColorsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get lyricColorsDone;

  /// No description provided for @lyricPresetDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get lyricPresetDefault;

  /// No description provided for @lyricPresetBlueRed.
  ///
  /// In en, this message translates to:
  /// **'Original blue / Translation red'**
  String get lyricPresetBlueRed;

  /// No description provided for @lyricPresetRedBlue.
  ///
  /// In en, this message translates to:
  /// **'Original red / Translation blue'**
  String get lyricPresetRedBlue;

  /// No description provided for @lyricPresetGreenOrange.
  ///
  /// In en, this message translates to:
  /// **'Original green / Translation orange'**
  String get lyricPresetGreenOrange;

  /// No description provided for @lyricPresetContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get lyricPresetContrast;

  /// No description provided for @renamePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renamePlaylist;

  /// No description provided for @renamePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get renamePlaylistTitle;

  /// No description provided for @playlistNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistNameLabel;

  /// No description provided for @playlistRenamed.
  ///
  /// In en, this message translates to:
  /// **'Playlist renamed'**
  String get playlistRenamed;

  /// No description provided for @playlistNameExists.
  ///
  /// In en, this message translates to:
  /// **'A playlist with this name already exists'**
  String get playlistNameExists;

  /// No description provided for @noLyricsHint.
  ///
  /// In en, this message translates to:
  /// **'This song has no lyrics yet'**
  String get noLyricsHint;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updateChecking;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get updateAvailableTitle;

  /// No description provided for @updateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String updateCurrentVersion(Object version);

  /// No description provided for @updateNewVersion.
  ///
  /// In en, this message translates to:
  /// **'New version: {version}'**
  String updateNewVersion(Object version);

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNew;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get downloadingUpdate;

  /// No description provided for @updateDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Update downloaded'**
  String get updateDownloaded;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @openReleasePage.
  ///
  /// In en, this message translates to:
  /// **'Open release page'**
  String get openReleasePage;

  /// No description provided for @noUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'✓ You have the latest version'**
  String get noUpdatesAvailable;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates'**
  String get updateCheckFailed;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download the update'**
  String get updateDownloadFailed;

  /// No description provided for @updateInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the installation. Open the downloaded APK manually.'**
  String get updateInstallFailed;

  /// No description provided for @updateSource.
  ///
  /// In en, this message translates to:
  /// **'Update source'**
  String get updateSource;

  /// No description provided for @updateSourceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Default: Aila update center, GitHub Releases as backup; or set any manifest URL (JSON with a version and an APK link)'**
  String get updateSourceSubtitle;

  /// No description provided for @updateSourceDefault.
  ///
  /// In en, this message translates to:
  /// **'Aila update center (default)'**
  String get updateSourceDefault;

  /// No description provided for @updateSourceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Update manifest URL'**
  String get updateSourceDialogTitle;

  /// No description provided for @updateSourceHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/manifest.json'**
  String get updateSourceHint;

  /// No description provided for @updateSourceReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get updateSourceReset;

  /// No description provided for @updateSourceSaved.
  ///
  /// In en, this message translates to:
  /// **'Update source saved'**
  String get updateSourceSaved;

  /// No description provided for @updateSourceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http(s) URL'**
  String get updateSourceInvalid;

  /// No description provided for @showEqualizerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show equalizer instead of lyrics'**
  String get showEqualizerTooltip;

  /// No description provided for @showLyricsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show song lyrics'**
  String get showLyricsTooltip;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fr', 'it', 'pt', 'ro', 'ru', 'uk', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'pt': return AppLocalizationsPt();
    case 'ro': return AppLocalizationsRo();
    case 'ru': return AppLocalizationsRu();
    case 'uk': return AppLocalizationsUk();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
