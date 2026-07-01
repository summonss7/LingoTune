// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Libreria';

  @override
  String get playlists => 'Playlist';

  @override
  String get settings => 'Impostazioni';

  @override
  String get allSongs => 'Tutte le canzoni';

  @override
  String get favorites => 'Preferiti';

  @override
  String get createPlaylist => 'Crea playlist';

  @override
  String get playlistName => 'Nome playlist';

  @override
  String get iconOptional => 'Icona (opzionale)';

  @override
  String get cancel => 'Annulla';

  @override
  String get create => 'Crea';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get save => 'Salva';

  @override
  String get close => 'Chiudi';

  @override
  String get search => 'Cerca';

  @override
  String get filter => 'Filtro';

  @override
  String get sort => 'Ordina';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get addToPlaylist => 'Aggiungi alla playlist';

  @override
  String get removeFromPlaylist => 'Rimuovi dalla playlist';

  @override
  String get addSongsToLibrary => 'Aggiungi brani dalla libreria';

  @override
  String get noSongsToAdd => 'Nessun brano da aggiungere';

  @override
  String addButtonText(Object count) {
    return 'Aggiungi $count';
  }

  @override
  String get selected => 'selezionati';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get lightMode => 'Modalità chiara';

  @override
  String get autoScroll => 'Scorrimento automatico';

  @override
  String get autoScrollSubtitle => 'Scorri automaticamente alla riga corrente';

  @override
  String get highlightNextLine => 'Evidenzia riga successiva';

  @override
  String get highlightNextLineSubtitle => 'Mostra la riga successiva con evidenziazione sottile';

  @override
  String get fontSize => 'Dimensione carattere';

  @override
  String get scrollOffset => 'Scorrimento';

  @override
  String get scrollOffsetSubtitle => 'Distanza dalla parte superiore dello schermo in pixel';

  @override
  String get autoScrollFocusOffset => 'Scorrimento del focus dello scroll automatico';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Posizione del focus iniziale per lo scroll automatico (predefinito: +50)';

  @override
  String get defaultTranslationLanguage => 'Lingua traduzione predefinita';

  @override
  String get defaultOriginalLanguage => 'Lingua originale predefinita';

  @override
  String get russian => 'Russo';

  @override
  String get english => 'Inglese';

  @override
  String get romanian => 'Rumeno';

  @override
  String get french => 'Francese';

  @override
  String get german => 'Tedesco';

  @override
  String get spanish => 'Spagnolo';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Portoghese';

  @override
  String get lyricsFolder => 'Cartella testi';

  @override
  String get useLyricsFolder => 'Usa cartella testi';

  @override
  String get useLyricsFolderDisabled => 'Disattivato - i file devono essere selezionati con l\'audio';

  @override
  String get setLyricsFolder => 'Imposta cartella testi';

  @override
  String get selectFolder => 'Seleziona cartella';

  @override
  String get folderPath => 'Percorso cartella';

  @override
  String get examples => 'Esempi:';

  @override
  String get defaultFolder => 'Predefinito: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Cartella attuale:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Cartella impostata: $path';
  }

  @override
  String get folderSetFailed => 'La cartella non esiste o nessun accesso';

  @override
  String get resetToDefault => 'Ripristina predefinito';

  @override
  String get showCurrentFolder => 'Mostra cartella attuale';

  @override
  String get changeFolder => 'Cambia cartella';

  @override
  String get resetToDefaultFolder => 'Ripristina cartella predefinita';

  @override
  String get folderReset => 'Cartella ripristinata al predefinito';

  @override
  String get clearCache => 'Svuota cache';

  @override
  String get clearCacheSubtitle => 'Elimina file temporanei';

  @override
  String get cacheCleared => 'Cache svuotata';

  @override
  String get resetSongLanguages => 'Reimposta lingue canzoni';

  @override
  String get resetSongLanguagesSubtitle => 'Usa lingua predefinita dalle impostazioni';

  @override
  String get songLanguagesReset => 'Lingue canzoni reimpostate';

  @override
  String get about => 'Informazioni';

  @override
  String get translationsLoaded => 'Traduzioni caricate con successo!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Impossibile caricare le traduzioni: $error';
  }

  @override
  String get editTranslations => 'Modifica';

  @override
  String get loadTranslationsFromFile => 'Importa archivio ZIP';

  @override
  String get loadTextMenu => 'Carica testo';

  @override
  String get loadTranslations => 'Carica traduzioni';

  @override
  String get deleteTranslation => 'Elimina traduzione';

  @override
  String get noFileSelected => 'Nessun file selezionato';

  @override
  String get noLrcFileAssociated => 'Nessun file LRC associato a questa canzone';

  @override
  String get lrcFileSaved => 'File LRC salvato con successo!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'Impossibile salvare il file LRC: $error';
  }

  @override
  String get exitEditMode => 'Esci dalla modalità modifica';

  @override
  String get editTimestamps => 'Modifica timestamp';

  @override
  String get saveChanges => 'Salva modifiche';

  @override
  String get language => 'Lingua';

  @override
  String get loading => 'Caricamento...';

  @override
  String get noSongsFound => 'Nessuna canzone trovata';

  @override
  String get noPlaylistsFound => 'Nessuna playlist trovata';

  @override
  String get selectSong => 'Seleziona una canzone da riprodurre';

  @override
  String get song => 'Canzone';

  @override
  String get artist => 'Artista';

  @override
  String get duration => 'Durata';

  @override
  String get actions => 'Azioni';

  @override
  String get play => 'Riproduci';

  @override
  String get pause => 'Pausa';

  @override
  String get stop => 'Stop';

  @override
  String get previous => 'Precedente';

  @override
  String get next => 'Successivo';

  @override
  String get rewind10 => '-10s';

  @override
  String get forward10 => '+10s';

  @override
  String get repeat => 'Ripeti';

  @override
  String get shuffle => 'Casuale';

  @override
  String get volume => 'Volume';

  @override
  String get speed => 'Velocità';

  @override
  String get lyrics => 'Testi';

  @override
  String get translations => 'Traduzioni';

  @override
  String get originalText => 'Testo originale';

  @override
  String get translatedText => 'Testo tradotto';

  @override
  String get showTranscription => 'Mostra trascrizione';

  @override
  String get showTranscriptionSubtitle => 'Mostra guida pronuncia';

  @override
  String get showTranslationFirst => 'Traduzione prima';

  @override
  String get showTranslationFirstSubtitle => 'Mostra traduzione prima del testo originale';

  @override
  String get italianLang => 'Italiano';

  @override
  String get portugueseLang => 'Portoghese';

  @override
  String get lyricsEditor => 'Editor testi';

  @override
  String get addLine => 'Aggiungi riga';

  @override
  String get updateLine => 'Aggiorna riga';

  @override
  String get deleteLine => 'Elimina riga';

  @override
  String get clearAll => 'Cancella tutto';

  @override
  String get moveUp => 'Su';

  @override
  String get moveDown => 'Giù';

  @override
  String get autoSyncLyrics => 'Sincronizzazione automatica testi';

  @override
  String get exportLrc => 'Esporta LRC (Originale)';

  @override
  String get exportJson => 'Esporta JSON (Traduzioni)';

  @override
  String get markTimestamp => 'Marca timestamp (Invio)';

  @override
  String get original => 'Originale';

  @override
  String get translation => 'Traduzione';

  @override
  String get audioFile => 'File audio';

  @override
  String get songTitle => 'Titolo canzone';

  @override
  String get browse => 'Sfoglia';

  @override
  String get audioControls => 'Controlli audio';

  @override
  String get addEditLine => 'Aggiungi/Modifica riga';

  @override
  String get instructions => 'Istruzioni';

  @override
  String get lyricsEditorInstructions => 'Istruzioni sincronizzazione LRC:\n\n1. Seleziona un file audio usando il pulsante Sfoglia\n2. Inserisci titolo della canzone e artista (opzionale)\n3. Clicca Riproduci per avviare l\'audio\n4. Quando viene cantata una riga, digita il testo originale nel campo \'Originale\'\n5. Premi Invio o \'Marca timestamp\' per registrare il timestamp\n6. Opzionalmente aggiungi una traduzione nel campo \'Traduzione\'\n7. Ripeti i passaggi 4-6 per ogni riga\n8. Usa \'Esporta LRC\' per salvare il testo originale con i timestamp\n9. Usa \'Esporta JSON\' per salvare le traduzioni\n\nSuggerimenti:\n- Usa -10s/+10s per navigare rapidamente nella canzone\n- Puoi riordinare le righe usando Su/Giù\n- Carica file JSON salvati in precedenza per modificare le traduzioni';

  @override
  String get welcome => 'Benvenuto';

  @override
  String get welcomeMessage => 'Inizia il tuo percorso di apprendimento delle lingue con la musica!';

  @override
  String get importSongs => 'Importa canzoni';

  @override
  String get importSongsSubtitle => 'Aggiungi file audio dal tuo dispositivo';

  @override
  String get manageLibrary => 'Gestisci libreria';

  @override
  String get manageLibrarySubtitle => 'Organizza le tue canzoni e playlist';

  @override
  String get syncLyrics => 'Sincronizza testi';

  @override
  String get syncLyricsSubtitle => 'Sincronizzazione automatica dei testi con l\'audio';

  @override
  String get languageLearning => 'Apprendimento lingue • Musica • Traduzioni';

  @override
  String get version => 'Versione';

  @override
  String get developer => 'Sviluppato da';

  @override
  String get website => 'Sito web';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Impossibile creare la playlist: $error';
  }

  @override
  String get playlistCreated => 'Playlist creata con successo!';

  @override
  String get playlistDeleted => 'Playlist eliminata con successo!';

  @override
  String get playlistUpdated => 'Playlist aggiornata con successo!';

  @override
  String get songAdded => 'Canzone aggiunta con successo!';

  @override
  String get songRemoved => 'Canzone rimossa con successo!';

  @override
  String get songDeleted => 'Canzone eliminata con successo!';

  @override
  String get error => 'Errore';

  @override
  String get warning => 'Avviso';

  @override
  String get info => 'Info';

  @override
  String get success => 'Successo';

  @override
  String get confirm => 'Conferma';

  @override
  String get areYouSure => 'Sei sicuro?';

  @override
  String get unsavedChanges => 'Hai modifiche non salvate. Continuare?';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get appLanguage => 'Lingua app';

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
  String get welcomeToLingoTune => 'Benvenuto in LingoTune';

  @override
  String get folderSetupMessage => 'Scegli una cartella per memorizzare testi e traduzioni (file LRC e JSON). Questo facilita l\'organizzazione della tua libreria musicale.';

  @override
  String get selectFolderNow => 'Seleziona cartella ora';

  @override
  String get goToSettings => 'Vai alle impostazioni';

  @override
  String get setupLater => 'Configura dopo';

  @override
  String get useDefaultFolder => 'Usa cartella predefinita';

  @override
  String get databaseFound => 'Database trovato nel file di importazione';

  @override
  String get importDatabaseQuestion => 'Vuoi importare anche il database?';

  @override
  String get mergeDatabase => 'Unisci';

  @override
  String get replaceDatabase => 'Sostituisci';

  @override
  String get importDatabase => 'Importa database';

  @override
  String get skipDatabase => 'Salta database';

  @override
  String get mergeDatabaseDescription => 'Unisci le canzoni importate con la tua libreria (aggiunge solo nuovi elementi)';

  @override
  String get replaceDatabaseDescription => 'Sostituisci l\'intera libreria con il database importato (perderai tutti i dati esistenti)';

  @override
  String get exporting => 'Esportazione...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Esportazione $current di $total canzoni';
  }

  @override
  String get exportDatabaseIncluded => 'Database incluso nell\'esportazione';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'Importato/i $fileCount file/e e database';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'Importato/i $fileCount file/e';
  }

  @override
  String get chinese => 'Cinese';

  @override
  String get arabic => 'Arabo';

  @override
  String get colorTheme => 'Tema colore';

  @override
  String get themeColorPurple => 'Viola';

  @override
  String get themeColorBlue => 'Blu';

  @override
  String get themeColorGreen => 'Verde';

  @override
  String get themeColorOrange => 'Arancione';

  @override
  String get themeColorRed => 'Rosso';

  @override
  String get themeColorPink => 'Rosa';

  @override
  String get themeColorDeepOrange => 'Arancione scuro';

  @override
  String get themeColorDarkRed => 'Rosso scuro';

  @override
  String get themeColorTeal => 'Turchese';

  @override
  String get themeColorCyan => 'Ciano';

  @override
  String get themeColorAmber => 'Ambra';

  @override
  String get themeColorLime => 'Lime';

  @override
  String get ukrainianLang => 'Ucraino';

  @override
  String get font => 'Carattere';

  @override
  String get fontSettings => 'Impostazioni carattere';

  @override
  String get systemFont => 'Sistema';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Dimensione testo principale';

  @override
  String get mainTextBold => 'Testo principale in grassetto';

  @override
  String get translationSize => 'Dimensione traduzione';

  @override
  String get translationBold => 'Traduzione in grassetto';

  @override
  String get transcriptSize => 'Dimensione trascrizione';

  @override
  String get transcriptBold => 'Trascrizione in grassetto';

  @override
  String get defaultStartScreen => 'Schermata iniziale predefinita';

  @override
  String get defaultStartScreenSubtitle => 'Schermata da mostrare all\'avvio dell\'app';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Aggiungi alla libreria quando aggiungi a una playlist';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Aggiungi automaticamente i brani alla libreria quando vengono aggiunti a una playlist';

  @override
  String get serviceMessages => 'Messaggi di servizio';

  @override
  String get serviceMessagesSubtitle => 'Mostra notifiche di servizio su traduzione e trascrizione';

  @override
  String get serviceData => 'Dati di servizio';

  @override
  String get serviceDataSubtitle => 'Mostra overlay diagnostico in modalità studio';

  @override
  String get ttsEngine => 'Motore TTS';

  @override
  String get ttsEngineSubtitle => 'Nessun motore TTS rilevato — l\'app potrebbe non vedere i motori vocali di sistema.';

  @override
  String get ttsEngineAuto => 'Automatico (consigliato)';

  @override
  String get ttsEngineReloadHint => 'Motore cambiato — avrà effetto alla prossima sessione di studio';

  @override
  String get includeMp3Files => 'Includi file MP3';

  @override
  String get includeMp3FilesSubtitle => 'Questo aumenterà la dimensione dell\'archivio';

  @override
  String get importMp3Files => 'Importa file MP3';

  @override
  String get importMp3FilesSubtitle => 'Aggiungi file musicali alla libreria';

  @override
  String get exportSongs => 'Esporta canzoni';

  @override
  String get import => 'Importa';

  @override
  String get addMultiple => 'Seleziona multipli';

  @override
  String get addToPlaylistShort => 'Aggiungi';

  @override
  String get deleteShort => 'Elimina';

  @override
  String get selectAllShort => 'Tutti';

  @override
  String get deselectAllShort => 'Cancella';

  @override
  String get exitSelectionMode => 'Esci dalla modalità selezione';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get deselectAll => 'Deseleziona tutto';

  @override
  String get deleteSelected => 'Elimina selezionati';

  @override
  String get addMultipleToPlaylist => 'Aggiungi alla playlist';

  @override
  String get coverArt => 'Copertina';

  @override
  String get playlistCover => 'Copertina playlist';

  @override
  String get selectFromGallery => 'Seleziona dalla galleria';

  @override
  String get removeCover => 'Rimuovi copertina';

  @override
  String get coverUpdated => 'Copertina aggiornata';

  @override
  String get coverRemoved => 'Copertina rimossa';

  @override
  String errorWithMessage(Object error) {
    return 'Errore: $error';
  }

  @override
  String get importFolders => 'Importa cartelle';

  @override
  String get selectMusicFolder => 'Seleziona cartella musica';

  @override
  String get folderWithAudioFiles => 'Cartella con file MP3/WAV';

  @override
  String get sameFolderForLyrics => 'Stessa cartella per testi';

  @override
  String get selectLyricsFolder => 'Seleziona cartella testi';

  @override
  String get folderWithLyricsFiles => 'Cartella con file LRC/JSON (opzionale)';

  @override
  String get pleaseEnterPlaylistName => 'Inserisci il nome della playlist';

  @override
  String get pleaseSelectMusicFolder => 'Seleziona una cartella di musica';

  @override
  String get cropImage => 'Ritaglia immagine';

  @override
  String get photoPermissionRequired => 'Autorizzazione accesso foto richiesta';

  @override
  String get photoPermissionDenied => 'Accesso alle foto negato';

  @override
  String get imageProcessingError => 'Impossibile elaborare l\'immagine';

  @override
  String get scanningFolder => 'Scansione cartella...';

  @override
  String get importingFiles => 'Importazione file...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Importazione $current/$total file... $songs canzoni trovate';
  }

  @override
  String processingFile(Object file) {
    return 'Elaborazione di $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Aggiungi alla playlist';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Aggiunto a \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Impossibile aggiungere alla playlist: $error';
  }

  @override
  String get deleteSong => 'Elimina';

  @override
  String get importSongDialogTitle => 'Importa canzone';

  @override
  String get audioOnly => 'Solo audio';

  @override
  String get addLyricsLater => 'Aggiungerò i testi più tardi';

  @override
  String get audioWithLyricsZIP => 'Audio + ZIP con testi';

  @override
  String get importWithAllTranslations => 'Importa con tutte le traduzioni';

  @override
  String get importTranslationDialogTitle => 'Aggiungi traduzione';

  @override
  String get loadTranslationFromZip => 'Carica da archivio ZIP';

  @override
  String get loadTranslationFromJson => 'Carica da file JSON';

  @override
  String get noAudioFilesSelected => 'Nessun file audio selezionato';

  @override
  String failedToImportSongs(Object error) {
    return 'Impossibile importare le canzoni: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Impossibile importare la canzone: $error';
  }

  @override
  String get musicFolderNotSelected => 'Cartella della musica non selezionata';

  @override
  String get generateLyrics => 'Genera testi';

  @override
  String get selectTextFileOrEnterText => 'Seleziona file testo o inserisci testo';

  @override
  String get originalLanguage => 'Lingua originale';

  @override
  String get translationLanguages => 'Lingue traduzione';

  @override
  String get startMinuteForTimestamps => 'Minuto iniziale timestamp';

  @override
  String get transcriptionLanguage => 'Lingua trascrizione';

  @override
  String get generating => 'Generazione...';

  @override
  String get generate => 'Genera';

  @override
  String get deepseekApiKey => 'Chiave API DeepSeek';

  @override
  String get validateKey => 'Valida chiave';

  @override
  String get keyIsValid => 'Chiave valida';

  @override
  String get keyIsInvalid => 'Chiave non valida';

  @override
  String get lyricsGenerationSuccess => 'Testi generati con successo';

  @override
  String get lyricsGenerationError => 'Errore generazione testi';

  @override
  String get savingFiles => 'Salvataggio file...';

  @override
  String get enterText => 'Inserisci testo';

  @override
  String get transcript => 'Trascrizione';

  @override
  String get originalTextEditable => 'Testo originale (modificabile)';

  @override
  String get selectLanguageToEdit => 'Seleziona lingua da modificare';

  @override
  String get moveLineUp => 'Sposta riga in alto';

  @override
  String get moveLineDown => 'Sposta riga in basso';

  @override
  String get moveAllTranslationsUp => 'Sposta tutte le traduzioni in alto';

  @override
  String get moveAllTranslationsDown => 'Sposta tutte le traduzioni in basso';

  @override
  String get translationSaved => 'Traduzione salvata!';

  @override
  String get translationSaveFailed => 'Impossibile salvare la traduzione';

  @override
  String get loadTextTitle => 'Carica testo';

  @override
  String get noOriginalTextWarning => 'Carica prima il testo originale';

  @override
  String get selectLanguageOriginal => 'Lingua originale';

  @override
  String get startTimestampMinutes => 'Inizio timestamp (minuti)';

  @override
  String get selectLanguageTranslation => 'Lingua di traduzione';

  @override
  String get originalTextLoaded => 'Testo originale caricato con successo!';

  @override
  String get translationLoaded => 'Traduzione caricata con successo!';

  @override
  String get transcriptLoaded => 'Trascrizione caricata con successo!';

  @override
  String get selectTranslationLanguage => 'Lingua di traduzione per la trascrizione';

  @override
  String get noTranslationWarning => 'Nessuna traduzione caricata';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Discrepanza righe: $loaded righe, atteso $expected';
  }

  @override
  String get loadTextTooltip => 'Carica testo o traduzione';

  @override
  String get loadFromFile => 'Carica da file';

  @override
  String get pasteFromClipboard => 'Incolla dagli appunti';

  @override
  String get audioNotificationService => 'Servizio di notifica audio';

  @override
  String get audioNotificationServiceActive => 'Stato: ✅ Attivo';

  @override
  String get audioNotificationServiceError => 'Stato: ❌ Errore';

  @override
  String get errorLabel => 'Errore:';

  @override
  String get audioNotificationServiceDescription => 'Questo servizio fornisce notifiche quando l\'app è ridotta a icona';

  @override
  String get reorder => 'Riordina';

  @override
  String get done => 'Fatto';

  @override
  String get selectMultiple => 'Seleziona multipli';

  @override
  String get sortSongs => 'Ordina canzoni';

  @override
  String get importSong => 'Importa canzone';

  @override
  String get sortDefault => 'Predefinito';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Più recenti';

  @override
  String get sortDateAsc => 'Più vecchie';

  @override
  String get importingSongs => 'Importazione canzoni...';

  @override
  String get noSongsInPlaylist => 'Nessuna canzone in questa playlist';

  @override
  String get addSongsFromLibraryHint => 'Aggiungi brani dalla tua libreria';

  @override
  String get removedSongsFromPlaylist => 'Canzoni rimosse dalla playlist';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Errore nell\'eliminazione delle canzoni: $error';
  }

  @override
  String get deletePlaylistTitle => 'Elimina playlist';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'Sei sicuro di eliminare \"$playlist\"?';
  }

  @override
  String get failedToDeletePlaylist => 'Impossibile eliminare playlist:';

  @override
  String get specifyTranslationLanguage => 'Specificare lingua di traduzione';

  @override
  String get languageNameLabel => 'Nome lingua';

  @override
  String get languageNameHint => 'Ad esempio: Russo, Dell\'autore, Poetico';

  @override
  String get translationTypeLabel => 'Tipo di traduzione:';

  @override
  String get translationTypeNormal => 'Normale';

  @override
  String get translationTypeAuthor => 'Dell\'autore';

  @override
  String get translationTypePoetic => 'Poetico';

  @override
  String get translationTypeLiteral => 'Letterale';

  @override
  String mp3FilesCount(Object count) {
    return 'File MP3: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return '$count file importati (database saltato)';
  }

  @override
  String get databaseMerged => 'Database unito';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'Database unito, file MP3: $count';
  }

  @override
  String get databaseReplaced => 'Database sostituito';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'Database sostituito, file MP3: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Conferma sostituzione';

  @override
  String get confirmReplaceDatabaseWarning => 'Sei sicuro? Perderai tutte le canzoni e playlist esistenti!';

  @override
  String get replaceAll => 'Sostituisci tutto';

  @override
  String get selectLanguages => 'Seleziona lingue';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Selezionati: $count lingue';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Selezionati: $count';
  }

  @override
  String get promptPreset => 'Preset del prompt';

  @override
  String get balanced => 'Bilanciato';

  @override
  String get poetic => 'Poetico';

  @override
  String get literal => 'Letterale';

  @override
  String get customPromptOption => 'Personalizzato...';

  @override
  String get editPrompt => 'Modifica prompt';

  @override
  String get notSet => 'Non impostato';

  @override
  String get showOrEditApiKey => 'Mostra/Modifica chiave API';

  @override
  String get timeout => 'Timeout';

  @override
  String get model => 'Modello';

  @override
  String get resetToPreset => 'Ripristina al preset';

  @override
  String get customPrompt => 'Prompt personalizzato';

  @override
  String customPromptChars(Object count) {
    return 'Prompt personalizzato ($count caratteri)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Uso del preset: $preset';
  }

  @override
  String get characters => 'caratteri';

  @override
  String get deepSeekPromptTitle => 'Prompt DeepSeek';

  @override
  String get customPromptLabel => 'Prompt personalizzato';

  @override
  String get leaveEmptyToUseDefault => 'Lasciare vuoto per usare il prompt predefinito';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Lasciare vuoto per usare il prompt predefinito integrato nell\'applicazione';

  @override
  String get apiKeySaved => 'Chiave API salvata';

  @override
  String get enterTimeout => 'Inserire il timeout in secondi';

  @override
  String get validTimeoutRange => 'Si prega di inserire un timeout valido (1-3600 secondi)';

  @override
  String get customTimeout => 'Timeout personalizzato';

  @override
  String get timeoutSeconds => 'Timeout (secondi)';

  @override
  String timeoutSetTo(Object value) {
    return 'Timeout impostato a $value secondi';
  }

  @override
  String get customModel => 'Modello personalizzato';

  @override
  String get modelName => 'Nome del modello';

  @override
  String get enterModelName => 'Inserire il nome esatto del modello fornito da DeepSeek API';

  @override
  String get pleaseEnterModelName => 'Si prega di inserire un nome del modello';

  @override
  String modelSetTo(Object value) {
    return 'Modello impostato su $value';
  }

  @override
  String get editCustomPrompt => 'Modifica prompt personalizzato';

  @override
  String get editPresetPrompt => 'Modifica prompt preimpostato';

  @override
  String get editingPreset => 'Modifica del preset';

  @override
  String get anyChangesSaveAsCustom => 'Qualsiasi modifica verrà salvata come prompt personalizzato. Utilizzare il pulsante \'Ripristina\' per ripristinare il preset originale.';

  @override
  String get useResetToRestorePreset => 'Utilizzare il pulsante \'Ripristina\' per ripristinare il preset originale';

  @override
  String get prompt => 'Prompt';

  @override
  String get promptSaved => 'Prompt salvato';

  @override
  String get usingPresetPrompt => 'Uso del prompt preimpostato';

  @override
  String get apiKeyHint => 'Chiave API';

  @override
  String get modelHint => 'es. deepseek-v3';

  @override
  String get enterExactModelName => 'Inserire il nome esatto del modello fornito da DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'Si prega di inserire prima la chiave API';

  @override
  String get maxTokensRegular => 'Max Tokens (Normale)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Limite token per le normali richieste di traduzione';

  @override
  String get maxTokensJsonHint => 'Limite token per le richieste di generazione completa (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (normale) impostato su $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) impostato su $value';
  }

  @override
  String get refreshFolder => 'Aggiorna cartella';

  @override
  String get refreshingFolder => 'Aggiornamento cartella...';

  @override
  String get playlistCreatedWithLink => 'Playlist creata! Premi \"Aggiorna\" per caricare le canzoni dalla cartella';

  @override
  String refreshedPlaylist(Object count) {
    return 'Aggiornato: $count canzoni';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Errore di aggiornamento: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Impossibile caricare canzoni: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'La cartella della musica non esiste';

  @override
  String successfullyImportedSongs(Object count) {
    return 'Importate con successo $count canzone/i';
  }

  @override
  String get noAudioFileSelected => 'Nessun file audio selezionato';

  @override
  String get noZipArchiveSelected => 'Nessun archivio ZIP selezionato';

  @override
  String get noFolderConfigured => 'Cartella non configurata';

  @override
  String get missingLyricsTranslations => 'Testi/Traduzioni mancanti';

  @override
  String missingForSong(Object songName) {
    return 'Per \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Mancanti: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'Cosa vorresti fare?';

  @override
  String get lyricsGeneratedSuccessfully => 'Testi generati con successo';

  @override
  String get setDeepSeekApiKey => 'Si prega di impostare la chiave API DeepSeek nelle impostazioni';

  @override
  String failedToOpenSong(Object error) {
    return 'Impossibile aprire canzone: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'Elimina anche i file LRC e JSON';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Aggiunto a \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Errore nell\'aggiungere alla playlist: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return '$count canzone/i esportata/e';
  }

  @override
  String get fileNotFound => 'File non trovato';

  @override
  String get selectZipFileNotJson => 'Si prega di selezionare un file ZIP, non JSON o LRC';

  @override
  String get noFilesFoundInZip => 'Nessun file trovato nello ZIP';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Formato file ZIP non valido: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Importazione non riuscita: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return '$count traduzione/i trovata/e';
  }

  @override
  String mp3ImportError(Object error) {
    return 'Errore importazione MP3: $error';
  }

  @override
  String get importSongFirstToSearch => 'Importa prima una canzone per cercare i testi';

  @override
  String get lyricsFetched => 'Testi recuperati';

  @override
  String get lyricsFoundUseCreate => 'Testi trovati. Usa per creare un file LRC sincronizzato';

  @override
  String get deleteSelectedSongs => 'Elimina canzoni selezionate';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'Sei sicuro di voler eliminare $count canzone/i?';
  }

  @override
  String get songsDeletedSuccessfully => 'Canzoni eliminate con successo';

  @override
  String get storagePermissionRequired => 'È richiesto il permesso di archiviazione per accedere alle cartelle.';

  @override
  String get enableStoragePermission => 'Si prega di abilitare il permesso di archiviazione nelle impostazioni.';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get unableToSelectFolder => 'Impossibile selezionare la cartella. Prova alternativa:';

  @override
  String get selectFilesInstead => 'Seleziona file invece';

  @override
  String get enterFolderPath => 'Si prega di inserire un percorso della cartella';

  @override
  String get folderDoesNotExist => '✗ La cartella non esiste';

  @override
  String folderSetWithPath(Object path) {
    return 'Cartella impostata: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Errore nell\'impostazione della cartella: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'Impossibile selezionare la cartella dei testi. Prova alternativa:';

  @override
  String get useManualPath => 'Usa percorso manuale (per test)';

  @override
  String get enterFolderPathManually => 'Inserisci il percorso della cartella manualmente invece di usare il selettore';

  @override
  String get folderPathLabel => 'Percorso cartella';

  @override
  String get folderPathHint => 'Esempio: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Percorso completo alla tua cartella musicale';

  @override
  String get setPath => 'Imposta percorso';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'Seleziona archivio ZIP con testi per \"$title\"';
  }

  @override
  String get skip => 'Salta';

  @override
  String get retry => 'Riprova';

  @override
  String get failedToCopyLrcFile => 'Errore nella copia del file LRC';

  @override
  String copiedJsonFiles(Object count) {
    return '$count file JSON copiato/i';
  }

  @override
  String get failedToCopyJsonFiles => 'Errore nella copia dei file JSON';

  @override
  String failedToDeleteSong(Object error) {
    return 'Errore nell\'eliminazione della canzone: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return '$count canzone/i aggiunta/e a \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'Aggiungi $count canzone/i alla playlist';
  }

  @override
  String get failedToExportSongs => 'Errore nell\'esportazione delle canzoni';

  @override
  String get ok => 'OK';

  @override
  String deleteSongConfirm(Object song) {
    return 'Sei sicuro di voler eliminare \"$song\"?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Seleziona la cartella musicale per questa playlist';

  @override
  String get folderLinkedToPlaylist => 'Cartella collegata alla playlist';

  @override
  String get folderUnlinkedFromPlaylist => 'Cartella scollegata dalla playlist';

  @override
  String get checkFolderAccess => 'Verifica accesso';

  @override
  String get checkingPermissions => 'Verifica permessi...';

  @override
  String get folderAccessible => '✓ Cartella accessibile';

  @override
  String get folderNotAccessible => '✗ Cartella non accessibile';

  @override
  String audioFilesFound(Object count) {
    return '$count file audio trovato/i';
  }

  @override
  String lyricsFound(Object count) {
    return '$count file di testi trovato/i';
  }

  @override
  String get noAudioFiles => 'Nessun file audio trovato';

  @override
  String get noLyricsFiles => 'Nessun file di testi trovato';

  @override
  String errorCheckingAccess(Object error) {
    return 'Errore durante la verifica dell\'accesso: $error';
  }

  @override
  String get folderPathColon => 'Percorso cartella:';

  @override
  String get permissionsStatus => 'Stato permessi:';

  @override
  String get folderContent => 'Contenuto cartella:';

  @override
  String get accessGranted => '✓ Accesso concesso';

  @override
  String get accessDenied => '✗ Accesso negato';

  @override
  String get permissionRequestFailed => 'Richiesta di permessi non riuscita';

  @override
  String get pleaseGrantPermissions => 'Concedi i permessi di archiviazione per verificare la cartella';

  @override
  String get refreshOnlySongs => 'Solo brani';

  @override
  String get refreshEverything => 'Tutto';

  @override
  String get refreshDialogDescription => 'Cosa vuoi aggiornare? \"Solo brani\" velocizza il processo saltando i testi.';

  @override
  String get mostSongs => 'Più brani';

  @override
  String get playlistPlay => 'Playlist';

  @override
  String get musicNote => 'Nota musicale';

  @override
  String get favorite => 'Preferito';

  @override
  String get libraryMusic => 'Libreria';

  @override
  String get tapToSelectFolder => 'Tocca per selezionare una cartella con file audio';

  @override
  String get showVerticalSlider => 'Slider verticale';

  @override
  String get showVerticalSliderSubtitle => 'Mostra slider verticale per l\'offset nel lettore';

  @override
  String get transcriptionEnabled => 'Trascrizione attivata';

  @override
  String get transcriptionDisabled => 'Trascrizione disattivata';

  @override
  String languageSelected(String language) {
    return 'Lingua selezionata: $language';
  }

  @override
  String get noTranslationsScanning => 'Nessuna traduzione trovata, scansione cartella...';

  @override
  String translationsLoadedCount(int count) {
    return 'Traduzioni caricate: $count';
  }

  @override
  String get translationsNotFound => 'Nessuna traduzione trovata per questo brano';

  @override
  String errorLoadingTranslations(String error) {
    return 'Errore caricamento traduzioni: $error';
  }

  @override
  String languageNotAvailable(String settingLang, String availableLang) {
    return '$settingLang selezionato ma non disponibile. Apertura: $availableLang';
  }

  @override
  String get errorAudioService => 'Errore Servizio Audio';

  @override
  String get audioServiceFailed => 'Impossibile inizializzare la riproduzione audio in background.';

  @override
  String get notificationMayNotAppear => 'La notifica del lettore potrebbe non apparire.';

  @override
  String get lrcAndTranslationsSaved => 'LRC e tutte le traduzioni salvate!';

  @override
  String translationDeleted(String name) {
    return 'Traduzione \"$name\" eliminata';
  }

  @override
  String failedToDeleteTranslation(String error) {
    return 'Eliminazione fallita: $error';
  }

  @override
  String get generatingTranslations => 'Generazione traduzioni';

  @override
  String get generatingProcessing => 'Elaborazione:';

  @override
  String get generatingLines => 'Righe:';

  @override
  String generatingLinesOf(int current, int total) {
    return '$current di $total';
  }

  @override
  String generatingErrors(int count) {
    return 'Errori: $count';
  }

  @override
  String selectedLanguagesCountGen(int count) {
    return 'Selezionati: $count';
  }

  @override
  String get transcriptionSection => 'Trascrizione';

  @override
  String get translationsSection => 'Traduzioni';

  @override
  String get translationLoadedSuccess => 'Traduzione caricata con successo!';

  @override
  String get exportSuccessful => 'Esportazione riuscita!';

  @override
  String get failedToExportSong => 'Esportazione brano fallita';

  @override
  String get deleteTranslationTitle => 'Elimina traduzione';

  @override
  String deleteTranslationConfirm(String name) {
    return 'Eliminare la traduzione \"$name\"?';
  }

  @override
  String get lrcLoaded => 'File LRC caricato';

  @override
  String get noFilesLoaded => 'Nessun file trovato nell\'archivio';

  @override
  String failedToProcessArchive(String error) {
    return 'Elaborazione archivio fallita: $error';
  }

  @override
  String failedToLoadTranslationsShort(String error) {
    return 'Caricamento fallito: $error';
  }

  @override
  String get noFolderConfiguredMsg => 'Nessuna cartella configurata';

  @override
  String failedToPlaySongMsg(String error) {
    return 'Riproduzione fallita: $error';
  }

  @override
  String addedSongsToPlaylistMsg(int count, String playlist) {
    return '$count brano/i aggiunto/i a \"$playlist\"';
  }

  @override
  String failedToAddSongsMsg(String error) {
    return 'Aggiunta fallita: $error';
  }

  @override
  String addSongsButton(int count) {
    return 'Aggiungi $count';
  }

  @override
  String get removeSong => 'Rimuovi';

  @override
  String failedToRemoveSongMsg(String error) {
    return 'Rimozione fallita: $error';
  }

  @override
  String failedToReorderSongsMsg(String error) {
    return 'Riordino fallito: $error';
  }

  @override
  String failedToLoadSongsMsg(String error) {
    return 'Caricamento fallito: $error';
  }

  @override
  String errorLoadingText(String error) {
    return 'Errore caricamento testo: $error';
  }

  @override
  String lrcAndTranslationsLoaded(int count) {
    return 'LRC e $count traduzione/i caricate';
  }

  @override
  String translationsOnlyLoaded(int count) {
    return '$count traduzione/i caricate';
  }

  @override
  String get pleaseSetDeepSeekApiKey => 'Imposta la chiave API DeepSeek nelle impostazioni';

  @override
  String get lyricsGeneratedSuccessfullyMsg => 'Testi generati con successo';

  @override
  String exportShareSubject(String title) {
    return 'LingoTune export: $title con testi e traduzioni';
  }

  @override
  String get timestampOffset => 'Offset timestamp';

  @override
  String get timestampOffsetSubtitle => 'Offset predefinito in minuti per i timestamp generati';

  @override
  String get resetTimestamps => 'Ripristina timestamp';

  @override
  String get resetTimestampsConfirm => 'Ripristinare tutti i timestamp ai valori predefiniti?';

  @override
  String get resetTimestampsSuccess => 'Timestamp ripristinati ai valori predefiniti';

  @override
  String get saveAfterReset => 'Salva modifiche';

  @override
  String get saveAfterResetConfirm => 'Salvare le modifiche dopo il ripristino dei timestamp?';

  @override
  String get repeatOff => 'Ripetizione disattivata';

  @override
  String get repeatAll => 'Ripeti tutto';

  @override
  String get repeatOne => 'Ripeti uno';

  @override
  String get repeatAllPlaylists => 'Ripeti tutte le playlist';

  @override
  String get playbackSpeed => 'Velocità di riproduzione';

  @override
  String get speedNormal => 'Normale';

  @override
  String get lyricsPositionOffset => 'Ritardo sincronizzazione testo';

  @override
  String get lyricsPositionOffsetSubtitle => 'Ritardo evidenziazione in secondi (aumenta se l\'evidenziazione anticipa)';

  @override
  String get studyMode => 'Studio';

  @override
  String get studyModeTooltip => 'Modalità studio: leggi la traduzione poi riproduci ogni riga';

  @override
  String get studyModeStarted => 'Modalità studio avviata';

  @override
  String get studyModeStartedNoVoice => 'Modalità studio avviata (solo frammenti — senza voce)';

  @override
  String get ttsLangMissingTitle => 'Nessuna voce per questa lingua';

  @override
  String get ttsLangMissingBody => 'Il dispositivo non ha una voce TTS installata per la lingua di traduzione. Installa un motore TTS con questa lingua (es. Google o Yandex) in Impostazioni → Sintesi vocale, oppure continua in modalità solo frammenti (senza voce).';

  @override
  String get ttsContinueNoVoice => 'Continua senza voce';

  @override
  String get studyModeStopped => 'Modalità studio fermata';

  @override
  String get studyModeNoLyrics => 'Nessun testo sincronizzato per questa canzone';

  @override
  String get studyModeSettings => 'Impostazioni modalità studio';

  @override
  String get studyModeOrder => 'Ordine';

  @override
  String get studyModeOrderTranslationFirst => 'Prima traduzione';

  @override
  String get studyModeOrderOriginalFirst => 'Prima originale';

  @override
  String get studyModeOrderOverlay => 'Sovrapposto (originale basso)';

  @override
  String get studyModeSpeechRate => 'Velocità voce';

  @override
  String get studyModeLongPressHint => 'Pressione lunga per impostazioni';

  @override
  String get exportCurrentSong => 'Esporta canzone';

  @override
  String get studyModeOverlayTiming => 'Quando parlare';

  @override
  String get studyModeOverlayAtStart => 'A inizio riga';

  @override
  String get studyModeOverlayAtEnd => 'A fine riga';

  @override
  String get studyModeOverlayAtBoth => 'Inizio e fine';

  @override
  String get studyModeDuckVolume => 'Volume originale';

  @override
  String get studyModeOpenSettings => 'Impostazioni modalità studio';
}
