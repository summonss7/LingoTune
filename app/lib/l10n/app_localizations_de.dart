// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Bibliothek';

  @override
  String get playlists => 'Playlists';

  @override
  String get settings => 'Einstellungen';

  @override
  String get allSongs => 'Alle Songs';

  @override
  String get favorites => 'Favoriten';

  @override
  String get createPlaylist => 'Playlist erstellen';

  @override
  String get playlistName => 'Playlist-Name';

  @override
  String get iconOptional => 'Symbol (optional)';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get close => 'Schließen';

  @override
  String get search => 'Suche';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sortieren';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get addToPlaylist => 'Zur Playlist hinzufügen';

  @override
  String get removeFromPlaylist => 'Aus Playlist entfernen';

  @override
  String get addSongsToLibrary => 'Songs aus Bibliothek hinzufügen';

  @override
  String get noSongsToAdd => 'Keine Songs zum Hinzufügen';

  @override
  String addButtonText(Object count) {
    return '$count hinzufügen';
  }

  @override
  String get selected => 'ausgewählt';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get lightMode => 'Heller Modus';

  @override
  String get autoScroll => 'Automatisches Scrollen';

  @override
  String get autoScrollSubtitle => 'Automatisch zur aktuellen Zeile scrollen';

  @override
  String get highlightNextLine => 'Nächste Zeile hervorheben';

  @override
  String get highlightNextLineSubtitle => 'Nächste Zeile mit subtiler Hervorhebung anzeigen';

  @override
  String get fontSize => 'Schriftgröße';

  @override
  String get scrollOffset => 'Scroll-Offset';

  @override
  String get scrollOffsetSubtitle => 'Abstand vom oberen Bildschirmrand in Pixel';

  @override
  String get autoScrollFocusOffset => 'Auto-Scroll-Fokus-Versatz';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Standard-Fokusposition für Auto-Scroll (Standard: +50)';

  @override
  String get defaultTranslationLanguage => 'Standard-Übersetzungssprache';

  @override
  String get defaultOriginalLanguage => 'Standardsprache für Original';

  @override
  String get russian => 'Russisch';

  @override
  String get english => 'Englisch';

  @override
  String get romanian => 'Rumänisch';

  @override
  String get french => 'Französisch';

  @override
  String get german => 'Deutsch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get italian => 'Italienisch';

  @override
  String get portuguese => 'Portugiesisch';

  @override
  String get lyricsFolder => 'Songtexte-Ordner';

  @override
  String get useLyricsFolder => 'Songtexte-Ordner verwenden';

  @override
  String get useLyricsFolderDisabled => 'Deaktiviert - Dateien müssen mit Audio ausgewählt werden';

  @override
  String get setLyricsFolder => 'Songtexte-Ordner festlegen';

  @override
  String get selectFolder => 'Ordner auswählen';

  @override
  String get folderPath => 'Ordnerpfad';

  @override
  String get examples => 'Beispiele:';

  @override
  String get defaultFolder => 'Standard: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Aktueller Ordner:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Ordner festgelegt: $path';
  }

  @override
  String get folderSetFailed => 'Ordner existiert nicht oder kein Zugriff';

  @override
  String get resetToDefault => 'Auf Standard zurücksetzen';

  @override
  String get showCurrentFolder => 'Aktuellen Ordner anzeigen';

  @override
  String get changeFolder => 'Ordner ändern';

  @override
  String get resetToDefaultFolder => 'Auf Standardordner zurücksetzen';

  @override
  String get folderReset => 'Auf Standardordner zurückgesetzt';

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get clearCacheSubtitle => 'Temporäre Dateien löschen';

  @override
  String get cacheCleared => 'Cache geleert';

  @override
  String get resetSongLanguages => 'Song-Sprachen zurücksetzen';

  @override
  String get resetSongLanguagesSubtitle => 'Standardsprache aus Einstellungen verwenden';

  @override
  String get songLanguagesReset => 'Song-Sprachen zurückgesetzt';

  @override
  String get about => 'Über';

  @override
  String get translationsLoaded => 'Übersetzungen erfolgreich geladen!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Übersetzungen konnten nicht geladen werden: $error';
  }

  @override
  String get editTranslations => 'Übersetzungen bearbeiten';

  @override
  String get loadTranslationsFromFile => 'Übersetzungen aus Datei laden';

  @override
  String get loadTextMenu => 'Text laden';

  @override
  String get loadTranslations => 'Übersetzungen laden';

  @override
  String get deleteTranslation => 'Übersetzung löschen';

  @override
  String get noFileSelected => 'Keine Datei ausgewählt';

  @override
  String get noLrcFileAssociated => 'Keine LRC-Datei mit diesem Song verknüpft';

  @override
  String get lrcFileSaved => 'LRC-Datei erfolgreich gespeichert!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'LRC-Datei konnte nicht gespeichert werden: $error';
  }

  @override
  String get exitEditMode => 'Bearbeitungsmodus beenden';

  @override
  String get editTimestamps => 'Zeitstempel bearbeiten';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get language => 'Sprache';

  @override
  String get loading => 'Laden...';

  @override
  String get noSongsFound => 'Keine Songs gefunden';

  @override
  String get noPlaylistsFound => 'Keine Playlists gefunden';

  @override
  String get selectSong => 'Wählen Sie einen Song zum Abspielen aus';

  @override
  String get song => 'Song';

  @override
  String get artist => 'Künstler';

  @override
  String get duration => 'Dauer';

  @override
  String get actions => 'Aktionen';

  @override
  String get play => 'Abspielen';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stopp';

  @override
  String get previous => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get rewind10 => '-10s';

  @override
  String get forward10 => '+10s';

  @override
  String get repeat => 'Wiederholen';

  @override
  String get shuffle => 'Zufällig';

  @override
  String get volume => 'Lautstärke';

  @override
  String get speed => 'Geschwindigkeit';

  @override
  String get lyrics => 'Songtexte';

  @override
  String get translations => 'Übersetzungen';

  @override
  String get originalText => 'Originaltext';

  @override
  String get translatedText => 'Übersetzter Text';

  @override
  String get showTranscription => 'Transkription anzeigen';

  @override
  String get showTranscriptionSubtitle => 'Aussprache-Anleitung anzeigen';

  @override
  String get showTranslationFirst => 'Übersetzung zuerst';

  @override
  String get showTranslationFirstSubtitle => 'Übersetzung vor dem Originaltext anzeigen';

  @override
  String get italianLang => 'Italienisch';

  @override
  String get portugueseLang => 'Portugiesisch';

  @override
  String get lyricsEditor => 'Songtext-Editor';

  @override
  String get addLine => 'Zeile hinzufügen';

  @override
  String get updateLine => 'Zeile aktualisieren';

  @override
  String get deleteLine => 'Zeile löschen';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get moveUp => 'Nach oben';

  @override
  String get moveDown => 'Nach unten';

  @override
  String get autoSyncLyrics => 'Automatische Songtext-Synchronisation';

  @override
  String get exportLrc => 'LRC exportieren (Original)';

  @override
  String get exportJson => 'JSON exportieren (Übersetzungen)';

  @override
  String get markTimestamp => 'Zeitstempel markieren (Eingabe)';

  @override
  String get original => 'Original';

  @override
  String get translation => 'Übersetzung';

  @override
  String get audioFile => 'Audiodatei';

  @override
  String get songTitle => 'Songtitel';

  @override
  String get browse => 'Durchsuchen';

  @override
  String get audioControls => 'Audio-Steuerelemente';

  @override
  String get addEditLine => 'Zeile hinzufügen/bearbeiten';

  @override
  String get instructions => 'Anweisungen';

  @override
  String get lyricsEditorInstructions => 'LRC-Synchronisierungsanweisungen:\n\n1. Wählen Sie eine Audiodatei mit dem Button Durchsuchen\n2. Geben Sie Songtitel und Künstler ein (optional)\n3. Klicken Sie auf Abspielen um Audio zu starten\n4. Wenn eine Zeile gesungen wird, geben Sie den Originaltext im Feld \'Original\' ein\n5. Drücken Sie Eingabe oder \'Zeitstempel markieren\' um den Zeitstempel aufzuzeichnen\n6. Optional fügen Sie eine Übersetzung im Feld \'Übersetzung\' hinzu\n7. Wiederholen Sie Schritte 4-6 für jede Zeile\n8. Verwenden Sie \'LRC exportieren\' um Originaltext mit Zeitstempeln zu speichern\n9. Verwenden Sie \'JSON exportieren\' um Übersetzungen zu speichern\n\nTipps:\n- Verwenden Sie -10s/+10s um schnell durch den Song zu navigieren\n- Sie können Zeilen mit Nach oben/Unten neu anordnen\n- Laden Sie zuvor gespeicherte JSON-Dateien um Übersetzungen zu bearbeiten';

  @override
  String get welcome => 'Willkommen';

  @override
  String get welcomeMessage => 'Beginnen Sie Ihre Sprachlernreise mit Musik!';

  @override
  String get importSongs => 'Songs importieren';

  @override
  String get importSongsSubtitle => 'Audiodateien von Ihrem Gerät hinzufügen';

  @override
  String get manageLibrary => 'Bibliothek verwalten';

  @override
  String get manageLibrarySubtitle => 'Organisieren Sie Ihre Songs und Playlists';

  @override
  String get syncLyrics => 'Songtexte synchronisieren';

  @override
  String get syncLyricsSubtitle => 'Automatische Synchronisation von Songtexten mit Audio';

  @override
  String get languageLearning => 'Sprachenlernen • Musik • Übersetzungen';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Entwickelt von';

  @override
  String get website => 'Website';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Playlist konnte nicht erstellt werden: $error';
  }

  @override
  String get playlistCreated => 'Playlist erfolgreich erstellt!';

  @override
  String get playlistDeleted => 'Playlist erfolgreich gelöscht!';

  @override
  String get playlistUpdated => 'Playlist erfolgreich aktualisiert!';

  @override
  String get songAdded => 'Song erfolgreich hinzugefügt!';

  @override
  String get songRemoved => 'Song erfolgreich entfernt!';

  @override
  String get songDeleted => 'Song erfolgreich gelöscht!';

  @override
  String get error => 'Fehler';

  @override
  String get warning => 'Warnung';

  @override
  String get info => 'Info';

  @override
  String get success => 'Erfolg';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get areYouSure => 'Sind Sie sicher?';

  @override
  String get unsavedChanges => 'Sie haben ungespeicherte Änderungen. Fortfahren?';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get appLanguage => 'App-Sprache';

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
  String get welcomeToLingoTune => 'Willkommen bei LingoTune';

  @override
  String get folderSetupMessage => 'Wählen Sie einen Ordner um Songtexte und Übersetzungen zu speichern (LRC und JSON Dateien). Dies erleichtert die Organisation Ihrer Musikbibliothek.';

  @override
  String get selectFolderNow => 'Ordner jetzt auswählen';

  @override
  String get goToSettings => 'Zu Einstellungen gehen';

  @override
  String get setupLater => 'Später einrichten';

  @override
  String get useDefaultFolder => 'Standardordner verwenden';

  @override
  String get databaseFound => 'Datenbank in Importdatei gefunden';

  @override
  String get importDatabaseQuestion => 'Möchten Sie auch die Datenbank importieren?';

  @override
  String get mergeDatabase => 'Zusammenführen';

  @override
  String get replaceDatabase => 'Ersetzen';

  @override
  String get importDatabase => 'Datenbank importieren';

  @override
  String get skipDatabase => 'Datenbank überspringen';

  @override
  String get mergeDatabaseDescription => 'Importierte Songs mit Ihrer Bibliothek zusammenführen (fügt nur neue Elemente hinzu)';

  @override
  String get replaceDatabaseDescription => 'Ersetzen Sie Ihre gesamte Bibliothek mit der importierten Datenbank (Sie verlieren alle vorhandenen Daten)';

  @override
  String get exporting => 'Exportieren...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Exportiere $current von $total Songs';
  }

  @override
  String get exportDatabaseIncluded => 'Datenbank im Export enthalten';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return '$fileCount Datei(en) und Datenbank importiert';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return '$fileCount Datei(en) importiert';
  }

  @override
  String get chinese => 'Chinesisch';

  @override
  String get arabic => 'Arabisch';

  @override
  String get colorTheme => 'Farbschema';

  @override
  String get themeColorPurple => 'Lila';

  @override
  String get themeColorBlue => 'Blau';

  @override
  String get themeColorGreen => 'Grün';

  @override
  String get themeColorOrange => 'Orange';

  @override
  String get themeColorRed => 'Rot';

  @override
  String get themeColorPink => 'Rosa';

  @override
  String get themeColorDeepOrange => 'Dunkelorange';

  @override
  String get themeColorDarkRed => 'Dunkelrot';

  @override
  String get themeColorTeal => 'Türkis';

  @override
  String get themeColorCyan => 'Cyan';

  @override
  String get themeColorAmber => 'Bernstein';

  @override
  String get themeColorLime => 'Limette';

  @override
  String get ukrainianLang => 'Ukrainisch';

  @override
  String get font => 'Schriftart';

  @override
  String get fontSettings => 'Schriftarteinstellungen';

  @override
  String get systemFont => 'System';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Haupttextgröße';

  @override
  String get mainTextBold => 'Haupttext fett';

  @override
  String get translationSize => 'Übersetzungsgröße';

  @override
  String get translationBold => 'Übersetzung fett';

  @override
  String get transcriptSize => 'Transkriptionsgröße';

  @override
  String get transcriptBold => 'Transkription fett';

  @override
  String get defaultStartScreen => 'Standard-Startbildschirm';

  @override
  String get defaultStartScreenSubtitle => 'Bildschirm, der beim App-Start angezeigt wird';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Zur Bibliothek hinzufügen beim Hinzufügen zu Wiedergabeliste';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Songs automatisch zur Bibliothek hinzufügen, wenn sie zu einer Wiedergabeliste hinzugefügt werden';

  @override
  String get serviceMessages => 'Dienstnachrichten';

  @override
  String get serviceMessagesSubtitle => 'Dienstbenachrichtigungen zu Übersetzung und Transkription anzeigen';

  @override
  String get includeMp3Files => 'MP3-Dateien einschließen';

  @override
  String get includeMp3FilesSubtitle => 'Dies vergrößert die Archivgröße';

  @override
  String get importMp3Files => 'MP3-Dateien importieren';

  @override
  String get importMp3FilesSubtitle => 'Musikdateien zur Bibliothek hinzufügen';

  @override
  String get exportSongs => 'Songs exportieren';

  @override
  String get import => 'Importieren';

  @override
  String get addMultiple => 'Mehrere auswählen';

  @override
  String get addToPlaylistShort => 'Hinzufügen';

  @override
  String get deleteShort => 'Löschen';

  @override
  String get selectAllShort => 'Alle';

  @override
  String get deselectAllShort => 'Löschen';

  @override
  String get exitSelectionMode => 'Auswahlmodus beenden';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get deselectAll => 'Auswahl aufheben';

  @override
  String get deleteSelected => 'Ausgewählte löschen';

  @override
  String get addMultipleToPlaylist => 'Zur Playlist hinzufügen';

  @override
  String get coverArt => 'Cover-Bild';

  @override
  String get playlistCover => 'Playlist-Cover';

  @override
  String get selectFromGallery => 'Aus Galerie auswählen';

  @override
  String get removeCover => 'Cover entfernen';

  @override
  String get coverUpdated => 'Cover aktualisiert';

  @override
  String get coverRemoved => 'Cover entfernt';

  @override
  String errorWithMessage(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get importFolders => 'Ordner importieren';

  @override
  String get selectMusicFolder => 'Musikordner auswählen';

  @override
  String get folderWithAudioFiles => 'Ordner mit MP3/WAV-Dateien';

  @override
  String get sameFolderForLyrics => 'Gleicher Ordner für Liedtexte';

  @override
  String get selectLyricsFolder => 'Liedtextordner auswählen';

  @override
  String get folderWithLyricsFiles => 'Ordner mit LRC/JSON-Dateien (optional)';

  @override
  String get pleaseEnterPlaylistName => 'Bitte geben Sie einen Playlist-Namen ein';

  @override
  String get pleaseSelectMusicFolder => 'Bitte wählen Sie einen Musikordner aus';

  @override
  String get cropImage => 'Bild zuschneiden';

  @override
  String get photoPermissionRequired => 'Fotozugriffsberechtigung erforderlich';

  @override
  String get photoPermissionDenied => 'Zugriff auf Fotos verweigert';

  @override
  String get imageProcessingError => 'Bildverarbeitung fehlgeschlagen';

  @override
  String get scanningFolder => 'Ordner wird gescannt...';

  @override
  String get importingFiles => 'Dateien werden importiert...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Importiere $current/$total Dateien... $songs Songs gefunden';
  }

  @override
  String processingFile(Object file) {
    return 'Verarbeite $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Zur Playlist hinzufügen';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Zu \"$playlist\" hinzugefügt';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Fehler beim Hinzufügen zur Playlist: $error';
  }

  @override
  String get deleteSong => 'Löschen';

  @override
  String get importSongDialogTitle => 'Song importieren';

  @override
  String get audioOnly => 'Nur Audio';

  @override
  String get addLyricsLater => 'Texte später hinzufügen';

  @override
  String get audioWithLyricsZIP => 'Audio + ZIP mit Texten';

  @override
  String get importWithAllTranslations => 'Mit allen Übersetzungen importieren';

  @override
  String get importTranslationDialogTitle => 'Übersetzung hinzufügen';

  @override
  String get loadTranslationFromZip => 'Aus ZIP-Archiv laden';

  @override
  String get loadTranslationFromJson => 'Aus JSON-Datei laden';

  @override
  String get noAudioFilesSelected => 'Keine Audiodateien ausgewählt';

  @override
  String failedToImportSongs(Object error) {
    return 'Songs konnten nicht importiert werden: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Song konnte nicht importiert werden: $error';
  }

  @override
  String get musicFolderNotSelected => 'Musikordner nicht ausgewählt';

  @override
  String get generateLyrics => 'Liedtexte generieren';

  @override
  String get selectTextFileOrEnterText => 'Textdatei auswählen oder Text eingeben';

  @override
  String get originalLanguage => 'Originalsprache';

  @override
  String get translationLanguages => 'Übersetzungssprachen';

  @override
  String get startMinuteForTimestamps => 'Startminute für Zeitstempel';

  @override
  String get transcriptionLanguage => 'Transkriptionssprache';

  @override
  String get generating => 'Generierung...';

  @override
  String get generate => 'Generieren';

  @override
  String get deepseekApiKey => 'DeepSeek API-Schlüssel';

  @override
  String get validateKey => 'Schlüssel validieren';

  @override
  String get keyIsValid => 'Schlüssel ist gültig';

  @override
  String get keyIsInvalid => 'Schlüssel ist ungültig';

  @override
  String get lyricsGenerationSuccess => 'Liedtexte erfolgreich generiert';

  @override
  String get lyricsGenerationError => 'Fehler beim Generieren der Liedtexte';

  @override
  String get savingFiles => 'Dateien werden gespeichert...';

  @override
  String get enterText => 'Text eingeben';

  @override
  String get transcript => 'Transkription';

  @override
  String get originalTextEditable => 'Originaltext (bearbeitbar)';

  @override
  String get selectLanguageToEdit => 'Sprache zum Bearbeiten auswählen';

  @override
  String get moveLineUp => 'Zeile nach oben verschieben';

  @override
  String get moveLineDown => 'Zeile nach unten verschieben';

  @override
  String get moveAllTranslationsUp => 'Alle Übersetzungen nach oben verschieben';

  @override
  String get moveAllTranslationsDown => 'Alle Übersetzungen nach unten verschieben';

  @override
  String get translationSaved => 'Übersetzung gespeichert!';

  @override
  String get translationSaveFailed => 'Übersetzung konnte nicht gespeichert werden';

  @override
  String get loadTextTitle => 'Text laden';

  @override
  String get noOriginalTextWarning => 'Bitte laden Sie zuerst den Originaltext';

  @override
  String get selectLanguageOriginal => 'Originalsprache';

  @override
  String get startTimestampMinutes => 'Startzeitstempel (Minuten)';

  @override
  String get selectLanguageTranslation => 'Übersetzungssprache';

  @override
  String get originalTextLoaded => 'Originaltext erfolgreich geladen!';

  @override
  String get translationLoaded => 'Übersetzung erfolgreich geladen!';

  @override
  String get transcriptLoaded => 'Transkription erfolgreich geladen!';

  @override
  String get selectTranslationLanguage => 'Übersetzungssprache für Transkription';

  @override
  String get noTranslationWarning => 'Keine Übersetzungen geladen';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Zeilen stimmen nicht überein: $loaded Zeilen, erwartet $expected';
  }

  @override
  String get loadTextTooltip => 'Text oder Übersetzung laden';

  @override
  String get loadFromFile => 'Aus Datei laden';

  @override
  String get pasteFromClipboard => 'Aus Zwischenablage einfügen';

  @override
  String get audioNotificationService => 'Audio-Benachrichtigungsdienst';

  @override
  String get audioNotificationServiceActive => 'Status: ✅ Aktiv';

  @override
  String get audioNotificationServiceError => 'Status: ❌ Fehler';

  @override
  String get errorLabel => 'Fehler:';

  @override
  String get audioNotificationServiceDescription => 'Dieser Dienst liefert Benachrichtigungen, wenn die App minimiert ist';

  @override
  String get reorder => 'Ordnen';

  @override
  String get done => 'Fertig';

  @override
  String get selectMultiple => 'Mehrere auswählen';

  @override
  String get sortSongs => 'Songs sortieren';

  @override
  String get importSong => 'Song importieren';

  @override
  String get sortDefault => 'Standard';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Neueste';

  @override
  String get sortDateAsc => 'Älteste';

  @override
  String get importingSongs => 'Songs werden importiert...';

  @override
  String get noSongsInPlaylist => 'Keine Songs in dieser Playlist';

  @override
  String get addSongsFromLibraryHint => 'Songs aus Ihrer Bibliothek hinzufügen';

  @override
  String get removedSongsFromPlaylist => 'Songs aus Playlist entfernt';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Songs konnten nicht gelöscht werden: $error';
  }

  @override
  String get deletePlaylistTitle => 'Playlist löschen';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'Möchten Sie \"$playlist\" wirklich löschen?';
  }

  @override
  String get failedToDeletePlaylist => 'Playlist konnte nicht gelöscht werden:';

  @override
  String get specifyTranslationLanguage => 'Übersetzungssprache angeben';

  @override
  String get languageNameLabel => 'Sprachname';

  @override
  String get languageNameHint => 'Zum Beispiel: Russisch, Autorisch, Poetisch';

  @override
  String get translationTypeLabel => 'Übersetzungstyp:';

  @override
  String get translationTypeNormal => 'Normal';

  @override
  String get translationTypeAuthor => 'Autorisch';

  @override
  String get translationTypePoetic => 'Poetisch';

  @override
  String get translationTypeLiteral => 'Wörtlich';

  @override
  String mp3FilesCount(Object count) {
    return 'MP3-Dateien: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return '$count Datei(en) importiert (Datenbank übersprungen)';
  }

  @override
  String get databaseMerged => 'Datenbank zusammengeführt';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'Datenbank zusammengeführt, MP3-Dateien: $count';
  }

  @override
  String get databaseReplaced => 'Datenbank ersetzt';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'Datenbank ersetzt, MP3-Dateien: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Ersetzung bestätigen';

  @override
  String get confirmReplaceDatabaseWarning => 'Sind Sie sicher? Sie verlieren alle vorhandenen Songs und Playlists!';

  @override
  String get replaceAll => 'Alle ersetzen';

  @override
  String get selectLanguages => 'Sprachen auswählen';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Ausgewählt: $count Sprachen';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Ausgewählt: $count';
  }

  @override
  String get promptPreset => 'Prompt-Voreinstellung';

  @override
  String get balanced => 'Ausgewogen';

  @override
  String get poetic => 'Poetisch';

  @override
  String get literal => 'Wörtlich';

  @override
  String get customPromptOption => 'Benutzerdefiniert...';

  @override
  String get editPrompt => 'Prompt bearbeiten';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get showOrEditApiKey => 'API-Schlüssel anzeigen/bearbeiten';

  @override
  String get timeout => 'Zeitüberschreitung';

  @override
  String get model => 'Modell';

  @override
  String get resetToPreset => 'Auf Voreinstellung zurücksetzen';

  @override
  String get customPrompt => 'Benutzerdefinierter Prompt';

  @override
  String customPromptChars(Object count) {
    return 'Benutzerdefinierter Prompt ($count Zeichen)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Voreinstellung verwenden: $preset';
  }

  @override
  String get characters => 'Zeichen';

  @override
  String get deepSeekPromptTitle => 'DeepSeek-Prompt';

  @override
  String get customPromptLabel => 'Benutzerdefinierter Prompt';

  @override
  String get leaveEmptyToUseDefault => 'Leer lassen, um Standard-Prompt zu verwenden';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Leer lassen, um den in die App integrierten Standard-Prompt zu verwenden';

  @override
  String get apiKeySaved => 'API-Schlüssel gespeichert';

  @override
  String get enterTimeout => 'Zeitüberschreitung in Sekunden eingeben';

  @override
  String get validTimeoutRange => 'Bitte geben Sie eine gültige Zeitüberschreitung ein (1-3600 Sekunden)';

  @override
  String get customTimeout => 'Benutzerdefinierte Zeitüberschreitung';

  @override
  String get timeoutSeconds => 'Zeitüberschreitung (Sekunden)';

  @override
  String timeoutSetTo(Object value) {
    return 'Zeitüberschreitung auf $value Sekunden eingestellt';
  }

  @override
  String get customModel => 'Benutzerdefiniertes Modell';

  @override
  String get modelName => 'Modellname';

  @override
  String get enterModelName => 'Geben Sie den exakten Modellnamen ein, der von DeepSeek API bereitgestellt wird';

  @override
  String get pleaseEnterModelName => 'Bitte geben Sie einen Modellnamen ein';

  @override
  String modelSetTo(Object value) {
    return 'Modell auf $value eingestellt';
  }

  @override
  String get editCustomPrompt => 'Benutzerdefinierten Prompt bearbeiten';

  @override
  String get editPresetPrompt => 'Voreinstellungs-Prompt bearbeiten';

  @override
  String get editingPreset => 'Voreinstellung bearbeiten';

  @override
  String get anyChangesSaveAsCustom => 'Änderungen werden als benutzerdefinierter Prompt gespeichert. Verwenden Sie die Schaltfläche \'Zurücksetzen\', um die ursprüngliche Voreinstellung wiederherzustellen.';

  @override
  String get useResetToRestorePreset => 'Verwenden Sie die Schaltfläche \'Zurücksetzen\', um die ursprüngliche Voreinstellung wiederherzustellen';

  @override
  String get prompt => 'Prompt';

  @override
  String get promptSaved => 'Prompt gespeichert';

  @override
  String get usingPresetPrompt => 'Voreinstellungs-Prompt verwenden';

  @override
  String get apiKeyHint => 'API-Schlüssel';

  @override
  String get modelHint => 'z.B. deepseek-v3';

  @override
  String get enterExactModelName => 'Geben Sie den exakten Modellnamen ein, der von DeepSeek API bereitgestellt wird.';

  @override
  String get pleaseEnterApiKeyFirst => 'Bitte geben Sie zuerst den API-Schlüssel ein';

  @override
  String get maxTokensRegular => 'Max Tokens (Normal)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Token-Limit für normale Übersetzungsanfragen';

  @override
  String get maxTokensJsonHint => 'Token-Limit für vollständige Generierungsanfragen (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (normal) eingestellt auf $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) eingestellt auf $value';
  }

  @override
  String get refreshFolder => 'Ordner aktualisieren';

  @override
  String get refreshingFolder => 'Ordner wird aktualisiert...';

  @override
  String get playlistCreatedWithLink => 'Playlist erstellt! Drücken Sie \"Aktualisieren\", um Songs aus dem Ordner zu laden';

  @override
  String refreshedPlaylist(Object count) {
    return 'Aktualisiert: $count Songs';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Aktualisierungsfehler: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Songs konnten nicht geladen werden: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'Musikordner existiert nicht';

  @override
  String successfullyImportedSongs(Object count) {
    return 'Erfolgreich $count Song(s) importiert';
  }

  @override
  String get noAudioFileSelected => 'Keine Audiodatei ausgewählt';

  @override
  String get noZipArchiveSelected => 'Kein ZIP-Archiv ausgewählt';

  @override
  String get noFolderConfigured => 'Kein Ordner konfiguriert';

  @override
  String get missingLyricsTranslations => 'Songtexte/Übersetzungen fehlen';

  @override
  String missingForSong(Object songName) {
    return 'Für \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Fehlend: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'Was möchten Sie tun?';

  @override
  String get lyricsGeneratedSuccessfully => 'Songtexte erfolgreich generiert';

  @override
  String get setDeepSeekApiKey => 'Bitte DeepSeek API-Schlüssel in den Einstellungen festlegen';

  @override
  String failedToOpenSong(Object error) {
    return 'Song konnte nicht geöffnet werden: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'Auch LRC- und JSON-Dateien löschen';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Zu \"$playlist\" hinzugefügt';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Fehler beim Hinzufügen zur Playlist: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return '$count Songs exportiert';
  }

  @override
  String get fileNotFound => 'Datei nicht gefunden';

  @override
  String get selectZipFileNotJson => 'Bitte eine ZIP-Datei auswählen, nicht JSON oder LRC';

  @override
  String get noFilesFoundInZip => 'Keine Dateien im ZIP-Archiv gefunden';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Ungültiges ZIP-Dateiformat: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return '$count Übersetzung(en) gefunden';
  }

  @override
  String mp3ImportError(Object error) {
    return 'MP3-Importfehler: $error';
  }

  @override
  String get importSongFirstToSearch => 'Importieren Sie zuerst einen Song, um nach Songtexten zu suchen';

  @override
  String get lyricsFetched => 'Songtexte abgerufen';

  @override
  String get lyricsFoundUseCreate => 'Songtexte gefunden! Verwenden Sie sie zum Erstellen einer synchronisierten LRC-Datei';

  @override
  String get deleteSelectedSongs => 'Ausgewählte Songs löschen';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'Sind Sie sicher, dass Sie $count Song(s) löschen möchten?';
  }

  @override
  String get songsDeletedSuccessfully => 'Songs erfolgreich gelöscht';

  @override
  String get storagePermissionRequired => 'Speicherberechtigung ist erforderlich, um auf Ordner zuzugreifen.';

  @override
  String get enableStoragePermission => 'Bitte aktivieren Sie die Speicherberechtigung in den App-Einstellungen.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get unableToSelectFolder => 'Ordner konnte nicht ausgewählt werden. Bitte Alternative versuchen:';

  @override
  String get selectFilesInstead => 'Stattdessen Dateien auswählen';

  @override
  String get enterFolderPath => 'Bitte geben Sie einen Ordnerpfad ein';

  @override
  String get folderDoesNotExist => '✗ Ordner existiert nicht';

  @override
  String folderSetWithPath(Object path) {
    return 'Ordner festgelegt: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Fehler beim Festlegen des Ordners: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'Songtextordner konnte nicht ausgewählt werden. Bitte Alternative versuchen:';

  @override
  String get useManualPath => 'Manuellen Pfad verwenden (für Tests)';

  @override
  String get enterFolderPathManually => 'Ordnerpfad manuell eingeben statt Ordnerauswahl zu verwenden';

  @override
  String get folderPathLabel => 'Ordnerpfad';

  @override
  String get folderPathHint => 'Beispiel: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Vollständiger Pfad zu Ihrem Musikordner';

  @override
  String get setPath => 'Pfad festlegen';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'ZIP-Archiv mit Songtexten für \"$title\" auswählen';
  }

  @override
  String get skip => 'Überspringen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get failedToCopyLrcFile => 'LRC-Datei konnte nicht kopiert werden';

  @override
  String copiedJsonFiles(Object count) {
    return '$count JSON-Datei(en) kopiert';
  }

  @override
  String get failedToCopyJsonFiles => 'JSON-Dateien konnten nicht kopiert werden';

  @override
  String failedToDeleteSong(Object error) {
    return 'Song konnte nicht gelöscht werden: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return '$count Song(s) zu \"$playlist\" hinzugefügt';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return '$count Song(s) zur Playlist hinzufügen';
  }

  @override
  String get failedToExportSongs => 'Songs konnten nicht exportiert werden';

  @override
  String get ok => 'OK';

  @override
  String deleteSongConfirm(Object song) {
    return 'Sind Sie sicher, dass Sie \"$song\" löschen möchten?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Musikordner für diese Playlist auswählen';

  @override
  String get folderLinkedToPlaylist => 'Ordner mit Playlist verknüpft';

  @override
  String get folderUnlinkedFromPlaylist => 'Ordner von Playlist getrennt';

  @override
  String get checkFolderAccess => 'Ordnerzugriff prüfen';

  @override
  String get checkingPermissions => 'Berechtigungen werden überprüft...';

  @override
  String get folderAccessible => '✓ Ordner zugreifbar';

  @override
  String get folderNotAccessible => '✗ Ordner nicht zugreifbar';

  @override
  String audioFilesFound(Object count) {
    return '$count Audiodatei(en) gefunden';
  }

  @override
  String lyricsFound(Object count) {
    return '$count Liedtextdatei(en) gefunden';
  }

  @override
  String get noAudioFiles => 'Keine Audiodateien gefunden';

  @override
  String get noLyricsFiles => 'Keine Liedtextdateien gefunden';

  @override
  String errorCheckingAccess(Object error) {
    return 'Fehler beim Überprüfen des Ordnerzugriffs: $error';
  }

  @override
  String get folderPathColon => 'Ordnerpfad:';

  @override
  String get permissionsStatus => 'Berechtigungsstatus:';

  @override
  String get folderContent => 'Ordnerinhalt:';

  @override
  String get accessGranted => '✓ Zugriff gewährt';

  @override
  String get accessDenied => '✗ Zugriff verweigert';

  @override
  String get permissionRequestFailed => 'Berechtigungsanfrage fehlgeschlagen';

  @override
  String get pleaseGrantPermissions => 'Bitte erteilen Sie Speicherberechtigungen, um den Ordner zu prüfen';

  @override
  String get refreshOnlySongs => 'Nur Songs';

  @override
  String get refreshEverything => 'Alles';

  @override
  String get refreshDialogDescription => 'Was möchten Sie aktualisieren? \"Nur Songs\" beschleunigt den Prozess, indem Liedtexte übersprungen werden.';

  @override
  String get mostSongs => 'Meiste Songs';

  @override
  String get playlistPlay => 'Wiedergabeliste';

  @override
  String get musicNote => 'Musiknote';

  @override
  String get favorite => 'Favorit';

  @override
  String get libraryMusic => 'Bibliothek';

  @override
  String get tapToSelectFolder => 'Tippen Sie, um einen Ordner mit Audiodateien auszuwählen';

  @override
  String get showVerticalSlider => 'Vertikaler Slider';

  @override
  String get showVerticalSliderSubtitle => 'Vertikalen Fokus-Verschiebungs-Slider im Player anzeigen';

  @override
  String get transcriptionEnabled => 'Transkription aktiviert';

  @override
  String get transcriptionDisabled => 'Transkription deaktiviert';

  @override
  String languageSelected(String language) {
    return 'Ausgewählte Sprache: $language';
  }

  @override
  String get noTranslationsScanning => 'Keine Übersetzungen gefunden, Ordner wird durchsucht...';

  @override
  String translationsLoadedCount(int count) {
    return 'Übersetzungen geladen: $count';
  }

  @override
  String get translationsNotFound => 'Keine Übersetzungen für dieses Lied gefunden';

  @override
  String errorLoadingTranslations(String error) {
    return 'Fehler beim Laden der Übersetzungen: $error';
  }

  @override
  String languageNotAvailable(String settingLang, String availableLang) {
    return '$settingLang in den Einstellungen ausgewählt, aber nicht verfügbar. Öffne: $availableLang';
  }

  @override
  String get errorAudioService => 'Audio Service Fehler';

  @override
  String get audioServiceFailed => 'Hintergrund-Audiowiedergabe konnte nicht initialisiert werden.';

  @override
  String get notificationMayNotAppear => 'Player-Benachrichtigung wird möglicherweise nicht angezeigt.';

  @override
  String get lrcAndTranslationsSaved => 'LRC und alle Übersetzungen gespeichert!';

  @override
  String translationDeleted(String name) {
    return 'Übersetzung \"$name\" gelöscht';
  }

  @override
  String failedToDeleteTranslation(String error) {
    return 'Fehler beim Löschen der Übersetzung: $error';
  }

  @override
  String get generatingTranslations => 'Übersetzungen werden generiert';

  @override
  String get generatingProcessing => 'Verarbeitung:';

  @override
  String get generatingLines => 'Zeilen:';

  @override
  String generatingLinesOf(int current, int total) {
    return '$current von $total';
  }

  @override
  String generatingErrors(int count) {
    return 'Fehler: $count';
  }

  @override
  String selectedLanguagesCountGen(int count) {
    return 'Ausgewählt: $count';
  }

  @override
  String get transcriptionSection => 'Transkription';

  @override
  String get translationsSection => 'Übersetzungen';

  @override
  String get translationLoadedSuccess => 'Übersetzung erfolgreich geladen!';

  @override
  String get exportSuccessful => 'Export erfolgreich!';

  @override
  String get failedToExportSong => 'Song konnte nicht exportiert werden';

  @override
  String get deleteTranslationTitle => 'Übersetzung löschen';

  @override
  String deleteTranslationConfirm(String name) {
    return 'Übersetzung \"$name\" wirklich löschen?';
  }

  @override
  String get lrcLoaded => 'LRC-Datei geladen';

  @override
  String get noFilesLoaded => 'Keine Dateien aus dem Archiv geladen';

  @override
  String failedToProcessArchive(String error) {
    return 'Fehler beim Verarbeiten des Archivs: $error';
  }

  @override
  String failedToLoadTranslationsShort(String error) {
    return 'Laden fehlgeschlagen: $error';
  }

  @override
  String get noFolderConfiguredMsg => 'Kein Ordner konfiguriert';

  @override
  String failedToPlaySongMsg(String error) {
    return 'Wiedergabe fehlgeschlagen: $error';
  }

  @override
  String addedSongsToPlaylistMsg(int count, String playlist) {
    return '$count Song(s) zu \"$playlist\" hinzugefügt';
  }

  @override
  String failedToAddSongsMsg(String error) {
    return 'Fehler beim Hinzufügen: $error';
  }

  @override
  String addSongsButton(int count) {
    return '$count hinzufügen';
  }

  @override
  String get removeSong => 'Entfernen';

  @override
  String failedToRemoveSongMsg(String error) {
    return 'Fehler beim Entfernen: $error';
  }

  @override
  String failedToReorderSongsMsg(String error) {
    return 'Fehler beim Sortieren: $error';
  }

  @override
  String failedToLoadSongsMsg(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String errorLoadingText(String error) {
    return 'Fehler beim Laden des Textes: $error';
  }

  @override
  String lrcAndTranslationsLoaded(int count) {
    return 'LRC und $count Übersetzung(en) geladen';
  }

  @override
  String translationsOnlyLoaded(int count) {
    return '$count Übersetzung(en) geladen';
  }

  @override
  String get pleaseSetDeepSeekApiKey => 'Bitte DeepSeek API-Schlüssel in den Einstellungen setzen';

  @override
  String get lyricsGeneratedSuccessfullyMsg => 'Songtexte erfolgreich generiert';

  @override
  String exportShareSubject(String title) {
    return 'LingoTune Export: $title mit Lyrics und Übersetzungen';
  }

  @override
  String get timestampOffset => 'Zeitstempel-Versatz';

  @override
  String get timestampOffsetSubtitle => 'Standardversatz in Minuten für generierte Zeitstempel';

  @override
  String get resetTimestamps => 'Zeitstempel zurücksetzen';

  @override
  String get resetTimestampsConfirm => 'Alle Zeitstempel auf Standardwerte zurücksetzen?';

  @override
  String get resetTimestampsSuccess => 'Zeitstempel auf Standardwerte zurückgesetzt';

  @override
  String get saveAfterReset => 'Änderungen speichern';

  @override
  String get saveAfterResetConfirm => 'Änderungen nach dem Zurücksetzen speichern?';

  @override
  String get repeatOff => 'Wiederholung aus';

  @override
  String get repeatAll => 'Alle wiederholen';

  @override
  String get repeatOne => 'Eines wiederholen';

  @override
  String get repeatAllPlaylists => 'Alle Wiedergabelisten wiederholen';
}
