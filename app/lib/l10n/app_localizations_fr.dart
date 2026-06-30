// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Bibliothèque';

  @override
  String get playlists => 'Playlists';

  @override
  String get settings => 'Paramètres';

  @override
  String get allSongs => 'Toutes les chansons';

  @override
  String get favorites => 'Favoris';

  @override
  String get createPlaylist => 'Créer une playlist';

  @override
  String get playlistName => 'Nom de la playlist';

  @override
  String get iconOptional => 'Icône (optionnel)';

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get save => 'Enregistrer';

  @override
  String get close => 'Fermer';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get addToPlaylist => 'Ajouter à la playlist';

  @override
  String get removeFromPlaylist => 'Retirer de la playlist';

  @override
  String get addSongsToLibrary => 'Ajouter des chansons de la bibliothèque';

  @override
  String get noSongsToAdd => 'Aucune chanson à ajouter';

  @override
  String addButtonText(Object count) {
    return 'Ajouter $count';
  }

  @override
  String get selected => 'sélectionnées';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get autoScroll => 'Défilement automatique';

  @override
  String get autoScrollSubtitle => 'Défiler automatiquement vers la ligne actuelle';

  @override
  String get highlightNextLine => 'Surligner la ligne suivante';

  @override
  String get highlightNextLineSubtitle => 'Afficher la ligne suivante avec un surlignage subtil';

  @override
  String get fontSize => 'Taille de police';

  @override
  String get scrollOffset => 'Décalage du défilement';

  @override
  String get scrollOffsetSubtitle => 'Distance du haut de l\'écran en pixels';

  @override
  String get autoScrollFocusOffset => 'Décalage du focus du défilement automatique';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Position de focus initiale pour le défilement automatique (par défaut: +50)';

  @override
  String get defaultTranslationLanguage => 'Langue de traduction par défaut';

  @override
  String get defaultOriginalLanguage => 'Langue originale par défaut';

  @override
  String get russian => 'Russe';

  @override
  String get english => 'Anglais';

  @override
  String get romanian => 'Roumain';

  @override
  String get french => 'Français';

  @override
  String get german => 'Allemand';

  @override
  String get spanish => 'Espagnol';

  @override
  String get italian => 'Italien';

  @override
  String get portuguese => 'Portugais';

  @override
  String get lyricsFolder => 'Dossier paroles';

  @override
  String get useLyricsFolder => 'Utiliser le dossier paroles';

  @override
  String get useLyricsFolderDisabled => 'Désactivé - les fichiers doivent être sélectionnés avec l\'audio';

  @override
  String get setLyricsFolder => 'Définir le dossier paroles';

  @override
  String get selectFolder => 'Sélectionner un dossier';

  @override
  String get folderPath => 'Chemin du dossier';

  @override
  String get examples => 'Exemples:';

  @override
  String get defaultFolder => 'Par défaut: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Dossier actuel:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Dossier défini: $path';
  }

  @override
  String get folderSetFailed => 'Le dossier n\'existe pas ou pas d\'accès';

  @override
  String get resetToDefault => 'Réinitialiser par défaut';

  @override
  String get showCurrentFolder => 'Afficher le dossier actuel';

  @override
  String get changeFolder => 'Changer de dossier';

  @override
  String get resetToDefaultFolder => 'Réinitialiser au dossier par défaut';

  @override
  String get folderReset => 'Dossier réinitialisé par défaut';

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get clearCacheSubtitle => 'Supprimer les fichiers temporaires';

  @override
  String get cacheCleared => 'Cache vidé';

  @override
  String get resetSongLanguages => 'Réinitialiser les langues des chansons';

  @override
  String get resetSongLanguagesSubtitle => 'Utiliser la langue par défaut des paramètres';

  @override
  String get songLanguagesReset => 'Langues des chansons réinitialisées';

  @override
  String get about => 'À propos';

  @override
  String get translationsLoaded => 'Traductions chargées avec succès!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Échec du chargement des traductions: $error';
  }

  @override
  String get editTranslations => 'Modifier les traductions';

  @override
  String get loadTranslationsFromFile => 'Charger les traductions depuis un fichier';

  @override
  String get loadTextMenu => 'Charger le texte';

  @override
  String get loadTranslations => 'Charger les traductions';

  @override
  String get deleteTranslation => 'Supprimer la traduction';

  @override
  String get noFileSelected => 'Aucun fichier sélectionné';

  @override
  String get noLrcFileAssociated => 'Aucun fichier LRC associé à cette chanson';

  @override
  String get lrcFileSaved => 'Fichier LRC enregistré avec succès!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'Échec de l\'enregistrement du fichier LRC: $error';
  }

  @override
  String get exitEditMode => 'Quitter le mode édition';

  @override
  String get editTimestamps => 'Modifier les horodatages';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get language => 'Langue';

  @override
  String get loading => 'Chargement...';

  @override
  String get noSongsFound => 'Aucune chanson trouvée';

  @override
  String get noPlaylistsFound => 'Aucune playlist trouvée';

  @override
  String get selectSong => 'Sélectionnez une chanson à lire';

  @override
  String get song => 'Chanson';

  @override
  String get artist => 'Artiste';

  @override
  String get duration => 'Durée';

  @override
  String get actions => 'Actions';

  @override
  String get play => 'Lecture';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Arrêt';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get rewind10 => '-10s';

  @override
  String get forward10 => '+10s';

  @override
  String get repeat => 'Répéter';

  @override
  String get shuffle => 'Aléatoire';

  @override
  String get volume => 'Volume';

  @override
  String get speed => 'Vitesse';

  @override
  String get lyrics => 'Paroles';

  @override
  String get translations => 'Traductions';

  @override
  String get originalText => 'Texte original';

  @override
  String get translatedText => 'Texte traduit';

  @override
  String get showTranscription => 'Afficher la transcription';

  @override
  String get showTranscriptionSubtitle => 'Afficher le guide de prononciation';

  @override
  String get showTranslationFirst => 'Traduction en premier';

  @override
  String get showTranslationFirstSubtitle => 'Afficher la traduction avant le texte original';

  @override
  String get italianLang => 'Italien';

  @override
  String get portugueseLang => 'Portugais';

  @override
  String get lyricsEditor => 'Éditeur de paroles';

  @override
  String get addLine => 'Ajouter une ligne';

  @override
  String get updateLine => 'Mettre à jour la ligne';

  @override
  String get deleteLine => 'Supprimer la ligne';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get moveUp => 'Monter';

  @override
  String get moveDown => 'Descendre';

  @override
  String get autoSyncLyrics => 'Synchronisation automatique des paroles';

  @override
  String get exportLrc => 'Exporter LRC (Original)';

  @override
  String get exportJson => 'Exporter JSON (Traductions)';

  @override
  String get markTimestamp => 'Marquer l\'horodatage (Entrée)';

  @override
  String get original => 'Original';

  @override
  String get translation => 'Traduction';

  @override
  String get audioFile => 'Fichier audio';

  @override
  String get songTitle => 'Titre de la chanson';

  @override
  String get browse => 'Parcourir';

  @override
  String get audioControls => 'Contrôles audio';

  @override
  String get addEditLine => 'Ajouter/Modifier la ligne';

  @override
  String get instructions => 'Instructions';

  @override
  String get lyricsEditorInstructions => 'Instructions de synchronisation LRC:\n\n1. Sélectionnez un fichier audio en utilisant le bouton Parcourir\n2. Entrez le titre de la chanson et l\'artiste (optionnel)\n3. Cliquez sur Lecture pour démarrer l\'audio\n4. Lorsqu\'une ligne est chantée, tapez le texte original dans le champ \'Original\'\n5. Appuyez sur Entrée ou \'Marquer l\'horodatage\' pour enregistrer l\'horodatage\n6. Optionnellement ajoutez une traduction dans le champ \'Traduction\'\n7. Répétez les étapes 4-6 pour chaque ligne\n8. Utilisez \'Exporter LRC\' pour enregistrer le texte original avec les horodatages\n9. Utilisez \'Exporter JSON\' pour enregistrer les traductions\n\nConseils:\n- Utilisez -10s/+10s pour naviguer rapidement dans la chanson\n- Vous pouvez réorganiser les lignes en utilisant Monter/Descendre\n- Chargez les fichiers JSON précédemment enregistrés pour modifier les traductions';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get welcomeMessage => 'Commencez votre parcours d\'apprentissage des langues avec la musique!';

  @override
  String get importSongs => 'Importer des chansons';

  @override
  String get importSongsSubtitle => 'Ajouter des fichiers audio depuis votre appareil';

  @override
  String get manageLibrary => 'Gérer la bibliothèque';

  @override
  String get manageLibrarySubtitle => 'Organisez vos chansons et playlists';

  @override
  String get syncLyrics => 'Synchroniser les paroles';

  @override
  String get syncLyricsSubtitle => 'Synchronisation automatique des paroles avec l\'audio';

  @override
  String get languageLearning => 'Apprentissage des langues • Musique • Traductions';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Développé par';

  @override
  String get website => 'Site web';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Échec de la création de la playlist: $error';
  }

  @override
  String get playlistCreated => 'Playlist créée avec succès!';

  @override
  String get playlistDeleted => 'Playlist supprimée avec succès!';

  @override
  String get playlistUpdated => 'Playlist mise à jour avec succès!';

  @override
  String get songAdded => 'Chanson ajoutée avec succès!';

  @override
  String get songRemoved => 'Chanson supprimée avec succès!';

  @override
  String get songDeleted => 'Chanson supprimée avec succès!';

  @override
  String get error => 'Erreur';

  @override
  String get warning => 'Avertissement';

  @override
  String get info => 'Information';

  @override
  String get success => 'Succès';

  @override
  String get confirm => 'Confirmer';

  @override
  String get areYouSure => 'Êtes-vous sûr?';

  @override
  String get unsavedChanges => 'Vous avez des modifications non enregistrées. Continuer?';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get appLanguage => 'Langue de l\'application';

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
  String get welcomeToLingoTune => 'Bienvenue dans LingoTune';

  @override
  String get folderSetupMessage => 'Choisissez un dossier pour stocker les paroles et traductions (fichiers LRC et JSON). Cela facilite l\'organisation de votre bibliothèque musicale.';

  @override
  String get selectFolderNow => 'Sélectionner le dossier maintenant';

  @override
  String get goToSettings => 'Aller aux paramètres';

  @override
  String get setupLater => 'Configuration plus tard';

  @override
  String get useDefaultFolder => 'Utiliser le dossier par défaut';

  @override
  String get databaseFound => 'Base de données trouvée dans le fichier d\'import';

  @override
  String get importDatabaseQuestion => 'Voulez-vous également importer la base de données?';

  @override
  String get mergeDatabase => 'Fusionner';

  @override
  String get replaceDatabase => 'Remplacer';

  @override
  String get importDatabase => 'Importer la base de données';

  @override
  String get skipDatabase => 'Ignorer la base de données';

  @override
  String get mergeDatabaseDescription => 'Fusionner les chansons importées avec votre bibliothèque (ajoute uniquement les nouveaux éléments)';

  @override
  String get replaceDatabaseDescription => 'Remplacer toute votre bibliothèque par la base de données importée (vous perdrez toutes les données existantes)';

  @override
  String get exporting => 'Exportation...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Exportation $current sur $total chansons';
  }

  @override
  String get exportDatabaseIncluded => 'Base de données incluse dans l\'export';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'Importé $fileCount fichier(s) et base de données';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'Importé $fileCount fichier(s)';
  }

  @override
  String get chinese => 'Chinois';

  @override
  String get arabic => 'Arabe';

  @override
  String get colorTheme => 'Thème de couleur';

  @override
  String get themeColorPurple => 'Violet';

  @override
  String get themeColorBlue => 'Bleu';

  @override
  String get themeColorGreen => 'Vert';

  @override
  String get themeColorOrange => 'Orange';

  @override
  String get themeColorRed => 'Rouge';

  @override
  String get themeColorPink => 'Rose';

  @override
  String get themeColorDeepOrange => 'Orange foncé';

  @override
  String get themeColorDarkRed => 'Rouge foncé';

  @override
  String get themeColorTeal => 'Turquoise';

  @override
  String get themeColorCyan => 'Cyan';

  @override
  String get themeColorAmber => 'Ambre';

  @override
  String get themeColorLime => 'Vert citron';

  @override
  String get ukrainianLang => 'Ukrainien';

  @override
  String get font => 'Police';

  @override
  String get fontSettings => 'Paramètres de police';

  @override
  String get systemFont => 'Système';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Taille du texte principal';

  @override
  String get mainTextBold => 'Texte principal en gras';

  @override
  String get translationSize => 'Taille de la traduction';

  @override
  String get translationBold => 'Traduction en gras';

  @override
  String get transcriptSize => 'Taille de la transcription';

  @override
  String get transcriptBold => 'Transcription en gras';

  @override
  String get defaultStartScreen => 'Écran de démarrage par défaut';

  @override
  String get defaultStartScreenSubtitle => 'Écran à afficher au démarrage de l\'application';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Ajouter à la bibliothèque lors de l\'ajout à une playlist';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Ajouter automatiquement les chansons à la bibliothèque lors de leur ajout à une playlist';

  @override
  String get serviceMessages => 'Messages de service';

  @override
  String get serviceMessagesSubtitle => 'Afficher les notifications de service sur la traduction et la transcription';

  @override
  String get includeMp3Files => 'Inclure les fichiers MP3';

  @override
  String get includeMp3FilesSubtitle => 'Cela augmentera la taille de l\'archive';

  @override
  String get importMp3Files => 'Importer les fichiers MP3';

  @override
  String get importMp3FilesSubtitle => 'Ajouter des fichiers musicaux à la bibliothèque';

  @override
  String get exportSongs => 'Exporter les chansons';

  @override
  String get import => 'Importer';

  @override
  String get addMultiple => 'Sélectionner plusieurs';

  @override
  String get addToPlaylistShort => 'Ajouter';

  @override
  String get deleteShort => 'Supprimer';

  @override
  String get selectAllShort => 'Tout';

  @override
  String get deselectAllShort => 'Effacer';

  @override
  String get exitSelectionMode => 'Quitter le mode de sélection';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get deleteSelected => 'Supprimer la sélection';

  @override
  String get addMultipleToPlaylist => 'Ajouter à la playlist';

  @override
  String get coverArt => 'Pochette';

  @override
  String get playlistCover => 'Pochette de playlist';

  @override
  String get selectFromGallery => 'Sélectionner depuis la galerie';

  @override
  String get removeCover => 'Supprimer la pochette';

  @override
  String get coverUpdated => 'Pochette mise à jour';

  @override
  String get coverRemoved => 'Pochette supprimée';

  @override
  String errorWithMessage(Object error) {
    return 'Erreur: $error';
  }

  @override
  String get importFolders => 'Importer des dossiers';

  @override
  String get selectMusicFolder => 'Sélectionner le dossier de musique';

  @override
  String get folderWithAudioFiles => 'Dossier avec fichiers MP3/WAV';

  @override
  String get sameFolderForLyrics => 'Même dossier pour les paroles';

  @override
  String get selectLyricsFolder => 'Sélectionner le dossier des paroles';

  @override
  String get folderWithLyricsFiles => 'Dossier avec fichiers LRC/JSON (optionnel)';

  @override
  String get pleaseEnterPlaylistName => 'Veuillez entrer le nom de la playlist';

  @override
  String get pleaseSelectMusicFolder => 'Veuillez sélectionner un dossier de musique';

  @override
  String get cropImage => 'Rogner l\'image';

  @override
  String get photoPermissionRequired => 'Autorisation d\'accès aux photos requise';

  @override
  String get photoPermissionDenied => 'Accès aux photos refusé';

  @override
  String get imageProcessingError => 'Échec du traitement de l\'image';

  @override
  String get scanningFolder => 'Scan du dossier...';

  @override
  String get importingFiles => 'Importation des fichiers...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Importation $current/$total fichiers... $songs chansons trouvées';
  }

  @override
  String processingFile(Object file) {
    return 'Traitement de $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Ajouter à la playlist';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Ajouté à \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Échec de l\'ajout à la playlist: $error';
  }

  @override
  String get deleteSong => 'Supprimer';

  @override
  String get importSongDialogTitle => 'Importer une chanson';

  @override
  String get audioOnly => 'Audio uniquement';

  @override
  String get addLyricsLater => 'Ajouter les paroles plus tard';

  @override
  String get audioWithLyricsZIP => 'Audio + ZIP avec paroles';

  @override
  String get importWithAllTranslations => 'Importer avec toutes les traductions';

  @override
  String get importTranslationDialogTitle => 'Ajouter une traduction';

  @override
  String get loadTranslationFromZip => 'Charger depuis l\'archive ZIP';

  @override
  String get loadTranslationFromJson => 'Charger depuis le fichier JSON';

  @override
  String get noAudioFilesSelected => 'Aucun fichier audio sélectionné';

  @override
  String failedToImportSongs(Object error) {
    return 'Échec de l\'importation des chansons: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Échec de l\'importation de la chanson: $error';
  }

  @override
  String get musicFolderNotSelected => 'Dossier de musique non sélectionné';

  @override
  String get generateLyrics => 'Générer paroles';

  @override
  String get selectTextFileOrEnterText => 'Sélectionner fichier texte ou entrer texte';

  @override
  String get originalLanguage => 'Langue originale';

  @override
  String get translationLanguages => 'Langues de traduction';

  @override
  String get startMinuteForTimestamps => 'Minute de début pour horodatage';

  @override
  String get transcriptionLanguage => 'Langue de transcription';

  @override
  String get generating => 'Génération...';

  @override
  String get generate => 'Générer';

  @override
  String get deepseekApiKey => 'Clé API DeepSeek';

  @override
  String get validateKey => 'Valider clé';

  @override
  String get keyIsValid => 'Clé valide';

  @override
  String get keyIsInvalid => 'Clé invalide';

  @override
  String get lyricsGenerationSuccess => 'Paroles générées avec succès';

  @override
  String get lyricsGenerationError => 'Échec de génération des paroles';

  @override
  String get savingFiles => 'Enregistrement fichiers...';

  @override
  String get enterText => 'Entrer texte';

  @override
  String get transcript => 'Transcription';

  @override
  String get originalTextEditable => 'Texte original (modifiable)';

  @override
  String get selectLanguageToEdit => 'Sélectionner la langue à modifier';

  @override
  String get moveLineUp => 'Déplacer la ligne vers le haut';

  @override
  String get moveLineDown => 'Déplacer la ligne vers le bas';

  @override
  String get moveAllTranslationsUp => 'Déplacer toutes les traductions vers le haut';

  @override
  String get moveAllTranslationsDown => 'Déplacer toutes les traductions vers le bas';

  @override
  String get translationSaved => 'Traduction enregistrée!';

  @override
  String get translationSaveFailed => 'Échec de l\'enregistrement de la traduction';

  @override
  String get loadTextTitle => 'Charger le texte';

  @override
  String get noOriginalTextWarning => 'Veuillez d\'abord charger le texte original';

  @override
  String get selectLanguageOriginal => 'Langue d\'origine';

  @override
  String get startTimestampMinutes => 'Début de l\'horodatage (minutes)';

  @override
  String get selectLanguageTranslation => 'Langue de traduction';

  @override
  String get originalTextLoaded => 'Texte original chargé avec succès!';

  @override
  String get translationLoaded => 'Traduction chargée avec succès!';

  @override
  String get transcriptLoaded => 'Transcription chargée avec succès!';

  @override
  String get selectTranslationLanguage => 'Langue de traduction pour la transcription';

  @override
  String get noTranslationWarning => 'Aucune traduction chargée';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Non-concordance des lignes: $loaded lignes, attendu $expected';
  }

  @override
  String get loadTextTooltip => 'Charger du texte ou une traduction';

  @override
  String get loadFromFile => 'Charger depuis un fichier';

  @override
  String get pasteFromClipboard => 'Coller depuis le presse-papiers';

  @override
  String get audioNotificationService => 'Service de notification audio';

  @override
  String get audioNotificationServiceActive => 'Statut: ✅ Actif';

  @override
  String get audioNotificationServiceError => 'Statut: ❌ Erreur';

  @override
  String get errorLabel => 'Erreur:';

  @override
  String get audioNotificationServiceDescription => 'Ce service fournit des notifications lorsque l\'application est minimisée';

  @override
  String get reorder => 'Réorganiser';

  @override
  String get done => 'Terminé';

  @override
  String get selectMultiple => 'Sélectionner plusieurs';

  @override
  String get sortSongs => 'Trier chansons';

  @override
  String get importSong => 'Importer chanson';

  @override
  String get sortDefault => 'Par défaut';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Plus récentes';

  @override
  String get sortDateAsc => 'Plus anciennes';

  @override
  String get importingSongs => 'Importation chansons...';

  @override
  String get noSongsInPlaylist => 'Aucune chanson dans cette playlist';

  @override
  String get addSongsFromLibraryHint => 'Ajouter des chansons de votre bibliothèque';

  @override
  String get removedSongsFromPlaylist => 'Chansons retirées de la playlist';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Erreur lors de la suppression des chansons: $error';
  }

  @override
  String get deletePlaylistTitle => 'Supprimer la playlist';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'Voulez-vous vraiment supprimer \"$playlist\"?';
  }

  @override
  String get failedToDeletePlaylist => 'Échec de la suppression de la playlist:';

  @override
  String get specifyTranslationLanguage => 'Spécifier la langue de traduction';

  @override
  String get languageNameLabel => 'Nom de la langue';

  @override
  String get languageNameHint => 'Par exemple: Russe, Auteur, Poétique';

  @override
  String get translationTypeLabel => 'Type de traduction:';

  @override
  String get translationTypeNormal => 'Normal';

  @override
  String get translationTypeAuthor => 'Auteur';

  @override
  String get translationTypePoetic => 'Poétique';

  @override
  String get translationTypeLiteral => 'Littéral';

  @override
  String mp3FilesCount(Object count) {
    return 'Fichiers MP3: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return '$count fichier(s) importé(s) (base de données ignorée)';
  }

  @override
  String get databaseMerged => 'Base de données fusionnée';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'Base de données fusionnée, fichiers MP3: $count';
  }

  @override
  String get databaseReplaced => 'Base de données remplacée';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'Base de données remplacée, fichiers MP3: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Confirmer le remplacement';

  @override
  String get confirmReplaceDatabaseWarning => 'Êtes-vous sûr? Vous perdrez toutes les chansons et playlists existantes!';

  @override
  String get replaceAll => 'Tout remplacer';

  @override
  String get selectLanguages => 'Sélectionner les langues';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Sélectionné: $count langues';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Sélectionné: $count';
  }

  @override
  String get promptPreset => 'Préréglage de prompt';

  @override
  String get balanced => 'Équilibré';

  @override
  String get poetic => 'Poétique';

  @override
  String get literal => 'Littéral';

  @override
  String get customPromptOption => 'Personnalisé...';

  @override
  String get editPrompt => 'Éditer le prompt';

  @override
  String get notSet => 'Non défini';

  @override
  String get showOrEditApiKey => 'Afficher/Éditer la clé API';

  @override
  String get timeout => 'Délai d\'attente';

  @override
  String get model => 'Modèle';

  @override
  String get resetToPreset => 'Réinitialiser au préréglage';

  @override
  String get customPrompt => 'Prompt personnalisé';

  @override
  String customPromptChars(Object count) {
    return 'Prompt personnalisé ($count caractères)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Utilisation du préréglage: $preset';
  }

  @override
  String get characters => 'caractères';

  @override
  String get deepSeekPromptTitle => 'Prompt DeepSeek';

  @override
  String get customPromptLabel => 'Prompt personnalisé';

  @override
  String get leaveEmptyToUseDefault => 'Laisser vide pour utiliser le prompt par défaut';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Laisser vide pour utiliser le prompt par défaut intégré dans l\'application';

  @override
  String get apiKeySaved => 'Clé API sauvegardée';

  @override
  String get enterTimeout => 'Entrez le délai d\'attente en secondes';

  @override
  String get validTimeoutRange => 'Veuillez entrer un délai d\'attente valide (1-3600 secondes)';

  @override
  String get customTimeout => 'Délai d\'attente personnalisé';

  @override
  String get timeoutSeconds => 'Délai d\'attente (secondes)';

  @override
  String timeoutSetTo(Object value) {
    return 'Délai d\'attente défini sur $value secondes';
  }

  @override
  String get customModel => 'Modèle personnalisé';

  @override
  String get modelName => 'Nom du modèle';

  @override
  String get enterModelName => 'Entrez le nom exact du modèle fourni par DeepSeek API';

  @override
  String get pleaseEnterModelName => 'Veuillez entrer un nom de modèle';

  @override
  String modelSetTo(Object value) {
    return 'Modèle défini sur $value';
  }

  @override
  String get editCustomPrompt => 'Éditer le prompt personnalisé';

  @override
  String get editPresetPrompt => 'Éditer le prompt préréglé';

  @override
  String get editingPreset => 'Édition du préréglage';

  @override
  String get anyChangesSaveAsCustom => 'Toute modification sera sauvegardée comme un prompt personnalisé. Utilisez le bouton \'Réinitialiser\' pour restaurer le préréglage original.';

  @override
  String get useResetToRestorePreset => 'Utilisez le bouton \'Réinitialiser\' pour restaurer le préréglage original';

  @override
  String get prompt => 'Prompt';

  @override
  String get promptSaved => 'Prompt sauvegardé';

  @override
  String get usingPresetPrompt => 'Utilisation du prompt préréglé';

  @override
  String get apiKeyHint => 'Clé API';

  @override
  String get modelHint => 'ex. deepseek-v3';

  @override
  String get enterExactModelName => 'Entrez le nom exact du modèle fourni par DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'Veuillez entrer la clé API d\'abord';

  @override
  String get maxTokensRegular => 'Max Tokens (Normal)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Limite de tokens pour les demandes de traduction normales';

  @override
  String get maxTokensJsonHint => 'Limite de tokens pour les demandes de génération complète (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (normal) défini sur $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) défini sur $value';
  }

  @override
  String get refreshFolder => 'Actualiser le dossier';

  @override
  String get refreshingFolder => 'Actualisation du dossier...';

  @override
  String get playlistCreatedWithLink => 'Playlist créée ! Appuyez sur \"Actualiser\" pour charger les chansons du dossier';

  @override
  String refreshedPlaylist(Object count) {
    return 'Actualisé : $count chansons';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Erreur d\'actualisation : $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Erreur lors du chargement des chansons: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'Le dossier de musique n\'existe pas';

  @override
  String successfullyImportedSongs(Object count) {
    return '$count chanson(s) importée(s) avec succès';
  }

  @override
  String get noAudioFileSelected => 'Aucun fichier audio sélectionné';

  @override
  String get noZipArchiveSelected => 'Aucune archive ZIP sélectionnée';

  @override
  String get noFolderConfigured => 'Dossier non configuré';

  @override
  String get missingLyricsTranslations => 'Paroles/Traductions manquantes';

  @override
  String missingForSong(Object songName) {
    return 'Pour \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Manquant: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'Que souhaitez-vous faire?';

  @override
  String get lyricsGeneratedSuccessfully => 'Paroles générées avec succès';

  @override
  String get setDeepSeekApiKey => 'Veuillez configurer la clé API DeepSeek dans les paramètres';

  @override
  String failedToOpenSong(Object error) {
    return 'Erreur lors de l\'ouverture de la chanson: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'Supprimer également les fichiers LRC et JSON';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Ajouté à \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Erreur lors de l\'ajout à la playlist: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return '$count chansons exportées';
  }

  @override
  String get fileNotFound => 'Fichier non trouvé';

  @override
  String get selectZipFileNotJson => 'Veuillez sélectionner un fichier ZIP, pas JSON ou LRC';

  @override
  String get noFilesFoundInZip => 'Aucun fichier trouvé dans le ZIP';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Format de fichier ZIP invalide: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Échec de l\'import: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return '$count traduction(s) trouvée(s)';
  }

  @override
  String mp3ImportError(Object error) {
    return 'Erreur d\'import MP3: $error';
  }

  @override
  String get importSongFirstToSearch => 'Importez d\'abord une chanson pour rechercher les paroles';

  @override
  String get lyricsFetched => 'Paroles récupérées';

  @override
  String get lyricsFoundUseCreate => 'Paroles trouvées. Utilisez pour créer un fichier LRC synchronisé';

  @override
  String get deleteSelectedSongs => 'Supprimer les chansons sélectionnées';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'Êtes-vous sûr de vouloir supprimer $count chanson(s)?';
  }

  @override
  String get songsDeletedSuccessfully => 'Chansons supprimées avec succès';

  @override
  String get storagePermissionRequired => 'L\'autorisation de stockage est requise pour accéder aux dossiers.';

  @override
  String get enableStoragePermission => 'Veuillez activer l\'autorisation de stockage dans les paramètres.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get unableToSelectFolder => 'Impossible de sélectionner le dossier. Essayez l\'alternative:';

  @override
  String get selectFilesInstead => 'Sélectionner des fichiers à la place';

  @override
  String get enterFolderPath => 'Veuillez entrer un chemin de dossier';

  @override
  String get folderDoesNotExist => '✗ Le dossier n\'existe pas';

  @override
  String folderSetWithPath(Object path) {
    return 'Dossier défini: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Erreur lors de la définition du dossier: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'Impossible de sélectionner le dossier des paroles. Essayez l\'alternative:';

  @override
  String get useManualPath => 'Utiliser le chemin manuel (pour tests)';

  @override
  String get enterFolderPathManually => 'Entrez le chemin du dossier manuellement au lieu d\'utiliser le sélecteur de dossier';

  @override
  String get folderPathLabel => 'Chemin du dossier';

  @override
  String get folderPathHint => 'Exemple: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Chemin complet vers votre dossier de musique';

  @override
  String get setPath => 'Définir le chemin';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'Sélectionner l\'archive ZIP avec les paroles pour \"$title\"';
  }

  @override
  String get skip => 'Passer';

  @override
  String get retry => 'Réessayer';

  @override
  String get failedToCopyLrcFile => 'Erreur lors de la copie du fichier LRC';

  @override
  String copiedJsonFiles(Object count) {
    return '$count fichier(s) JSON copié(s)';
  }

  @override
  String get failedToCopyJsonFiles => 'Erreur lors de la copie des fichiers JSON';

  @override
  String failedToDeleteSong(Object error) {
    return 'Erreur lors de la suppression de la chanson: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return '$count chanson(s) ajoutée(s) à \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'Ajouter $count chanson(s) à la playlist';
  }

  @override
  String get failedToExportSongs => 'Erreur lors de l\'export des chansons';

  @override
  String get ok => 'OK';

  @override
  String deleteSongConfirm(Object song) {
    return 'Êtes-vous sûr de vouloir supprimer \"$song\"?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Sélectionner le dossier de musique pour cette playlist';

  @override
  String get folderLinkedToPlaylist => 'Dossier lié à la playlist';

  @override
  String get folderUnlinkedFromPlaylist => 'Dossier dissocié de la playlist';

  @override
  String get checkFolderAccess => 'Vérifier l\'accès';

  @override
  String get checkingPermissions => 'Vérification des autorisations...';

  @override
  String get folderAccessible => '✓ Dossier accessible';

  @override
  String get folderNotAccessible => '✗ Dossier inaccessible';

  @override
  String audioFilesFound(Object count) {
    return '$count fichier(s) audio trouvé(s)';
  }

  @override
  String lyricsFound(Object count) {
    return '$count fichier(s) de paroles trouvé(s)';
  }

  @override
  String get noAudioFiles => 'Aucun fichier audio trouvé';

  @override
  String get noLyricsFiles => 'Aucun fichier de paroles trouvé';

  @override
  String errorCheckingAccess(Object error) {
    return 'Erreur lors de la vérification de l\'accès: $error';
  }

  @override
  String get folderPathColon => 'Chemin du dossier:';

  @override
  String get permissionsStatus => 'État des autorisations:';

  @override
  String get folderContent => 'Contenu du dossier:';

  @override
  String get accessGranted => '✓ Accès accordé';

  @override
  String get accessDenied => '✗ Accès refusé';

  @override
  String get permissionRequestFailed => 'Échec de la demande d\'autorisation';

  @override
  String get pleaseGrantPermissions => 'Veuillez accorder les autorisations de stockage pour vérifier le dossier';

  @override
  String get refreshOnlySongs => 'Seulement les chansons';

  @override
  String get refreshEverything => 'Tout';

  @override
  String get refreshDialogDescription => 'Que souhaitez-vous mettre à jour? \"Seulement les chansons\" accélère le processus en ignorant les paroles.';

  @override
  String get mostSongs => 'Le plus de chansons';

  @override
  String get playlistPlay => 'Playlist';

  @override
  String get musicNote => 'Note de musique';

  @override
  String get favorite => 'Favori';

  @override
  String get libraryMusic => 'Bibliothèque';

  @override
  String get tapToSelectFolder => 'Appuyez pour sélectionner un dossier avec des fichiers audio';

  @override
  String get showVerticalSlider => 'Slider vertical';

  @override
  String get showVerticalSliderSubtitle => 'Afficher le slider de décalage vertical dans le lecteur';

  @override
  String get transcriptionEnabled => 'Transcription activée';

  @override
  String get transcriptionDisabled => 'Transcription désactivée';

  @override
  String languageSelected(String language) {
    return 'Langue sélectionnée : $language';
  }

  @override
  String get noTranslationsScanning => 'Aucune traduction trouvée, analyse du dossier...';

  @override
  String translationsLoadedCount(int count) {
    return 'Traductions chargées : $count';
  }

  @override
  String get translationsNotFound => 'Aucune traduction trouvée pour cette chanson';

  @override
  String errorLoadingTranslations(String error) {
    return 'Erreur de chargement des traductions : $error';
  }

  @override
  String languageNotAvailable(String settingLang, String availableLang) {
    return '$settingLang sélectionné mais indisponible. Ouverture : $availableLang';
  }

  @override
  String get errorAudioService => 'Erreur Audio Service';

  @override
  String get audioServiceFailed => 'Échec de l\'initialisation de la lecture audio en arrière-plan.';

  @override
  String get notificationMayNotAppear => 'La notification du lecteur peut ne pas apparaître.';

  @override
  String get lrcAndTranslationsSaved => 'LRC et toutes les traductions enregistrées !';

  @override
  String translationDeleted(String name) {
    return 'Traduction \"$name\" supprimée';
  }

  @override
  String failedToDeleteTranslation(String error) {
    return 'Échec de suppression : $error';
  }

  @override
  String get generatingTranslations => 'Génération des traductions';

  @override
  String get generatingProcessing => 'Traitement :';

  @override
  String get generatingLines => 'Lignes :';

  @override
  String generatingLinesOf(int current, int total) {
    return '$current sur $total';
  }

  @override
  String generatingErrors(int count) {
    return 'Erreurs : $count';
  }

  @override
  String selectedLanguagesCountGen(int count) {
    return 'Sélectionné : $count';
  }

  @override
  String get transcriptionSection => 'Transcription';

  @override
  String get translationsSection => 'Traductions';

  @override
  String get translationLoadedSuccess => 'Traduction chargée avec succès !';

  @override
  String get exportSuccessful => 'Export réussi !';

  @override
  String get failedToExportSong => 'Échec de l\'export de la chanson';

  @override
  String get deleteTranslationTitle => 'Supprimer la traduction';

  @override
  String deleteTranslationConfirm(String name) {
    return 'Supprimer la traduction \"$name\" ?';
  }

  @override
  String get lrcLoaded => 'Fichier LRC chargé';

  @override
  String get noFilesLoaded => 'Aucun fichier trouvé dans l\'archive';

  @override
  String failedToProcessArchive(String error) {
    return 'Échec du traitement de l\'archive : $error';
  }

  @override
  String failedToLoadTranslationsShort(String error) {
    return 'Chargement échoué : $error';
  }

  @override
  String get noFolderConfiguredMsg => 'Aucun dossier configuré';

  @override
  String failedToPlaySongMsg(String error) {
    return 'Échec de lecture : $error';
  }

  @override
  String addedSongsToPlaylistMsg(int count, String playlist) {
    return '$count chanson(s) ajoutée(s) à \"$playlist\"';
  }

  @override
  String failedToAddSongsMsg(String error) {
    return 'Échec de l\'ajout : $error';
  }

  @override
  String addSongsButton(int count) {
    return 'Ajouter $count';
  }

  @override
  String get removeSong => 'Retirer';

  @override
  String failedToRemoveSongMsg(String error) {
    return 'Échec du retrait : $error';
  }

  @override
  String failedToReorderSongsMsg(String error) {
    return 'Réorganisation échouée : $error';
  }

  @override
  String failedToLoadSongsMsg(String error) {
    return 'Chargement échoué : $error';
  }

  @override
  String errorLoadingText(String error) {
    return 'Erreur de chargement du texte : $error';
  }

  @override
  String lrcAndTranslationsLoaded(int count) {
    return 'LRC et $count traduction(s) chargées';
  }

  @override
  String translationsOnlyLoaded(int count) {
    return '$count traduction(s) chargées';
  }

  @override
  String get pleaseSetDeepSeekApiKey => 'Veuillez définir la clé API DeepSeek dans les paramètres';

  @override
  String get lyricsGeneratedSuccessfullyMsg => 'Paroles générées avec succès';

  @override
  String exportShareSubject(String title) {
    return 'LingoTune export : $title avec paroles et traductions';
  }

  @override
  String get timestampOffset => 'Décalage des horodatages';

  @override
  String get timestampOffsetSubtitle => 'Décalage par défaut en minutes pour les horodatages générés';

  @override
  String get resetTimestamps => 'Réinitialiser les horodatages';

  @override
  String get resetTimestampsConfirm => 'Réinitialiser tous les horodatages aux valeurs par défaut ?';

  @override
  String get resetTimestampsSuccess => 'Horodatages réinitialisés aux valeurs par défaut';

  @override
  String get saveAfterReset => 'Enregistrer les modifications';

  @override
  String get saveAfterResetConfirm => 'Enregistrer les modifications après la réinitialisation ?';

  @override
  String get repeatOff => 'Répétition désactivée';

  @override
  String get repeatAll => 'Répéter tout';

  @override
  String get repeatOne => 'Répéter un';

  @override
  String get repeatAllPlaylists => 'Répéter toutes les listes';

  @override
  String get playbackSpeed => 'Vitesse de lecture';

  @override
  String get speedNormal => 'Normale';

  @override
  String get lyricsPositionOffset => 'Délai de synchronisation des paroles';

  @override
  String get lyricsPositionOffsetSubtitle => 'Délai de surbrillance en secondes (augmentez si la surbrillance devance)';

  @override
  String get studyMode => 'Étude';

  @override
  String get studyModeTooltip => 'Mode étude : lire la traduction puis jouer chaque ligne';

  @override
  String get studyModeStarted => 'Mode étude démarré';

  @override
  String get studyModeStopped => 'Mode étude arrêté';

  @override
  String get studyModeNoLyrics => 'Pas de paroles synchronisées pour cette chanson';

  @override
  String get studyModeSettings => 'Paramètres du mode étude';

  @override
  String get studyModeOrder => 'Ordre';

  @override
  String get studyModeOrderTranslationFirst => 'Traduction d\'abord';

  @override
  String get studyModeOrderOriginalFirst => 'Original d\'abord';

  @override
  String get studyModeOrderOverlay => 'Superposé (original réduit)';

  @override
  String get studyModeSpeechRate => 'Vitesse de voix';

  @override
  String get studyModeLongPressHint => 'Appui long pour les réglages';

  @override
  String get exportCurrentSong => 'Exporter la chanson';

  @override
  String get studyModeOverlayTiming => 'Quand parler';

  @override
  String get studyModeOverlayAtStart => 'Au début de la ligne';

  @override
  String get studyModeOverlayAtEnd => 'À la fin de la ligne';

  @override
  String get studyModeOverlayAtBoth => 'Début et fin';

  @override
  String get studyModeDuckVolume => 'Volume de l\'original';

  @override
  String get studyModeOpenSettings => 'Paramètres du mode étude';
}
