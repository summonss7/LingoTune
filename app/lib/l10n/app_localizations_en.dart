// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Library';

  @override
  String get playlists => 'Playlists';

  @override
  String get settings => 'Settings';

  @override
  String get allSongs => 'All Songs';

  @override
  String get favorites => 'Favorites';

  @override
  String get createPlaylist => 'Create Playlist';

  @override
  String get playlistName => 'Playlist Name';

  @override
  String get iconOptional => 'Icon (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get addToPlaylist => 'Add to Playlist';

  @override
  String get removeFromPlaylist => 'Remove from Playlist';

  @override
  String get addSongsToLibrary => 'Add songs from Library';

  @override
  String get noSongsToAdd => 'No songs to add';

  @override
  String addButtonText(Object count) {
    return 'Add $count';
  }

  @override
  String get selected => 'selected';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get autoScroll => 'Auto Scroll';

  @override
  String get autoScrollSubtitle => 'Automatically scroll to current line';

  @override
  String get highlightNextLine => 'Highlight Next Line';

  @override
  String get highlightNextLineSubtitle => 'Show next line with subtle highlight';

  @override
  String get fontSize => 'Font Size';

  @override
  String get scrollOffset => 'Scroll Offset';

  @override
  String get scrollOffsetSubtitle => 'Distance from top of screen in pixels';

  @override
  String get autoScrollFocusOffset => 'Auto Scroll Focus Offset';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Default focus position for auto-scroll (default: +50)';

  @override
  String get defaultTranslationLanguage => 'Default Translation Language';

  @override
  String get defaultOriginalLanguage => 'Default Original Language';

  @override
  String get russian => 'Russian';

  @override
  String get english => 'English';

  @override
  String get romanian => 'Romanian';

  @override
  String get french => 'French';

  @override
  String get german => 'German';

  @override
  String get spanish => 'Spanish';

  @override
  String get italian => 'Italian';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get lyricsFolder => 'Lyrics Folder';

  @override
  String get useLyricsFolder => 'Use Lyrics Folder';

  @override
  String get useLyricsFolderDisabled => 'Disabled - files must be selected with audio';

  @override
  String get setLyricsFolder => 'Set Lyrics Folder';

  @override
  String get selectFolder => 'Select Folder';

  @override
  String get folderPath => 'Folder path';

  @override
  String get examples => 'Examples:';

  @override
  String get defaultFolder => 'Default: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Current folder:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Folder set: $path';
  }

  @override
  String get folderSetFailed => 'Folder does not exist or no access';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get showCurrentFolder => 'Show current folder';

  @override
  String get changeFolder => 'Change folder';

  @override
  String get resetToDefaultFolder => 'Reset to default folder';

  @override
  String get folderReset => 'Reset to default folder';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheSubtitle => 'Clear temporary files';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get resetSongLanguages => 'Reset Song Languages';

  @override
  String get resetSongLanguagesSubtitle => 'Use default language from settings';

  @override
  String get songLanguagesReset => 'Song languages reset';

  @override
  String get about => 'About';

  @override
  String get translationsLoaded => 'Translations loaded successfully!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Failed to load translations: $error';
  }

  @override
  String get editTranslations => 'Edit';

  @override
  String get loadTranslationsFromFile => 'Import ZIP archive';

  @override
  String get loadTextMenu => 'Load text';

  @override
  String get loadTranslations => 'Load Translations';

  @override
  String get deleteTranslation => 'Delete translation';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get noLrcFileAssociated => 'No LRC file associated with this song';

  @override
  String get lrcFileSaved => 'LRC file saved successfully!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'Failed to save LRC file: $error';
  }

  @override
  String get exitEditMode => 'Exit edit mode';

  @override
  String get editTimestamps => 'Edit timestamps';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get language => 'Language';

  @override
  String get loading => 'Loading...';

  @override
  String get noSongsFound => 'No songs found';

  @override
  String get noPlaylistsFound => 'No playlists found';

  @override
  String get selectSong => 'Select a song to play';

  @override
  String get song => 'Song';

  @override
  String get artist => 'Artist';

  @override
  String get duration => 'Duration';

  @override
  String get actions => 'Actions';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get rewind10 => '-10s';

  @override
  String get forward10 => '+10s';

  @override
  String get repeat => 'Repeat';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get volume => 'Volume';

  @override
  String get speed => 'Speed';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get translations => 'Translations';

  @override
  String get originalText => 'Original Text';

  @override
  String get translatedText => 'Translated Text';

  @override
  String get showTranscription => 'Show Transcription';

  @override
  String get showTranscriptionSubtitle => 'Display pronunciation guide';

  @override
  String get showTranslationFirst => 'Translation First';

  @override
  String get showTranslationFirstSubtitle => 'Show translation before original text';

  @override
  String get italianLang => 'Italiano';

  @override
  String get portugueseLang => 'Português';

  @override
  String get lyricsEditor => 'Lyrics Editor';

  @override
  String get addLine => 'Add Line';

  @override
  String get updateLine => 'Update Line';

  @override
  String get deleteLine => 'Delete Line';

  @override
  String get clearAll => 'Clear All';

  @override
  String get moveUp => 'Move Up';

  @override
  String get moveDown => 'Move Down';

  @override
  String get autoSyncLyrics => 'Auto Sync Lyrics';

  @override
  String get exportLrc => 'Export LRC (Original)';

  @override
  String get exportJson => 'Export JSON (Translations)';

  @override
  String get markTimestamp => 'Mark Timestamp (Enter)';

  @override
  String get original => 'Original';

  @override
  String get translation => 'Translation';

  @override
  String get audioFile => 'Audio File';

  @override
  String get songTitle => 'Song Title';

  @override
  String get browse => 'Browse';

  @override
  String get audioControls => 'Audio Controls';

  @override
  String get addEditLine => 'Add/Edit Line';

  @override
  String get instructions => 'Instructions';

  @override
  String get lyricsEditorInstructions => 'LRC Synchronizer Instructions:\n\n1. Select an audio file using Browse button\n2. Enter song title and artist (optional)\n3. Click Play to start audio\n4. When a line is sung, type original text in \'Original\' field\n5. Press Enter or click \'Mark Timestamp\' to record timestamp\n6. Optionally add a translation in \'Translation\' field\n7. Repeat steps 4-6 for each line\n8. Use \'Export LRC\' to save original lyrics with timestamps\n9. Use \'Export JSON\' to save translations\n\nTips:\n- Use -10s/+10s to navigate quickly through the song\n- You can reorder lines using Move Up/Down\n- Load previously saved JSON files to edit translations';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeMessage => 'Start your language learning journey with music!';

  @override
  String get importSongs => 'Import Songs';

  @override
  String get importSongsSubtitle => 'Add audio files from your device';

  @override
  String get manageLibrary => 'Manage Library';

  @override
  String get manageLibrarySubtitle => 'Organize your songs and playlists';

  @override
  String get syncLyrics => 'Sync Lyrics';

  @override
  String get syncLyricsSubtitle => 'Automatically sync lyrics with audio';

  @override
  String get languageLearning => 'Language Learning • Music • Translations';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developed by';

  @override
  String get website => 'Website';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Failed to create playlist: $error';
  }

  @override
  String get playlistCreated => 'Playlist created successfully!';

  @override
  String get playlistDeleted => 'Playlist deleted successfully!';

  @override
  String get playlistUpdated => 'Playlist updated successfully!';

  @override
  String get songAdded => 'Song added successfully!';

  @override
  String get songRemoved => 'Song removed successfully!';

  @override
  String get songDeleted => 'Song deleted successfully!';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get success => 'Success';

  @override
  String get confirm => 'Confirm';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get unsavedChanges => 'You have unsaved changes. Continue?';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get appLanguage => 'App Language';

  @override
  String get englishLang => 'English';

  @override
  String get russianLang => 'Русский';

  @override
  String get romanianLang => 'Română';

  @override
  String get frenchLang => 'Français';

  @override
  String get germanLang => 'Deutsch';

  @override
  String get spanishLang => 'Español';

  @override
  String get chineseLang => '中文';

  @override
  String get arabicLang => 'العربية';

  @override
  String get welcomeToLingoTune => 'Welcome to LingoTune';

  @override
  String get folderSetupMessage => 'Choose a folder to store lyrics and translations (LRC and JSON files). This makes it easy to organize your music library.';

  @override
  String get selectFolderNow => 'Select Folder Now';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get setupLater => 'Setup Later';

  @override
  String get useDefaultFolder => 'Use Default Folder';

  @override
  String get databaseFound => 'Database found in import file';

  @override
  String get importDatabaseQuestion => 'Do you want to import the database too?';

  @override
  String get mergeDatabase => 'Merge';

  @override
  String get replaceDatabase => 'Replace';

  @override
  String get importDatabase => 'Import Database';

  @override
  String get skipDatabase => 'Skip Database';

  @override
  String get mergeDatabaseDescription => 'Merge imported songs with your library (adds new items only)';

  @override
  String get replaceDatabaseDescription => 'Replace your entire library with the imported database (you will lose all existing data)';

  @override
  String get exporting => 'Exporting...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Exporting $current of $total songs';
  }

  @override
  String get exportDatabaseIncluded => 'Database included in export';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'Imported $fileCount file(s) and database';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'Imported $fileCount file(s)';
  }

  @override
  String get chinese => 'Chinese';

  @override
  String get arabic => 'Arabic';

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get themeNameAmethyst => 'Amethyst';

  @override
  String get themeColorPurple => 'Purple';

  @override
  String get themeColorBlue => 'Blue';

  @override
  String get themeColorGreen => 'Green';

  @override
  String get themeColorOrange => 'Orange';

  @override
  String get themeColorRed => 'Red';

  @override
  String get themeColorPink => 'Pink';

  @override
  String get themeColorDeepOrange => 'Deep Orange';

  @override
  String get themeColorDarkRed => 'Dark Red';

  @override
  String get themeColorTeal => 'Teal';

  @override
  String get themeColorCyan => 'Cyan';

  @override
  String get themeColorAmber => 'Amber';

  @override
  String get themeColorLime => 'Lime';

  @override
  String get ukrainianLang => 'Ukrainian';

  @override
  String get font => 'Font';

  @override
  String get fontSettings => 'Font Settings';

  @override
  String get systemFont => 'System';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Main Text Size';

  @override
  String get mainTextBold => 'Bold Main Text';

  @override
  String get translationSize => 'Translation Size';

  @override
  String get translationBold => 'Bold Translation';

  @override
  String get transcriptSize => 'Transcript Size';

  @override
  String get transcriptBold => 'Bold Transcript';

  @override
  String get defaultStartScreen => 'Default Start Screen';

  @override
  String get defaultStartScreenSubtitle => 'Screen to show when app starts';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Add to Library When Adding to Playlist';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Automatically add songs to library when added to a playlist';

  @override
  String get serviceMessages => 'Service Messages';

  @override
  String get serviceMessagesSubtitle => 'Show service notifications about translation and transcription';

  @override
  String get serviceData => 'Service Data';

  @override
  String get serviceDataSubtitle => 'Show diagnostic overlay in study mode';

  @override
  String get ttsEngine => 'TTS Engine';

  @override
  String get ttsEngineSubtitle => 'No TTS engines detected — the app may not see system speech engines.';

  @override
  String get ttsEngineAuto => 'Auto (recommended)';

  @override
  String get ttsEngineReloadHint => 'Engine changed — takes effect on next study session';

  @override
  String get includeMp3Files => 'Include MP3 files';

  @override
  String get includeMp3FilesSubtitle => 'This will increase the archive size';

  @override
  String get importMp3Files => 'Import MP3 files';

  @override
  String get importMp3FilesSubtitle => 'Add music files to library';

  @override
  String get exportSongs => 'Export Songs';

  @override
  String get import => 'Import';

  @override
  String get addMultiple => 'Select multiple';

  @override
  String get addToPlaylistShort => 'Add';

  @override
  String get deleteShort => 'Delete';

  @override
  String get selectAllShort => 'All';

  @override
  String get deselectAllShort => 'Clear';

  @override
  String get exitSelectionMode => 'Exit selection mode';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get addMultipleToPlaylist => 'Add to Playlist';

  @override
  String get coverArt => 'Cover Art';

  @override
  String get playlistCover => 'Playlist Cover';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get removeCover => 'Remove Cover';

  @override
  String get coverUpdated => 'Cover updated';

  @override
  String get coverRemoved => 'Cover removed';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get importFolders => 'Import Folders';

  @override
  String get selectMusicFolder => 'Select Music Folder';

  @override
  String get folderWithAudioFiles => 'Folder with MP3/WAV files';

  @override
  String get sameFolderForLyrics => 'Same folder for lyrics';

  @override
  String get selectLyricsFolder => 'Select Lyrics Folder';

  @override
  String get folderWithLyricsFiles => 'Folder with LRC/JSON files (optional)';

  @override
  String get pleaseEnterPlaylistName => 'Please enter playlist name';

  @override
  String get pleaseSelectMusicFolder => 'Please select music folder';

  @override
  String get cropImage => 'Crop Image';

  @override
  String get photoPermissionRequired => 'Photo access permission required';

  @override
  String get photoPermissionDenied => 'Photo access denied';

  @override
  String get imageProcessingError => 'Failed to process image';

  @override
  String get scanningFolder => 'Scanning folder...';

  @override
  String get importingFiles => 'Importing files...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Importing $current/$total files... Found $songs songs';
  }

  @override
  String processingFile(Object file) {
    return 'Processing $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Add to Playlist';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Added to \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Failed to add to playlist: $error';
  }

  @override
  String get deleteSong => 'Delete';

  @override
  String get importSongDialogTitle => 'Import Song';

  @override
  String get audioOnly => 'Audio only';

  @override
  String get addLyricsLater => 'I will add lyrics later';

  @override
  String get audioWithLyricsZIP => 'Audio + Lyrics ZIP';

  @override
  String get importWithAllTranslations => 'Import with all translations';

  @override
  String get importTranslationDialogTitle => 'Add Translation';

  @override
  String get loadTranslationFromZip => 'Load from ZIP archive';

  @override
  String get loadTranslationFromJson => 'Load from JSON file';

  @override
  String get noAudioFilesSelected => 'No audio files selected';

  @override
  String failedToImportSongs(Object error) {
    return 'Failed to import songs: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Failed to import song: $error';
  }

  @override
  String get musicFolderNotSelected => 'Music folder not selected';

  @override
  String get generateLyrics => 'Generate Lyrics';

  @override
  String get selectTextFileOrEnterText => 'Select text file or enter text';

  @override
  String get originalLanguage => 'Original language';

  @override
  String get translationLanguages => 'Translation languages';

  @override
  String get startMinuteForTimestamps => 'Start minute for timestamps';

  @override
  String get transcriptionLanguage => 'Transcription language';

  @override
  String get generating => 'Generating...';

  @override
  String get generate => 'Generate';

  @override
  String get deepseekApiKey => 'DeepSeek API Key';

  @override
  String get validateKey => 'Validate key';

  @override
  String get keyIsValid => 'Key is valid';

  @override
  String get keyIsInvalid => 'Key is invalid';

  @override
  String get lyricsGenerationSuccess => 'Lyrics generated successfully';

  @override
  String get lyricsGenerationError => 'Failed to generate lyrics';

  @override
  String get savingFiles => 'Saving files...';

  @override
  String get enterText => 'Enter text';

  @override
  String get transcript => 'Transcript';

  @override
  String get originalTextEditable => 'Original Text (editable)';

  @override
  String get selectLanguageToEdit => 'Select language to edit';

  @override
  String get moveLineUp => 'Move line up';

  @override
  String get moveLineDown => 'Move line down';

  @override
  String get moveAllTranslationsUp => 'Move all translations up';

  @override
  String get moveAllTranslationsDown => 'Move all translations down';

  @override
  String get translationSaved => 'Translation saved!';

  @override
  String get translationSaveFailed => 'Failed to save translation';

  @override
  String get loadTextTitle => 'Load Text';

  @override
  String get noOriginalTextWarning => 'Please load original text first';

  @override
  String get selectLanguageOriginal => 'Original language';

  @override
  String get startTimestampMinutes => 'Start timestamp (minutes)';

  @override
  String get selectLanguageTranslation => 'Translation language';

  @override
  String get originalTextLoaded => 'Original text loaded successfully!';

  @override
  String get translationLoaded => 'Translation loaded successfully!';

  @override
  String get transcriptLoaded => 'Transcript loaded successfully!';

  @override
  String get selectTranslationLanguage => 'Translation language for transcript';

  @override
  String get noTranslationWarning => 'No translations loaded';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Lines mismatch: $loaded lines, expected $expected';
  }

  @override
  String get loadTextTooltip => 'Load text or translation';

  @override
  String get loadFromFile => 'Load from file';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get audioNotificationService => 'Audio Notification Service';

  @override
  String get audioNotificationServiceActive => 'Status: ✅ Active';

  @override
  String get audioNotificationServiceError => 'Status: ❌ Error';

  @override
  String get errorLabel => 'Error:';

  @override
  String get audioNotificationServiceDescription => 'This service provides notifications when app is minimized';

  @override
  String get reorder => 'Reorder';

  @override
  String get done => 'Done';

  @override
  String get selectMultiple => 'Select multiple';

  @override
  String get sortSongs => 'Sort songs';

  @override
  String get importSong => 'Import Song';

  @override
  String get sortDefault => 'Default';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Newest';

  @override
  String get sortDateAsc => 'Oldest';

  @override
  String get importingSongs => 'Importing songs...';

  @override
  String get noSongsInPlaylist => 'No songs in this playlist';

  @override
  String get addSongsFromLibraryHint => 'Add songs from your library';

  @override
  String get removedSongsFromPlaylist => 'Removed songs from playlist';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Failed to delete songs: $error';
  }

  @override
  String get deletePlaylistTitle => 'Delete Playlist';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'Are you sure you want to delete \"$playlist\"?';
  }

  @override
  String get failedToDeletePlaylist => 'Failed to delete playlist:';

  @override
  String get specifyTranslationLanguage => 'Specify translation language';

  @override
  String get languageNameLabel => 'Language name';

  @override
  String get languageNameHint => 'For example: Russian, Author\'s, Poetic';

  @override
  String get translationTypeLabel => 'Translation type:';

  @override
  String get translationTypeNormal => 'Normal';

  @override
  String get translationTypeAuthor => 'Author\'s';

  @override
  String get translationTypePoetic => 'Poetic';

  @override
  String get translationTypeLiteral => 'Literal';

  @override
  String mp3FilesCount(Object count) {
    return 'MP3 files: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return 'Imported $count file(s) (database skipped)';
  }

  @override
  String get databaseMerged => 'Database merged';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'Database merged, MP3 files: $count';
  }

  @override
  String get databaseReplaced => 'Database replaced';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'Database replaced, MP3 files: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Confirm Replace';

  @override
  String get confirmReplaceDatabaseWarning => 'Are you sure? You will lose all existing songs and playlists!';

  @override
  String get replaceAll => 'Replace All';

  @override
  String get selectLanguages => 'Select languages';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Selected: $count languages';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Selected: $count';
  }

  @override
  String get promptPreset => 'Prompt Preset';

  @override
  String get balanced => 'Balanced';

  @override
  String get poetic => 'Poetic';

  @override
  String get literal => 'Literal';

  @override
  String get customPromptOption => 'Custom...';

  @override
  String get editPrompt => 'Edit Prompt';

  @override
  String get notSet => 'Not set';

  @override
  String get showOrEditApiKey => 'Show/Edit API key';

  @override
  String get timeout => 'Timeout';

  @override
  String get model => 'Model';

  @override
  String get resetToPreset => 'Reset to preset';

  @override
  String get customPrompt => 'Custom prompt';

  @override
  String customPromptChars(Object count) {
    return 'Custom prompt ($count chars)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Using preset: $preset';
  }

  @override
  String get characters => 'characters';

  @override
  String get deepSeekPromptTitle => 'DeepSeek Prompt';

  @override
  String get customPromptLabel => 'Custom Prompt';

  @override
  String get leaveEmptyToUseDefault => 'Leave empty to use default prompt';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Leave empty to use the default prompt built into the app';

  @override
  String get apiKeySaved => 'API key saved';

  @override
  String get enterTimeout => 'Enter timeout in seconds';

  @override
  String get validTimeoutRange => 'Please enter a valid timeout (1-3600 seconds)';

  @override
  String get customTimeout => 'Custom Timeout';

  @override
  String get timeoutSeconds => 'Timeout (seconds)';

  @override
  String timeoutSetTo(Object value) {
    return 'Timeout set to $value seconds';
  }

  @override
  String get customModel => 'Custom Model';

  @override
  String get modelName => 'Model Name';

  @override
  String get enterModelName => 'Enter the exact model name as provided by DeepSeek API';

  @override
  String get pleaseEnterModelName => 'Please enter a model name';

  @override
  String modelSetTo(Object value) {
    return 'Model set to $value';
  }

  @override
  String get editCustomPrompt => 'Edit Custom Prompt';

  @override
  String get editPresetPrompt => 'Edit Preset Prompt';

  @override
  String get editingPreset => 'Editing Preset';

  @override
  String get anyChangesSaveAsCustom => 'Any changes will save as a custom prompt. Use \'Reset\' button to restore the original preset.';

  @override
  String get useResetToRestorePreset => 'Use \'Reset\' button to restore the original preset';

  @override
  String get prompt => 'Prompt';

  @override
  String get promptSaved => 'Prompt saved';

  @override
  String get usingPresetPrompt => 'Using preset prompt';

  @override
  String get apiKeyHint => 'API Key';

  @override
  String get modelHint => 'e.g. deepseek-v3';

  @override
  String get enterExactModelName => 'Enter the exact model name as provided by DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'Please enter API key first';

  @override
  String get maxTokensRegular => 'Max Tokens (Regular)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Token limit for regular translation requests';

  @override
  String get maxTokensJsonHint => 'Token limit for full generation (JSON) requests';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (regular) set to $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) set to $value';
  }

  @override
  String get refreshFolder => 'Refresh Folder';

  @override
  String get refreshingFolder => 'Refreshing folder...';

  @override
  String get playlistCreatedWithLink => 'Playlist created! Press \"Refresh\" to load songs from folder';

  @override
  String refreshedPlaylist(Object count) {
    return 'Refreshed: $count songs';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Refresh error: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Failed to load songs: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'Music folder does not exist';

  @override
  String successfullyImportedSongs(Object count) {
    return 'Successfully imported $count song(s)';
  }

  @override
  String get noAudioFileSelected => 'No audio file selected';

  @override
  String get noZipArchiveSelected => 'No ZIP archive selected';

  @override
  String get noFolderConfigured => 'No folder configured';

  @override
  String get missingLyricsTranslations => 'Missing Lyrics/Translations';

  @override
  String missingForSong(Object songName) {
    return 'For \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Missing: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get lyricsGeneratedSuccessfully => 'Lyrics generated successfully';

  @override
  String get setDeepSeekApiKey => 'Please set DeepSeek API key in settings';

  @override
  String failedToOpenSong(Object error) {
    return 'Failed to open song: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'Also delete LRC and JSON files';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Added to \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Failed to add to playlist: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return 'Exported $count songs';
  }

  @override
  String get fileNotFound => 'File not found';

  @override
  String get selectZipFileNotJson => 'Please select a ZIP file, not JSON or LRC';

  @override
  String get noFilesFoundInZip => 'No files found in ZIP';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Invalid ZIP file format: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return 'Found $count translation(s)';
  }

  @override
  String mp3ImportError(Object error) {
    return 'MP3 import error: $error';
  }

  @override
  String get importSongFirstToSearch => 'Import a song first to search for lyrics';

  @override
  String get lyricsFetched => 'Lyrics Fetched';

  @override
  String get lyricsFoundUseCreate => 'Lyrics found! Use to create a synchronized LRC file';

  @override
  String get deleteSelectedSongs => 'Delete Selected Songs';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'Are you sure you want to delete $count song(s)?';
  }

  @override
  String get songsDeletedSuccessfully => 'Songs deleted successfully';

  @override
  String get storagePermissionRequired => 'Storage permission is required to access folders.';

  @override
  String get enableStoragePermission => 'Please enable storage permission in app settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get unableToSelectFolder => 'Unable to select folder. Please try alternative:';

  @override
  String get selectFilesInstead => 'Select Files Instead';

  @override
  String get enterFolderPath => 'Please enter a folder path';

  @override
  String get folderDoesNotExist => '✗ Folder does not exist';

  @override
  String folderSetWithPath(Object path) {
    return 'Folder set: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Error setting folder: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'Unable to select lyrics folder. Please try alternative:';

  @override
  String get useManualPath => 'Use manual path (for testing)';

  @override
  String get enterFolderPathManually => 'Enter folder path manually instead of using folder picker';

  @override
  String get folderPathLabel => 'Folder Path';

  @override
  String get folderPathHint => 'Example: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Full path to your music folder';

  @override
  String get setPath => 'Set Path';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'Select ZIP archive with lyrics for \"$title\"';
  }

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get failedToCopyLrcFile => 'Failed to copy LRC file';

  @override
  String copiedJsonFiles(Object count) {
    return 'Copied $count JSON file(s)';
  }

  @override
  String get failedToCopyJsonFiles => 'Failed to copy JSON files';

  @override
  String failedToDeleteSong(Object error) {
    return 'Failed to delete song: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return 'Added $count song(s) to \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'Add $count song(s) to Playlist';
  }

  @override
  String get failedToExportSongs => 'Failed to export songs';

  @override
  String get ok => 'OK';

  @override
  String deleteSongConfirm(Object song) {
    return 'Are you sure you want to delete \"$song\"?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Select music folder for this playlist';

  @override
  String get folderLinkedToPlaylist => 'Folder linked to playlist';

  @override
  String get folderUnlinkedFromPlaylist => 'Folder unlinked from playlist';

  @override
  String get checkFolderAccess => 'Check Folder Access';

  @override
  String get checkingPermissions => 'Checking permissions...';

  @override
  String get folderAccessible => '✓ Folder accessible';

  @override
  String get folderNotAccessible => '✗ Folder not accessible';

  @override
  String audioFilesFound(Object count) {
    return '$count audio file(s) found';
  }

  @override
  String lyricsFound(Object count) {
    return '$count lyrics file(s) found';
  }

  @override
  String get noAudioFiles => 'No audio files found';

  @override
  String get noLyricsFiles => 'No lyrics files found';

  @override
  String errorCheckingAccess(Object error) {
    return 'Error checking folder access: $error';
  }

  @override
  String get folderPathColon => 'Folder path:';

  @override
  String get permissionsStatus => 'Permissions status:';

  @override
  String get folderContent => 'Folder content:';

  @override
  String get accessGranted => '✓ Access granted';

  @override
  String get accessDenied => '✗ Access denied';

  @override
  String get permissionRequestFailed => 'Failed to request permissions';

  @override
  String get pleaseGrantPermissions => 'Please grant storage permissions to check folder access';

  @override
  String get refreshOnlySongs => 'Only songs';

  @override
  String get refreshEverything => 'Everything';

  @override
  String get refreshDialogDescription => 'What would you like to update? \"Only songs\" speeds up process by skipping lyrics.';

  @override
  String get mostSongs => 'Most Songs';

  @override
  String get playlistPlay => 'Playlist';

  @override
  String get musicNote => 'Music Note';

  @override
  String get favorite => 'Favorite';

  @override
  String get libraryMusic => 'Library';

  @override
  String get tapToSelectFolder => 'Tap to select a folder with audio files';

  @override
  String get showVerticalSlider => 'Show Vertical Slider';

  @override
  String get showVerticalSliderSubtitle => 'Display vertical focus offset slider in player';

  @override
  String get transcriptionEnabled => 'Transcription enabled';

  @override
  String get transcriptionDisabled => 'Transcription disabled';

  @override
  String languageSelected(String language) {
    return 'Selected language: $language';
  }

  @override
  String get noTranslationsScanning => 'No translations found, scanning folder...';

  @override
  String translationsLoadedCount(int count) {
    return 'Loaded translations: $count';
  }

  @override
  String get translationsNotFound => 'No translations found for this song';

  @override
  String errorLoadingTranslations(String error) {
    return 'Error loading translations: $error';
  }

  @override
  String languageNotAvailable(String settingLang, String availableLang) {
    return '$settingLang selected in settings but not available. Opening: $availableLang';
  }

  @override
  String get errorAudioService => 'Audio Service Error';

  @override
  String get audioServiceFailed => 'Failed to initialize background audio playback.';

  @override
  String get notificationMayNotAppear => 'Player notification may not appear.';

  @override
  String get lrcAndTranslationsSaved => 'LRC and all translations saved!';

  @override
  String translationDeleted(String name) {
    return 'Translation \"$name\" deleted';
  }

  @override
  String failedToDeleteTranslation(String error) {
    return 'Failed to delete translation: $error';
  }

  @override
  String get generatingTranslations => 'Generating translations';

  @override
  String get generatingProcessing => 'Processing:';

  @override
  String get generatingLines => 'Lines:';

  @override
  String generatingLinesOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String generatingErrors(int count) {
    return 'Errors: $count';
  }

  @override
  String selectedLanguagesCountGen(int count) {
    return 'Selected: $count';
  }

  @override
  String get transcriptionSection => 'Transcription';

  @override
  String get translationsSection => 'Translations';

  @override
  String get translationLoadedSuccess => 'Translation loaded successfully!';

  @override
  String get exportSuccessful => 'Export successful!';

  @override
  String get failedToExportSong => 'Failed to export song';

  @override
  String get deleteTranslationTitle => 'Delete Translation';

  @override
  String deleteTranslationConfirm(String name) {
    return 'Are you sure you want to delete the \"$name\" translation?';
  }

  @override
  String get lrcLoaded => 'LRC file loaded';

  @override
  String get noFilesLoaded => 'No files loaded from archive';

  @override
  String failedToProcessArchive(String error) {
    return 'Failed to process archive: $error';
  }

  @override
  String failedToLoadTranslationsShort(String error) {
    return 'Failed to load translations: $error';
  }

  @override
  String get noFolderConfiguredMsg => 'No folder configured';

  @override
  String failedToPlaySongMsg(String error) {
    return 'Failed to play song: $error';
  }

  @override
  String addedSongsToPlaylistMsg(int count, String playlist) {
    return 'Added $count song(s) to \"$playlist\"';
  }

  @override
  String failedToAddSongsMsg(String error) {
    return 'Failed to add songs: $error';
  }

  @override
  String addSongsButton(int count) {
    return 'Add $count song(s)';
  }

  @override
  String get removeSong => 'Remove';

  @override
  String failedToRemoveSongMsg(String error) {
    return 'Failed to remove song: $error';
  }

  @override
  String failedToReorderSongsMsg(String error) {
    return 'Failed to reorder songs: $error';
  }

  @override
  String failedToLoadSongsMsg(String error) {
    return 'Failed to load songs: $error';
  }

  @override
  String errorLoadingText(String error) {
    return 'Error loading text: $error';
  }

  @override
  String lrcAndTranslationsLoaded(int count) {
    return 'LRC and $count translation(s) loaded';
  }

  @override
  String translationsOnlyLoaded(int count) {
    return '$count translation(s) loaded';
  }

  @override
  String get pleaseSetDeepSeekApiKey => 'Please set DeepSeek API key in settings';

  @override
  String get lyricsGeneratedSuccessfullyMsg => 'Lyrics generated successfully';

  @override
  String exportShareSubject(String title) {
    return 'LingoTune export: $title with lyrics and translations';
  }

  @override
  String get timestampOffset => 'Timestamp Offset';

  @override
  String get timestampOffsetSubtitle => 'Default offset in minutes for generated timestamps';

  @override
  String get resetTimestamps => 'Reset Timestamps';

  @override
  String get resetTimestampsConfirm => 'Reset all timestamps to default values?';

  @override
  String get resetTimestampsSuccess => 'Timestamps reset to default values';

  @override
  String get saveAfterReset => 'Save Changes';

  @override
  String get saveAfterResetConfirm => 'Save changes after resetting timestamps?';

  @override
  String get repeatOff => 'Repeat off';

  @override
  String get repeatAll => 'Repeat all';

  @override
  String get repeatOne => 'Repeat one';

  @override
  String get repeatAllPlaylists => 'Repeat all playlists';

  @override
  String get playFavoritesOnly => 'Play favorites only';

  @override
  String get noFavoriteSongs => 'No favorite songs yet';

  @override
  String get playbackSpeed => 'Playback Speed';

  @override
  String get speedNormal => 'Normal';

  @override
  String get lyricsPositionOffset => 'Lyrics Sync Delay';

  @override
  String get lyricsPositionOffsetSubtitle => 'Highlight delay in seconds (increase if highlight jumps ahead)';

  @override
  String get studyMode => 'Study';

  @override
  String get studyModeTooltip => 'Study mode: speak translation then play each line';

  @override
  String get studyModeStarted => 'Study mode started';

  @override
  String get studyModeStartedNoVoice => 'Study mode started (segments only — no voice)';

  @override
  String get ttsLangMissingTitle => 'No voice for this language';

  @override
  String get ttsLangMissingBody => 'Your device has no installed TTS voice for the translation language. Install a TTS engine with this language (e.g. Google or Yandex) under Settings → Text-to-speech, or continue in segments-only mode (no voiceover).';

  @override
  String get ttsContinueNoVoice => 'Continue without voice';

  @override
  String get studyModeStopped => 'Study mode stopped';

  @override
  String get studyModeNoLyrics => 'No timed lyrics for this song';

  @override
  String get studyModeSettings => 'Study Mode Settings';

  @override
  String get studyPerSongOverride => 'Custom settings for this song';

  @override
  String get studyPerSongOverrideSubtitle => 'When off, the app-wide defaults are used';

  @override
  String get studyModeOrder => 'Order';

  @override
  String get studyModeOrderTranslationFirst => 'Translation first';

  @override
  String get studyModeOrderOriginalFirst => 'Original first';

  @override
  String get studyModeOrderOverlay => 'Overlay (quiet original)';

  @override
  String get studyModeSpeechRate => 'Speech rate';

  @override
  String get studyModeSpeechVolume => 'Speech volume';

  @override
  String get studyModeLongPressHint => 'Long press for settings';

  @override
  String get exportCurrentSong => 'Export song';

  @override
  String get studyModeOverlayTiming => 'When to speak';

  @override
  String get studyModeOverlayAtStart => 'At line start';

  @override
  String get studyModeOverlayAtEnd => 'At line end';

  @override
  String get studyModeOverlayAtBoth => 'Start and end';

  @override
  String get studyModeDuckVolume => 'Original volume';

  @override
  String get studyModeTtsOffset => 'Speech timing offset';

  @override
  String get studyModeTtsOffsetHint => 'Negative — speak earlier, positive — later (sec). Overlay mode only';

  @override
  String get studyModeOpenSettings => 'Study mode settings';

  @override
  String get carDetectionTitle => 'Car Detection';

  @override
  String get carDetectionEnabled => 'Enabled';

  @override
  String get carDetectionDisabled => 'Disabled';

  @override
  String get carDetectionSensitivity => 'Sensitivity';

  @override
  String get carDetectionSensitivityHint => 'Higher = more alerts (may cause false positives). Lower = only strong signals.';

  @override
  String get carAlertSound => 'Sound alert';

  @override
  String get carAlertSoundSubtitle => 'Beep over the music';

  @override
  String get carAlertVibration => 'Vibration alert';

  @override
  String get carAlertVibrationSubtitle => 'Haptic feedback on detection';

  @override
  String get carAlertVoice => 'Voice alert';

  @override
  String get carAlertVoiceSubtitle => 'Spoken warning via TTS';

  @override
  String get carDetectionPrivacyNote => 'Audio is analyzed on-device only — nothing is recorded or sent anywhere.';

  @override
  String get carDetectionTooltip => 'Car detection via microphone';

  @override
  String get carDetectionStarted => 'Car detection started — listening for vehicles';

  @override
  String get carDetectionMicDenied => 'Microphone permission denied — cannot detect cars';

  @override
  String get carCalibrationTitle => 'Detector calibration';

  @override
  String get carCalibrationSubtitle => 'Train detector on your sounds';

  @override
  String get carCalibrationMicDenied => 'Microphone permission denied — calibration impossible';

  @override
  String get carCalibrationLive => 'Live spectrum';

  @override
  String get carCalibrationModeClassify => 'Mode: classify';

  @override
  String get carCalibrationModeThreshold => 'Mode: threshold';

  @override
  String carCalibrationNearest(String cls, String dist) {
    return 'Nearest: $cls (d=$dist)';
  }

  @override
  String get carCalibrationNoMatch => 'No match';

  @override
  String carCalibrationThresholdScore(String score) {
    return 'Score: $score';
  }

  @override
  String get carCalibrationRecordTitle => 'Record sample';

  @override
  String get carCalibrationClass => 'Class';

  @override
  String get carCalibrationName => 'Sample name';

  @override
  String get carCalibrationRecord => 'Record 5 sec';

  @override
  String carCalibrationRecording(int s) {
    return 'Recording... ${s}s';
  }

  @override
  String carCalibrationProfilesCount(int n) {
    return 'Profiles ($n)';
  }

  @override
  String get carCalibrationEmpty => 'No samples yet — record your first';

  @override
  String get carCalibrationDelete => 'Delete';

  @override
  String carCalibrationDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get carCalibrationReset => 'Reset all';

  @override
  String get carCalibrationResetConfirm => 'Delete all calibration profiles?';

  @override
  String get carCalibrationCancel => 'Cancel';

  @override
  String get carCalibrationConfirm => 'Delete';

  @override
  String get carCalibrationLoadDemo => 'Load demo profiles';

  @override
  String get carCalibrationDemoPrefix => 'Demo';

  @override
  String carCalibrationDemoLoaded(int n) {
    return 'Loaded $n demo profiles';
  }

  @override
  String get profileClassCarClose => 'Car close';

  @override
  String get profileClassCarFar => 'Car far';

  @override
  String get profileClassCarTruck => 'Truck';

  @override
  String get profileClassCarMotorcycle => 'Motorcycle';

  @override
  String get profileClassWind => 'Wind';

  @override
  String get profileClassSteps => 'Steps';

  @override
  String get profileClassVoice => 'Voice';

  @override
  String get profileClassStreet => 'Street';

  @override
  String get profileClassMusic => 'Music';

  @override
  String get profileClassOther => 'Other';

  @override
  String get ttsSource => 'TTS source';

  @override
  String get ttsSourceOffline => 'Offline';

  @override
  String get ttsSourceSystem => 'System';

  @override
  String get ttsSourceOfflineSubtitle => 'Built-in neural TTS (recommended, stable on all devices)';

  @override
  String get ttsSourceSystemSubtitle => 'Android system TTS engine';

  @override
  String get ttsSourceSwitchedHint => 'TTS source switched';

  @override
  String get voicePackages => 'Voice packages';

  @override
  String get voicePackagesSubtitle => 'Offline TTS models for languages';

  @override
  String get voicePackagesDescription => 'Download offline neural TTS models so speech works without internet and stays stable on any device. The Russian model is bundled with the app; others can be downloaded here.';

  @override
  String get voicePackageReady => 'Ready';

  @override
  String get voicePackageBundled => 'Bundled with the app';

  @override
  String get voicePackageDownload => 'Download';

  @override
  String get voicePackageInstall => 'Install';

  @override
  String get voicePackageRetry => 'Retry';

  @override
  String get voicePackageDownloading => 'Downloading...';

  @override
  String get voicePackageExtracting => 'Extracting...';

  @override
  String get voicePackageError => 'Error';

  @override
  String get voicePackageDelete => 'Delete';

  @override
  String voicePackageInstalledSuccess(Object lang) {
    return 'Model for \"$lang\" installed';
  }

  @override
  String voicePackageInstalledFailed(Object lang) {
    return 'Failed to install model for \"$lang\"';
  }

  @override
  String voicePackageDeleteConfirm(Object lang) {
    return 'Delete model for \"$lang\"? This frees up disk space.';
  }

  @override
  String get lyricColors => 'Line colors';

  @override
  String get lyricColorsTitle => 'Line colors';

  @override
  String get lyricColorsUseCustom => 'Custom colors';

  @override
  String get lyricColorsPresets => 'Presets';

  @override
  String get lyricColorsOriginal => 'Original';

  @override
  String get lyricColorsTranslation => 'Translation';

  @override
  String get lyricColorsActive => 'Active line';

  @override
  String get lyricColorsPreview => 'Preview';

  @override
  String get lyricColorsDone => 'Done';

  @override
  String get lyricPresetDefault => 'Default';

  @override
  String get lyricPresetBlueRed => 'Original blue / Translation red';

  @override
  String get lyricPresetRedBlue => 'Original red / Translation blue';

  @override
  String get lyricPresetGreenOrange => 'Original green / Translation orange';

  @override
  String get lyricPresetContrast => 'High contrast';

  @override
  String get renamePlaylist => 'Rename';

  @override
  String get renamePlaylistTitle => 'Rename playlist';

  @override
  String get playlistNameLabel => 'Playlist name';

  @override
  String get playlistRenamed => 'Playlist renamed';

  @override
  String get playlistNameExists => 'A playlist with this name already exists';

  @override
  String get noLyricsHint => 'This song has no lyrics yet';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get updateChecking => 'Checking for updates…';

  @override
  String get updateAvailableTitle => 'New version available';

  @override
  String updateCurrentVersion(Object version) {
    return 'Current version: $version';
  }

  @override
  String updateNewVersion(Object version) {
    return 'New version: $version';
  }

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get download => 'Download';

  @override
  String get later => 'Later';

  @override
  String get downloadingUpdate => 'Downloading update…';

  @override
  String get updateDownloaded => 'Update downloaded';

  @override
  String get install => 'Install';

  @override
  String get openReleasePage => 'Open release page';

  @override
  String get noUpdatesAvailable => '✓ You have the latest version';

  @override
  String get updateCheckFailed => 'Failed to check for updates';

  @override
  String get updateDownloadFailed => 'Failed to download the update';

  @override
  String get updateInstallFailed => 'Could not start the installation. Open the downloaded APK manually.';

  @override
  String get updateSource => 'Update source';

  @override
  String get updateSourceSubtitle => 'Default: Aila update center, GitHub Releases as backup; or set your own manifest URL (JSON with a version and an APK link) — https only';

  @override
  String get updateSourceDefault => 'Aila update center (default)';

  @override
  String get updateSourceDialogTitle => 'Update manifest URL';

  @override
  String get updateSourceHint => 'https://example.com/manifest.json';

  @override
  String get updateSourceReset => 'Reset';

  @override
  String get updateSourceSaved => 'Update source saved';

  @override
  String get updateSourceInvalid => 'Enter a valid https URL';

  @override
  String get updateSourceHttpBlocked => 'HTTP URLs are not supported: the app blocks unencrypted traffic. Use an https://… address';

  @override
  String get showEqualizerTooltip => 'Show equalizer instead of lyrics';

  @override
  String get showLyricsTooltip => 'Show song lyrics';

  @override
  String get abRepeatTooltipIdle => 'Repeat section (A–B)';

  @override
  String get abRepeatTooltipWaitEnd => 'Tap at the end of the section (B)';

  @override
  String get abRepeatTooltipActive => 'Section repeat running — tap to turn off';

  @override
  String get abRepeatStartSet => 'Section start A:';

  @override
  String get abRepeatActiveOn => 'Section repeat on:';

  @override
  String get abRepeatCleared => 'Section repeat off';

  @override
  String get abRepeatTooShort => 'Section too short — play at least 1 s further';

  @override
  String get abRepeatUnavailableStudy => 'Not available while study mode is active';
}
