// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Bibliotecă';

  @override
  String get playlists => 'Playlist-uri';

  @override
  String get settings => 'Setări';

  @override
  String get allSongs => 'Toate melodiile';

  @override
  String get favorites => 'Favorite';

  @override
  String get createPlaylist => 'Creează playlist';

  @override
  String get playlistName => 'Nume playlist';

  @override
  String get iconOptional => 'Iconiță (opțional)';

  @override
  String get cancel => 'Anulare';

  @override
  String get create => 'Creare';

  @override
  String get delete => 'Ștergere';

  @override
  String get edit => 'Editare';

  @override
  String get save => 'Salvare';

  @override
  String get close => 'Închidere';

  @override
  String get search => 'Căutare';

  @override
  String get filter => 'Filtru';

  @override
  String get sort => 'Sortare';

  @override
  String get addToFavorites => 'Adaugă la favorite';

  @override
  String get removeFromFavorites => 'Elimină din favorite';

  @override
  String get addToPlaylist => 'Adaugă la playlist';

  @override
  String get removeFromPlaylist => 'Elimină din playlist';

  @override
  String get addSongsToLibrary => 'Adaugă melodii din bibliotecă';

  @override
  String get noSongsToAdd => 'Nu există melodii de adăugat';

  @override
  String addButtonText(Object count) {
    return 'Adaugă $count';
  }

  @override
  String get selected => 'selectate';

  @override
  String get darkMode => 'Mod întunecat';

  @override
  String get lightMode => 'Mod luminos';

  @override
  String get autoScroll => 'Derulare automată';

  @override
  String get autoScrollSubtitle => 'Derulează automat la linia curentă';

  @override
  String get highlightNextLine => 'Evidențiază linia următoare';

  @override
  String get highlightNextLineSubtitle => 'Arată linia următoare cu evidențiere subtilă';

  @override
  String get fontSize => 'Dimensiune font';

  @override
  String get scrollOffset => 'Decalaj derulare';

  @override
  String get scrollOffsetSubtitle => 'Distanța de la marginea de sus a ecranului în pixeli';

  @override
  String get autoScrollFocusOffset => 'Decalaj focalizare pentru derularea automată';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Poziția focalizării inițială pentru derularea automată (implicit: +50)';

  @override
  String get showVerticalSlider => 'Slider vertical';

  @override
  String get showVerticalSliderSubtitle => 'Afișează sliderul de derulare lateral';

  @override
  String get defaultTranslationLanguage => 'Limbă traducere implicită';

  @override
  String get defaultOriginalLanguage => 'Limbă originală implicită';

  @override
  String get russian => 'Rusă';

  @override
  String get english => 'Engleză';

  @override
  String get romanian => 'Română';

  @override
  String get french => 'Franceză';

  @override
  String get german => 'Germană';

  @override
  String get spanish => 'Spaniolă';

  @override
  String get italian => 'Italiană';

  @override
  String get portuguese => 'Portugheză';

  @override
  String get lyricsFolder => 'Folder versuri';

  @override
  String get useLyricsFolder => 'Folosește folder versuri';

  @override
  String get useLyricsFolderDisabled => 'Dezactivat - fișierele trebuie selectate cu audio';

  @override
  String get setLyricsFolder => 'Setează folder versuri';

  @override
  String get selectFolder => 'Selectează folder';

  @override
  String get folderPath => 'Cale folder';

  @override
  String get examples => 'Exemple:';

  @override
  String get defaultFolder => 'Implicit: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Folder curent:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Folder setat: $path';
  }

  @override
  String get folderSetFailed => 'Folderul nu există sau nu există acces';

  @override
  String get resetToDefault => 'Resetează la implicit';

  @override
  String get showCurrentFolder => 'Arată folderul curent';

  @override
  String get changeFolder => 'Schimbă folder';

  @override
  String get resetToDefaultFolder => 'Resetare la folder implicit';

  @override
  String get folderReset => 'Folder resetat la implicit';

  @override
  String get clearCache => 'Șterge cache';

  @override
  String get clearCacheSubtitle => 'Șterge fișierele temporare';

  @override
  String get cacheCleared => 'Cache golit';

  @override
  String get resetSongLanguages => 'Resetează limbile melodiilor';

  @override
  String get resetSongLanguagesSubtitle => 'Folosește limba implicită din setări';

  @override
  String get songLanguagesReset => 'Limbile melodiilor resetate';

  @override
  String get about => 'Despre';

  @override
  String get translationsLoaded => 'Traduceri încărcate cu succes!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Nu s-au putut încărca traducerile: $error';
  }

  @override
  String get editTranslations => 'Editare traduceri';

  @override
  String get loadTranslationsFromFile => 'Încarcă traduceri din fișier';

  @override
  String get loadTextMenu => 'Încarcă text';

  @override
  String get loadTranslations => 'Încarcă traduceri';

  @override
  String get deleteTranslation => 'Ștergere traducere';

  @override
  String get noFileSelected => 'Niciun fișier selectat';

  @override
  String get noLrcFileAssociated => 'Niciun fișier LRC asociat cu această melodie';

  @override
  String get lrcFileSaved => 'Fișier LRC salvat cu succes!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'Nu s-a putut salva fișierul LRC: $error';
  }

  @override
  String get exitEditMode => 'Ieși din modul de editare';

  @override
  String get editTimestamps => 'Editare marcaje temporale';

  @override
  String get saveChanges => 'Salvează modificările';

  @override
  String get language => 'Limbă';

  @override
  String get loading => 'Încărcare...';

  @override
  String get noSongsFound => 'Nu s-au găsit melodii';

  @override
  String get noPlaylistsFound => 'Nu s-au găsit playlist-uri';

  @override
  String get selectSong => 'Selectează o melodie pentru redare';

  @override
  String get song => 'Melodie';

  @override
  String get artist => 'Artist';

  @override
  String get duration => 'Durată';

  @override
  String get actions => 'Acțiuni';

  @override
  String get play => 'Redare';

  @override
  String get pause => 'Pauză';

  @override
  String get stop => 'Stop';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Următor';

  @override
  String get rewind10 => '-10s';

  @override
  String get forward10 => '+10s';

  @override
  String get repeat => 'Repetă';

  @override
  String get shuffle => 'Amestecă';

  @override
  String get volume => 'Volum';

  @override
  String get speed => 'Viteză';

  @override
  String get lyrics => 'Versuri';

  @override
  String get translations => 'Traduceri';

  @override
  String get originalText => 'Text original';

  @override
  String get translatedText => 'Text tradus';

  @override
  String get showTranscription => 'Arată transcripția';

  @override
  String get showTranscriptionSubtitle => 'Afișează ghidul de pronunție';

  @override
  String get showTranslationFirst => 'Traducere prima';

  @override
  String get showTranslationFirstSubtitle => 'Arată traducerea înainte de textul original';

  @override
  String get italianLang => 'Italiană';

  @override
  String get portugueseLang => 'Portugheză';

  @override
  String get lyricsEditor => 'Editor versuri';

  @override
  String get addLine => 'Adaugă linie';

  @override
  String get updateLine => 'Actualizare linie';

  @override
  String get deleteLine => 'Ștergere linie';

  @override
  String get clearAll => 'Șterge tot';

  @override
  String get moveUp => 'Sus';

  @override
  String get moveDown => 'Jos';

  @override
  String get autoSyncLyrics => 'Sincronizare automată versuri';

  @override
  String get exportLrc => 'Export LRC (Original)';

  @override
  String get exportJson => 'Export JSON (Traduceri)';

  @override
  String get markTimestamp => 'Marchează timp (Enter)';

  @override
  String get original => 'Original';

  @override
  String get translation => 'Traducere';

  @override
  String get audioFile => 'Fișier audio';

  @override
  String get songTitle => 'Titlu melodie';

  @override
  String get browse => 'Navigare';

  @override
  String get audioControls => 'Controale audio';

  @override
  String get addEditLine => 'Adaugă/Editează linie';

  @override
  String get instructions => 'Instrucțiuni';

  @override
  String get lyricsEditorInstructions => 'Instrucțiuni sincronizare LRC:\n\n1. Selectează un fișier audio folosind butonul Navigare\n2. Introdu titlul melodi și artistul (opțional)\n3. Apasă Redare pentru a porni audio\n4. Când o linie este cântată, introdu textul original în câmpul \'Original\'\n5. Apasă Enter sau \'Marchează timp\' pentru a înregistra marcajul temporal\n6. Opțional adaugă o traducere în câmpul \'Traducere\'\n7. Repetă pașii 4-6 pentru fiecare linie\n8. Folosește \'Export LRC\' pentru a salva textul original cu marcaje temporale\n9. Folosește \'Export JSON\' pentru a salva traducerile\n\nSfaturi:\n- Folosește -10s/+10s pentru a naviga rapid prin melodie\n- Poți reordona liniile folosind Sus/Jos\n- Încarcă fișiere JSON salvate anterior pentru a edita traducerile';

  @override
  String get welcome => 'Bine ai venit';

  @override
  String get welcomeMessage => 'Începe călătoria de învățare a limbilor cu muzică!';

  @override
  String get importSongs => 'Import melodii';

  @override
  String get importSongsSubtitle => 'Adaugă fișiere audio de pe dispozitiv';

  @override
  String get manageLibrary => 'Gestionează bibliotecă';

  @override
  String get manageLibrarySubtitle => 'Organizează-ți melodiile și playlist-urile';

  @override
  String get syncLyrics => 'Sincronizează versuri';

  @override
  String get syncLyricsSubtitle => 'Sincronizare automată a versurilor cu audio';

  @override
  String get languageLearning => 'Învățare limbi • Muzică • Traduceri';

  @override
  String get version => 'Versiune';

  @override
  String get developer => 'Dezvoltat de';

  @override
  String get website => 'Site web';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Nu s-a putut crea playlist-ul: $error';
  }

  @override
  String get playlistCreated => 'Playlist creat cu succes!';

  @override
  String get playlistDeleted => 'Playlist șters cu succes!';

  @override
  String get playlistUpdated => 'Playlist actualizat cu succes!';

  @override
  String get songAdded => 'Melodie adăugată cu succes!';

  @override
  String get songRemoved => 'Melodie eliminată cu succes!';

  @override
  String get songDeleted => 'Melodie ștearsă cu succes!';

  @override
  String get error => 'Eroare';

  @override
  String get warning => 'Avertisment';

  @override
  String get info => 'Informații';

  @override
  String get success => 'Succes';

  @override
  String get confirm => 'Confirmare';

  @override
  String get areYouSure => 'Ești sigur?';

  @override
  String get unsavedChanges => 'Ai modificări nesalvate. Continui?';

  @override
  String get selectLanguage => 'Selectează limbă';

  @override
  String get appLanguage => 'Limbă aplicație';

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
  String get welcomeToLingoTune => 'Bine ai venit la LingoTune';

  @override
  String get folderSetupMessage => 'Alege un folder pentru a stoca versuri și traduceri (fișiere LRC și JSON). Acest lucru face ușor organizarea bibliotecii de muzică.';

  @override
  String get selectFolderNow => 'Selectează folder acum';

  @override
  String get goToSettings => 'Mergi la setări';

  @override
  String get setupLater => 'Configurare mai târziu';

  @override
  String get useDefaultFolder => 'Folosește folder implicit';

  @override
  String get databaseFound => 'Bază de date găsită în fișierul de import';

  @override
  String get importDatabaseQuestion => 'Vrei să imporți și baza de date?';

  @override
  String get mergeDatabase => 'Fuzionare';

  @override
  String get replaceDatabase => 'Înlocuire';

  @override
  String get importDatabase => 'Import bază de date';

  @override
  String get skipDatabase => 'Omite bază de date';

  @override
  String get mergeDatabaseDescription => 'Fuzionează melodiile importate cu biblioteca ta (adaugă doar elemente noi)';

  @override
  String get replaceDatabaseDescription => 'Înlocuiește întreaga bibliotecă cu baza de date importată (vei pierde toate datele existente)';

  @override
  String get exporting => 'Exportare...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Exportare $current din $total melodii';
  }

  @override
  String get exportDatabaseIncluded => 'Baza de date inclusă în export';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'Importat $fileCount fișier(e) și bază de date';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'Importat $fileCount fișier(e)';
  }

  @override
  String get chinese => 'Chineză';

  @override
  String get arabic => 'Arabă';

  @override
  String get colorTheme => 'Temă culori';

  @override
  String get themeColorPurple => 'Violet';

  @override
  String get themeColorBlue => 'Albastru';

  @override
  String get themeColorGreen => 'Verde';

  @override
  String get themeColorOrange => 'Portocaliu';

  @override
  String get themeColorRed => 'Roșu';

  @override
  String get themeColorPink => 'Roz';

  @override
  String get themeColorDeepOrange => 'Portocaliu închis';

  @override
  String get themeColorDarkRed => 'Roșu închis';

  @override
  String get themeColorTeal => 'Turcoaz';

  @override
  String get themeColorCyan => 'Cian';

  @override
  String get themeColorAmber => 'Chihlimbar';

  @override
  String get themeColorLime => 'Lime';

  @override
  String get ukrainianLang => 'Ucraineană';

  @override
  String get font => 'Font';

  @override
  String get fontSettings => 'Setări font';

  @override
  String get systemFont => 'Sistem';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Dimensiune text principal';

  @override
  String get mainTextBold => 'Text principal îngroșat';

  @override
  String get translationSize => 'Dimensiune traducere';

  @override
  String get translationBold => 'Traducere îngroșată';

  @override
  String get transcriptSize => 'Dimensiune transcriere';

  @override
  String get transcriptBold => 'Transcriere îngroșată';

  @override
  String get defaultStartScreen => 'Ecran de pornire implicit';

  @override
  String get defaultStartScreenSubtitle => 'Ecranul de afișat la pornirea aplicației';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Adaugă la bibliotecă la adăugarea la o listă de redare';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Adaugă automat melodii în bibliotecă la adăugarea lor la o listă de redare';

  @override
  String get serviceMessages => 'Mesaje de serviciu';

  @override
  String get serviceMessagesSubtitle => 'Arată notificări de serviciu despre traducere și transcriere';

  @override
  String get includeMp3Files => 'Include fișiere MP3';

  @override
  String get includeMp3FilesSubtitle => 'Acest lucru va mări dimensiunea arhivei';

  @override
  String get importMp3Files => 'Importă fișiere MP3';

  @override
  String get importMp3FilesSubtitle => 'Adaugă fișiere muzicale în bibliotecă';

  @override
  String get exportSongs => 'Exportă melodiile';

  @override
  String get import => 'Import';

  @override
  String get addMultiple => 'Selectează mai multe';

  @override
  String get addToPlaylistShort => 'Adaugă';

  @override
  String get deleteShort => 'Șterge';

  @override
  String get selectAllShort => 'Toate';

  @override
  String get deselectAllShort => 'Golește';

  @override
  String get exitSelectionMode => 'Ieși din modul de selecție';

  @override
  String get selectAll => 'Selectează tot';

  @override
  String get deselectAll => 'Deselectează tot';

  @override
  String get deleteSelected => 'Șterge selecția';

  @override
  String get addMultipleToPlaylist => 'Adaugă la playlist';

  @override
  String get coverArt => 'Copertă';

  @override
  String get playlistCover => 'Coperta playlist';

  @override
  String get selectFromGallery => 'Selectează din galerie';

  @override
  String get removeCover => 'Elimină coperta';

  @override
  String get coverUpdated => 'Coperta actualizată';

  @override
  String get coverRemoved => 'Coperta eliminată';

  @override
  String errorWithMessage(Object error) {
    return 'Eroare: $error';
  }

  @override
  String get importFolders => 'Importă foldere';

  @override
  String get selectMusicFolder => 'Selectează folderul de muzică';

  @override
  String get folderWithAudioFiles => 'Folder cu fișiere MP3/WAV';

  @override
  String get sameFolderForLyrics => 'Același folder pentru versuri';

  @override
  String get selectLyricsFolder => 'Selectează folderul versuri';

  @override
  String get folderWithLyricsFiles => 'Folder cu fișiere LRC/JSON (opțional)';

  @override
  String get pleaseEnterPlaylistName => 'Vă rugăm să introduceți numele playlist-ului';

  @override
  String get pleaseSelectMusicFolder => 'Vă rugăm să selectați un folder de muzică';

  @override
  String get cropImage => 'Decupează imaginea';

  @override
  String get photoPermissionRequired => 'Permisiunea de acces la fotografii necesară';

  @override
  String get photoPermissionDenied => 'Acces la fotografii refuzat';

  @override
  String get imageProcessingError => 'Eroare la procesarea imaginii';

  @override
  String get scanningFolder => 'Scanare folder...';

  @override
  String get importingFiles => 'Importare fișiere...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Importare $current/$total fișiere... Găsite $songs melodii';
  }

  @override
  String processingFile(Object file) {
    return 'Prelucrare $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Adaugă la playlist';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Adăugat la \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Nu s-a putut adăuga la playlist: $error';
  }

  @override
  String get deleteSong => 'Șterge';

  @override
  String get importSongDialogTitle => 'Importă melodie';

  @override
  String get audioOnly => 'Doar audio';

  @override
  String get addLyricsLater => 'Voi adă versurile mai târziu';

  @override
  String get audioWithLyricsZIP => 'Audio + ZIP cu versuri';

  @override
  String get importWithAllTranslations => 'Importă cu toate traducerile';

  @override
  String get importTranslationDialogTitle => 'Adaugă traducere';

  @override
  String get loadTranslationFromZip => 'Încarcă din arhivă ZIP';

  @override
  String get loadTranslationFromJson => 'Încarcă din fișier JSON';

  @override
  String get noAudioFilesSelected => 'Nu s-a selectat niciun fișier audio';

  @override
  String failedToImportSongs(Object error) {
    return 'Nu s-au putut importa melodiile: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Nu s-a putut importa melodia: $error';
  }

  @override
  String get musicFolderNotSelected => 'Nu s-a selectat folderul de muzică';

  @override
  String get generateLyrics => 'Generează versuri';

  @override
  String get selectTextFileOrEnterText => 'Selectează fișier text sau introdu text';

  @override
  String get originalLanguage => 'Limbă originală';

  @override
  String get translationLanguages => 'Limbi traducere';

  @override
  String get startMinuteForTimestamps => 'Minut start timpi';

  @override
  String get transcriptionLanguage => 'Limbă transcriere';

  @override
  String get generating => 'Generare...';

  @override
  String get generate => 'Generează';

  @override
  String get deepseekApiKey => 'Cheie API DeepSeek';

  @override
  String get validateKey => 'Validează cheie';

  @override
  String get keyIsValid => 'Cheie validă';

  @override
  String get keyIsInvalid => 'Cheie invalidă';

  @override
  String get lyricsGenerationSuccess => 'Versuri generate cu succes';

  @override
  String get lyricsGenerationError => 'Eșec generare versuri';

  @override
  String get savingFiles => 'Salvare fișiere...';

  @override
  String get enterText => 'Introdu text';

  @override
  String get transcript => 'Transcriere';

  @override
  String get originalTextEditable => 'Text original (editabil)';

  @override
  String get selectLanguageToEdit => 'Selectează limba de editat';

  @override
  String get moveLineUp => 'Mută linia în sus';

  @override
  String get moveLineDown => 'Mută linia în jos';

  @override
  String get moveAllTranslationsUp => 'Mută toate traducerile în sus';

  @override
  String get moveAllTranslationsDown => 'Mută toate traducerile în jos';

  @override
  String get translationSaved => 'Traducere salvată!';

  @override
  String get translationSaveFailed => 'Nu s-a putut salva traducerea';

  @override
  String get loadTextTitle => 'Încarcă text';

  @override
  String get noOriginalTextWarning => 'Încărcați mai întâi textul original';

  @override
  String get selectLanguageOriginal => 'Limbă originală';

  @override
  String get startTimestampMinutes => 'Început timestamp (minute)';

  @override
  String get selectLanguageTranslation => 'Limbă de traducere';

  @override
  String get originalTextLoaded => 'Textul original încărcat cu succes!';

  @override
  String get translationLoaded => 'Traducerea încărcată cu succes!';

  @override
  String get transcriptLoaded => 'Transcrierea încărcată cu succes!';

  @override
  String get selectTranslationLanguage => 'Limbă de traducere pentru transcriere';

  @override
  String get noTranslationWarning => 'Nicio traducere încărcată';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Discordanță de linii: $loaded linii, așteptate $expected';
  }

  @override
  String get loadTextTooltip => 'Încarcă text sau traducere';

  @override
  String get loadFromFile => 'Încarcă din fișier';

  @override
  String get pasteFromClipboard => 'Lipește din clipboard';

  @override
  String get audioNotificationService => 'Serviciu notificare audio';

  @override
  String get audioNotificationServiceActive => 'Stare: ✅ Activ';

  @override
  String get audioNotificationServiceError => 'Stare: ❌ Eroare';

  @override
  String get errorLabel => 'Eroare:';

  @override
  String get audioNotificationServiceDescription => 'Acest serviciu oferă notificări când aplicația este minimizată';

  @override
  String get reorder => 'Reorganizați';

  @override
  String get done => 'Gata';

  @override
  String get selectMultiple => 'Selectare multiplă';

  @override
  String get sortSongs => 'Sortare melodii';

  @override
  String get importSong => 'Importă melodie';

  @override
  String get sortDefault => 'Implicit';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Cele mai recente';

  @override
  String get sortDateAsc => 'Cele mai vechi';

  @override
  String get importingSongs => 'Importare melodii...';

  @override
  String get noSongsInPlaylist => 'Niciun cântec în acest playlist';

  @override
  String get addSongsFromLibraryHint => 'Adaugă melodii din bibliotecă';

  @override
  String get removedSongsFromPlaylist => 'Melodii eliminate din playlist';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Eroare la ștergerea melodiilor: $error';
  }

  @override
  String get deletePlaylistTitle => 'Ștergere playlist';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'Sigur doriți să ștergeți \"$playlist\"?';
  }

  @override
  String get failedToDeletePlaylist => 'Nu s-a putut șterge playlist-ul:';

  @override
  String get specifyTranslationLanguage => 'Specificați limba de traducere';

  @override
  String get languageNameLabel => 'Numele limbii';

  @override
  String get languageNameHint => 'De exemplu: Rusă, Autor, Poetic';

  @override
  String get translationTypeLabel => 'Tip de traducere:';

  @override
  String get translationTypeNormal => 'Normal';

  @override
  String get translationTypeAuthor => 'Autor';

  @override
  String get translationTypePoetic => 'Poetic';

  @override
  String get translationTypeLiteral => 'Literal';

  @override
  String mp3FilesCount(Object count) {
    return 'Fișiere MP3: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return '$count fișier(e) importat(e) (baza de date omisă)';
  }

  @override
  String get databaseMerged => 'Baza de date fuzionată';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'Baza de date fuzionată, fișiere MP3: $count';
  }

  @override
  String get databaseReplaced => 'Baza de date înlocuită';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'Baza de date înlocuită, fișiere MP3: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Confirmați înlocuirea';

  @override
  String get confirmReplaceDatabaseWarning => 'Sunteți sigur? Veți pierde toate melodiile și playlist-urile existente!';

  @override
  String get replaceAll => 'Înlocuiți tot';

  @override
  String get selectLanguages => 'Selectează limbi';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Selectate: $count limbi';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Selectate: $count';
  }

  @override
  String get promptPreset => 'Preset de prompt';

  @override
  String get balanced => 'Echilibrat';

  @override
  String get poetic => 'Poetic';

  @override
  String get literal => 'Literal';

  @override
  String get customPromptOption => 'Personalizat...';

  @override
  String get editPrompt => 'Editează promptul';

  @override
  String get notSet => 'Nestabilit';

  @override
  String get showOrEditApiKey => 'Afișează/Editează cheia API';

  @override
  String get timeout => 'Timeout';

  @override
  String get model => 'Model';

  @override
  String get resetToPreset => 'Resetează la preset';

  @override
  String get customPrompt => 'Prompt personalizat';

  @override
  String customPromptChars(Object count) {
    return 'Prompt personalizat ($count caractere)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Se utilizează presetul: $preset';
  }

  @override
  String get characters => 'caractere';

  @override
  String get deepSeekPromptTitle => 'Prompt DeepSeek';

  @override
  String get customPromptLabel => 'Prompt personalizat';

  @override
  String get leaveEmptyToUseDefault => 'Lăsați gol pentru a utiliza promptul implicit';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Lăsați gol pentru a utiliza promptul implicit integrat în aplicație';

  @override
  String get apiKeySaved => 'Cheia API salvată';

  @override
  String get enterTimeout => 'Introduceți timeout-ul în secunde';

  @override
  String get validTimeoutRange => 'Vă rugăm să introduceți un timeout valid (1-3600 secunde)';

  @override
  String get customTimeout => 'Timeout personalizat';

  @override
  String get timeoutSeconds => 'Timeout (secunde)';

  @override
  String timeoutSetTo(Object value) {
    return 'Timeout setat la $value secunde';
  }

  @override
  String get customModel => 'Model personalizat';

  @override
  String get modelName => 'Numele modelului';

  @override
  String get enterModelName => 'Introduceți numele exact al modelului furnizat de DeepSeek API';

  @override
  String get pleaseEnterModelName => 'Vă rugăm să introduceți un nume de model';

  @override
  String modelSetTo(Object value) {
    return 'Model setat la $value';
  }

  @override
  String get editCustomPrompt => 'Editați promptul personalizat';

  @override
  String get editPresetPrompt => 'Editați promptul predefinit';

  @override
  String get editingPreset => 'Editare preset';

  @override
  String get anyChangesSaveAsCustom => 'Orice modificare va fi salvată ca un prompt personalizat. Utilizați butonul \'Resetează\' pentru a restaura presetul original.';

  @override
  String get useResetToRestorePreset => 'Utilizați butonul \'Resetează\' pentru a restaura presetul original';

  @override
  String get prompt => 'Prompt';

  @override
  String get promptSaved => 'Prompt salvat';

  @override
  String get usingPresetPrompt => 'Se utilizează promptul predefinit';

  @override
  String get apiKeyHint => 'Cheie API';

  @override
  String get modelHint => 'ex. deepseek-v3';

  @override
  String get enterExactModelName => 'Introduceți numele exact al modelului furnizat de DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'Vă rugăm să introduceți mai întâi cheia API';

  @override
  String get maxTokensRegular => 'Max Tokens (Normal)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Limita de tokeni pentru cererile normale de traducere';

  @override
  String get maxTokensJsonHint => 'Limita de tokeni pentru cererile complete de generare (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (normal) setat la $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) setat la $value';
  }

  @override
  String get refreshFolder => 'Actualizare folder';

  @override
  String get refreshingFolder => 'Actualizare folder în curs...';

  @override
  String get playlistCreatedWithLink => 'Playlist creată! Apăsați \"Actualizare\" pentru a încărca melodii din folder';

  @override
  String refreshedPlaylist(Object count) {
    return 'Actualizat: $count melodii';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Eroare de actualizare: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Eroare la încărcarea melodiilor: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'Folderul de muzică nu există';

  @override
  String successfullyImportedSongs(Object count) {
    return '$count melodie(i) importate cu succes';
  }

  @override
  String get noAudioFileSelected => 'Niciun fișier audio selectat';

  @override
  String get noZipArchiveSelected => 'Niciun arhivă ZIP selectată';

  @override
  String get noFolderConfigured => 'Folderul nu este configurat';

  @override
  String get missingLyricsTranslations => 'Versuri/Traduceri lipsă';

  @override
  String missingForSong(Object songName) {
    return 'Pentru \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Lipsă: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'Ce doriți să faceți?';

  @override
  String get lyricsGeneratedSuccessfully => 'Versuri generate cu succes';

  @override
  String get setDeepSeekApiKey => 'Vă rugăm să configurați cheia API DeepSeek în setări';

  @override
  String failedToOpenSong(Object error) {
    return 'Eroare la deschiderea melodiei: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'Ștergeți și fișierele LRC și JSON';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Adăugat la \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Eroare la adăugarea la playlist: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return '$count melodii exportate';
  }

  @override
  String get fileNotFound => 'Fișier negăsit';

  @override
  String get selectZipFileNotJson => 'Vă rugăm să selectați un fișier ZIP, nu JSON sau LRC';

  @override
  String get noFilesFoundInZip => 'Niciun fișier găsit în ZIP';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Format de fișier ZIP invalid: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Eroare la importare: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return '$count traduceri găsite';
  }

  @override
  String mp3ImportError(Object error) {
    return 'Eroare import MP3: $error';
  }

  @override
  String get importSongFirstToSearch => 'Importați întâi o melodie pentru a căuta versuri';

  @override
  String get lyricsFetched => 'Versuri preluate';

  @override
  String get lyricsFoundUseCreate => 'Versuri găsite. Folosiți pentru a crea un fișier LRC sincronizat';

  @override
  String get deleteSelectedSongs => 'Șterge melodiile selectate';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'Sigur doriți să ștergeți $count melodii?';
  }

  @override
  String get songsDeletedSuccessfully => 'Melodii șterse cu succes';

  @override
  String get storagePermissionRequired => 'Permisiunea de stocare este necesară pentru a accesa foldere.';

  @override
  String get enableStoragePermission => 'Vă rugăm să activați permisiunea de stocare în setări.';

  @override
  String get openSettings => 'Deschide setări';

  @override
  String get unableToSelectFolder => 'Nu s-a putut selecta folderul. Încercați alternativă:';

  @override
  String get selectFilesInstead => 'Selectați fișiere în schimb';

  @override
  String get enterFolderPath => 'Vă rugăm să introduceți o cale de folder';

  @override
  String get folderDoesNotExist => '✗ Folderul nu există';

  @override
  String folderSetWithPath(Object path) {
    return 'Folder setat: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Eroare la setarea folderului: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'Nu s-a putut selecta folderul de versuri. Încercați alternativă:';

  @override
  String get useManualPath => 'Utilizați cale manuală (pentru teste)';

  @override
  String get enterFolderPathManually => 'Introduceți calea folderului manual în loc să utilizați selectorul de folder';

  @override
  String get folderPathLabel => 'Cale folder';

  @override
  String get folderPathHint => 'Exemplu: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Cale completă către folderul dvs. de muzică';

  @override
  String get setPath => 'Setați calea';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'Selectați arhiva ZIP cu versuri pentru \"$title\"';
  }

  @override
  String get skip => 'Omiteți';

  @override
  String get retry => 'Încercați din nou';

  @override
  String get failedToCopyLrcFile => 'Eroare la copierea fișierului LRC';

  @override
  String copiedJsonFiles(Object count) {
    return '$count fișier(e) JSON copiat(e)';
  }

  @override
  String get failedToCopyJsonFiles => 'Eroare la copierea fișierelor JSON';

  @override
  String failedToDeleteSong(Object error) {
    return 'Eroare la ștergerea melodiei: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return '$count melodii adăugate la \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'Adăugați $count melodii la playlist';
  }

  @override
  String get failedToExportSongs => 'Eroare la exportul melodiilor';

  @override
  String get ok => 'OK';

  @override
  String deleteSongConfirm(Object song) {
    return 'Sigur doriți să ștergeți \"$song\"?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Selectați folderul cu muzică pentru acest playlist';

  @override
  String get folderLinkedToPlaylist => 'Folderul este legat de playlist';

  @override
  String get folderUnlinkedFromPlaylist => 'Folderul este deconectat de la playlist';

  @override
  String get checkFolderAccess => 'Verificare acces';

  @override
  String get checkingPermissions => 'Verificare permisiuni...';

  @override
  String get folderAccessible => '✓ Folder accesibil';

  @override
  String get folderNotAccessible => '✗ Folder inaccesibil';

  @override
  String audioFilesFound(Object count) {
    return 'Găsite $count fișier(e) audio';
  }

  @override
  String lyricsFound(Object count) {
    return 'Găsite $count fișier(e) cu text';
  }

  @override
  String get noAudioFiles => 'Nu s-au găsit fișiere audio';

  @override
  String get noLyricsFiles => 'Nu s-au găsit fișiere cu text';

  @override
  String errorCheckingAccess(Object error) {
    return 'Eroare la verificarea accesului: $error';
  }

  @override
  String get folderPathColon => 'Cale folder:';

  @override
  String get permissionsStatus => 'Stare permisiuni:';

  @override
  String get folderContent => 'Conținut folder:';

  @override
  String get accessGranted => '✓ Acces permis';

  @override
  String get accessDenied => '✗ Acces interzis';

  @override
  String get permissionRequestFailed => 'Nu s-a putut solicita permisiuni';

  @override
  String get pleaseGrantPermissions => 'Vă rugăm să acordați permisiuni de stocare pentru a verifica folderul';

  @override
  String get refreshOnlySongs => 'Doar melodii';

  @override
  String get refreshEverything => 'Tot';

  @override
  String get refreshDialogDescription => 'Ce doriți să actualizați? \"Doar melodii\" grăbește procesul sărind peste texte.';

  @override
  String get mostSongs => 'Cele mai multe melodii';
}
