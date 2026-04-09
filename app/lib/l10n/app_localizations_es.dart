// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Biblioteca';

  @override
  String get playlists => 'Listas de reproducción';

  @override
  String get settings => 'Ajustes';

  @override
  String get allSongs => 'Todas las canciones';

  @override
  String get favorites => 'Favoritos';

  @override
  String get createPlaylist => 'Crear lista de reproducción';

  @override
  String get playlistName => 'Nombre de la lista';

  @override
  String get iconOptional => 'Icono (opcional)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar';

  @override
  String get close => 'Cerrar';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtro';

  @override
  String get sort => 'Ordenar';

  @override
  String get addToFavorites => 'Añadir a favoritos';

  @override
  String get removeFromFavorites => 'Eliminar de favoritos';

  @override
  String get addToPlaylist => 'Añadir a lista de reproducción';

  @override
  String get removeFromPlaylist => 'Eliminar de lista de reproducción';

  @override
  String get addSongsToLibrary => 'Añadir canciones de la biblioteca';

  @override
  String get noSongsToAdd => 'No hay canciones para añadir';

  @override
  String addButtonText(Object count) {
    return 'Añadir $count';
  }

  @override
  String get selected => 'seleccionadas';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get autoScroll => 'Desplazamiento automático';

  @override
  String get autoScrollSubtitle => 'Desplazar automáticamente a la línea actual';

  @override
  String get highlightNextLine => 'Resaltar línea siguiente';

  @override
  String get highlightNextLineSubtitle => 'Mostrar línea siguiente con resaltado sutil';

  @override
  String get fontSize => 'Tamaño de fuente';

  @override
  String get scrollOffset => 'Desplazamiento de desplazamiento';

  @override
  String get scrollOffsetSubtitle => 'Distancia desde la parte superior de la pantalla en píxeles';

  @override
  String get autoScrollFocusOffset => 'Desplazamiento del enfoque del auto-scroll';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Posición de enfoque inicial para auto-scroll (predeterminado: +50)';

  @override
  String get defaultTranslationLanguage => 'Idioma de traducción predeterminado';

  @override
  String get defaultOriginalLanguage => 'Idioma original por defecto';

  @override
  String get russian => 'Ruso';

  @override
  String get english => 'Inglés';

  @override
  String get romanian => 'Rumano';

  @override
  String get french => 'Francés';

  @override
  String get german => 'Alemán';

  @override
  String get spanish => 'Español';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Portugués';

  @override
  String get lyricsFolder => 'Carpeta de letras';

  @override
  String get useLyricsFolder => 'Usar carpeta de letras';

  @override
  String get useLyricsFolderDisabled => 'Desactivado - los archivos deben seleccionarse con audio';

  @override
  String get setLyricsFolder => 'Establecer carpeta de letras';

  @override
  String get selectFolder => 'Seleccionar carpeta';

  @override
  String get folderPath => 'Ruta de carpeta';

  @override
  String get examples => 'Ejemplos:';

  @override
  String get defaultFolder => 'Predeterminado: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Carpeta actual:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Carpeta establecida: $path';
  }

  @override
  String get folderSetFailed => 'La carpeta no existe o no hay acceso';

  @override
  String get resetToDefault => 'Restablecer a predeterminado';

  @override
  String get showCurrentFolder => 'Mostrar carpeta actual';

  @override
  String get changeFolder => 'Cambiar carpeta';

  @override
  String get resetToDefaultFolder => 'Restablecer a carpeta predeterminada';

  @override
  String get folderReset => 'Carpeta restablecida a predeterminada';

  @override
  String get clearCache => 'Limpiar caché';

  @override
  String get clearCacheSubtitle => 'Eliminar archivos temporales';

  @override
  String get cacheCleared => 'Caché limpiada';

  @override
  String get resetSongLanguages => 'Restablecer idiomas de canciones';

  @override
  String get resetSongLanguagesSubtitle => 'Usar idioma predeterminado de configuración';

  @override
  String get songLanguagesReset => 'Idiomas de canciones restablecidos';

  @override
  String get about => 'Acerca de';

  @override
  String get translationsLoaded => '¡Traducciones cargadas con éxito!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Error al cargar traducciones: $error';
  }

  @override
  String get editTranslations => 'Editar traducciones';

  @override
  String get loadTranslationsFromFile => 'Cargar traducciones desde archivo';

  @override
  String get loadTextMenu => 'Cargar texto';

  @override
  String get loadTranslations => 'Cargar traducciones';

  @override
  String get deleteTranslation => 'Eliminar traducción';

  @override
  String get noFileSelected => 'Ningún archivo seleccionado';

  @override
  String get noLrcFileAssociated => 'Ningún archivo LRC asociado con esta canción';

  @override
  String get lrcFileSaved => '¡Archivo LRC guardado con éxito!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'Error al guardar archivo LRC: $error';
  }

  @override
  String get exitEditMode => 'Salir del modo edición';

  @override
  String get editTimestamps => 'Editar marcas de tiempo';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get language => 'Idioma';

  @override
  String get loading => 'Cargando...';

  @override
  String get noSongsFound => 'No se encontraron canciones';

  @override
  String get noPlaylistsFound => 'No se encontraron listas de reproducción';

  @override
  String get selectSong => 'Selecciona una canción para reproducir';

  @override
  String get song => 'Canción';

  @override
  String get artist => 'Artista';

  @override
  String get duration => 'Duración';

  @override
  String get actions => 'Acciones';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausa';

  @override
  String get stop => 'Detener';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get rewind10 => '-10s';

  @override
  String get forward10 => '+10s';

  @override
  String get repeat => 'Repetir';

  @override
  String get shuffle => 'Aleatorio';

  @override
  String get volume => 'Volumen';

  @override
  String get speed => 'Velocidad';

  @override
  String get lyrics => 'Letras';

  @override
  String get translations => 'Traducciones';

  @override
  String get originalText => 'Texto original';

  @override
  String get translatedText => 'Texto traducido';

  @override
  String get showTranscription => 'Mostrar transcripción';

  @override
  String get showTranscriptionSubtitle => 'Mostrar guía de pronunciación';

  @override
  String get showTranslationFirst => 'Traducción primero';

  @override
  String get showTranslationFirstSubtitle => 'Mostrar traducción antes del texto original';

  @override
  String get italianLang => 'Italiano';

  @override
  String get portugueseLang => 'Portugués';

  @override
  String get lyricsEditor => 'Editor de letras';

  @override
  String get addLine => 'Añadir línea';

  @override
  String get updateLine => 'Actualizar línea';

  @override
  String get deleteLine => 'Eliminar línea';

  @override
  String get clearAll => 'Limpiar todo';

  @override
  String get moveUp => 'Subir';

  @override
  String get moveDown => 'Bajar';

  @override
  String get autoSyncLyrics => 'Sincronización automática de letras';

  @override
  String get exportLrc => 'Exportar LRC (Original)';

  @override
  String get exportJson => 'Exportar JSON (Traducciones)';

  @override
  String get markTimestamp => 'Marcar tiempo (Enter)';

  @override
  String get original => 'Original';

  @override
  String get translation => 'Traducción';

  @override
  String get audioFile => 'Archivo de audio';

  @override
  String get songTitle => 'Título de canción';

  @override
  String get browse => 'Examinar';

  @override
  String get audioControls => 'Controles de audio';

  @override
  String get addEditLine => 'Añadir/Editar línea';

  @override
  String get instructions => 'Instrucciones';

  @override
  String get lyricsEditorInstructions => 'Instrucciones de sincronización LRC:\n\n1. Selecciona un archivo de audio usando el botón Examinar\n2. Introduce el título de la canción y el artista (opcional)\n3. Haz clic en Reproducir para iniciar el audio\n4. Cuando se canta una línea, escribe el texto original en el campo \'Original\'\n5. Presiona Enter o \'Marcar tiempo\' para grabar la marca de tiempo\n6. Opcionalmente añade una traducción en el campo \'Traducción\'\n7. Repite los pasos 4-6 para cada línea\n8. Usa \'Exportar LRC\' para guardar el texto original con marcas de tiempo\n9. Usa \'Exportar JSON\' para guardar las traducciones\n\nConsejos:\n- Usa -10s/+10s para navegar rápidamente por la canción\n- Puedes reordenar las líneas usando Subir/Bajar\n- Carga archivos JSON guardados anteriormente para editar traducciones';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get welcomeMessage => '¡Comienza tu viaje de aprendizaje de idiomas con música!';

  @override
  String get importSongs => 'Importar canciones';

  @override
  String get importSongsSubtitle => 'Añadir archivos de audio desde tu dispositivo';

  @override
  String get manageLibrary => 'Gestionar biblioteca';

  @override
  String get manageLibrarySubtitle => 'Organiza tus canciones y listas de reproducción';

  @override
  String get syncLyrics => 'Sincronizar letras';

  @override
  String get syncLyricsSubtitle => 'Sincronización automática de letras con audio';

  @override
  String get languageLearning => 'Aprendizaje de idiomas • Música • Traducciones';

  @override
  String get version => 'Versión';

  @override
  String get developer => 'Desarrollado por';

  @override
  String get website => 'Sitio web';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Error al crear lista de reproducción: $error';
  }

  @override
  String get playlistCreated => '¡Lista de reproducción creada con éxito!';

  @override
  String get playlistDeleted => '¡Lista de reproducción eliminada con éxito!';

  @override
  String get playlistUpdated => '¡Lista de reproducción actualizada con éxito!';

  @override
  String get songAdded => '¡Canción añadida con éxito!';

  @override
  String get songRemoved => '¡Canción eliminada con éxito!';

  @override
  String get songDeleted => '¡Canción eliminada con éxito!';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Advertencia';

  @override
  String get info => 'Información';

  @override
  String get success => 'Éxito';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSure => '¿Estás seguro?';

  @override
  String get unsavedChanges => 'Tienes cambios sin guardar. ¿Continuar?';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get appLanguage => 'Idioma de la aplicación';

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
  String get welcomeToLingoTune => 'Bienvenido a LingoTune';

  @override
  String get folderSetupMessage => 'Elige una carpeta para almacenar letras y traducciones (archivos LRC y JSON). Esto facilita organizar tu biblioteca musical.';

  @override
  String get selectFolderNow => 'Seleccionar carpeta ahora';

  @override
  String get goToSettings => 'Ir a ajustes';

  @override
  String get setupLater => 'Configurar más tarde';

  @override
  String get useDefaultFolder => 'Usar carpeta predeterminada';

  @override
  String get databaseFound => 'Base de datos encontrada en archivo de importación';

  @override
  String get importDatabaseQuestion => '¿Desea importar también la base de datos?';

  @override
  String get mergeDatabase => 'Combinar';

  @override
  String get replaceDatabase => 'Reemplazar';

  @override
  String get importDatabase => 'Importar base de datos';

  @override
  String get skipDatabase => 'Omitir base de datos';

  @override
  String get mergeDatabaseDescription => 'Combinar las canciones importadas con su biblioteca (agrega solo nuevos elementos)';

  @override
  String get replaceDatabaseDescription => 'Reemplazar toda su biblioteca con la base de datos importada (perderá todos los datos existentes)';

  @override
  String get exporting => 'Exportando...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Exportando $current de $total canciones';
  }

  @override
  String get exportDatabaseIncluded => 'Base de datos incluida en exportación';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'Importados $fileCount archivo(s) y base de datos';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'Importados $fileCount archivo(s)';
  }

  @override
  String get chinese => 'Chino';

  @override
  String get arabic => 'Árabe';

  @override
  String get colorTheme => 'Tema de color';

  @override
  String get themeColorPurple => 'Púrpura';

  @override
  String get themeColorBlue => 'Azul';

  @override
  String get themeColorGreen => 'Verde';

  @override
  String get themeColorOrange => 'Naranja';

  @override
  String get themeColorRed => 'Rojo';

  @override
  String get themeColorPink => 'Rosa';

  @override
  String get themeColorDeepOrange => 'Naranja oscuro';

  @override
  String get themeColorDarkRed => 'Rojo oscuro';

  @override
  String get themeColorTeal => 'Verde azulado';

  @override
  String get themeColorCyan => 'Cian';

  @override
  String get themeColorAmber => 'Ámbar';

  @override
  String get themeColorLime => 'Lima';

  @override
  String get ukrainianLang => 'Ucraniano';

  @override
  String get font => 'Fuente';

  @override
  String get fontSettings => 'Configuración de fuente';

  @override
  String get systemFont => 'Sistema';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Tamaño de texto principal';

  @override
  String get mainTextBold => 'Texto principal en negrita';

  @override
  String get translationSize => 'Tamaño de traducción';

  @override
  String get translationBold => 'Traducción en negrita';

  @override
  String get transcriptSize => 'Tamaño de transcripción';

  @override
  String get transcriptBold => 'Transcripción en negrita';

  @override
  String get defaultStartScreen => 'Pantalla de inicio predeterminada';

  @override
  String get defaultStartScreenSubtitle => 'Pantalla que se muestra al iniciar la aplicación';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Agregar a la biblioteca al agregar a una lista de reproducción';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Agregar automáticamente canciones a la biblioteca cuando se agreguen a una lista de reproducción';

  @override
  String get serviceMessages => 'Mensajes de servicio';

  @override
  String get serviceMessagesSubtitle => 'Mostrar notificaciones de servicio sobre traducción y transcripción';

  @override
  String get includeMp3Files => 'Incluir archivos MP3';

  @override
  String get includeMp3FilesSubtitle => 'Esto aumentará el tamaño del archivo';

  @override
  String get importMp3Files => 'Importar archivos MP3';

  @override
  String get importMp3FilesSubtitle => 'Añadir archivos de música a la biblioteca';

  @override
  String get exportSongs => 'Exportar canciones';

  @override
  String get import => 'Importar';

  @override
  String get addMultiple => 'Seleccionar múltiples';

  @override
  String get addToPlaylistShort => 'Añadir';

  @override
  String get deleteShort => 'Eliminar';

  @override
  String get selectAllShort => 'Todos';

  @override
  String get deselectAllShort => 'Limpiar';

  @override
  String get exitSelectionMode => 'Salir del modo de selección';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String get deleteSelected => 'Eliminar seleccionados';

  @override
  String get addMultipleToPlaylist => 'Añadir a lista de reproducción';

  @override
  String get coverArt => 'Carátula';

  @override
  String get playlistCover => 'Carátula de playlist';

  @override
  String get selectFromGallery => 'Seleccionar de la galería';

  @override
  String get removeCover => 'Eliminar carátula';

  @override
  String get coverUpdated => 'Carátula actualizada';

  @override
  String get coverRemoved => 'Carátula eliminada';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get importFolders => 'Importar carpetas';

  @override
  String get selectMusicFolder => 'Seleccionar carpeta de música';

  @override
  String get folderWithAudioFiles => 'Carpeta con archivos MP3/WAV';

  @override
  String get sameFolderForLyrics => 'Misma carpeta para letras';

  @override
  String get selectLyricsFolder => 'Seleccionar carpeta de letras';

  @override
  String get folderWithLyricsFiles => 'Carpeta con archivos LRC/JSON (opcional)';

  @override
  String get pleaseEnterPlaylistName => 'Por favor, ingrese el nombre de la lista';

  @override
  String get pleaseSelectMusicFolder => 'Por favor, seleccione una carpeta de música';

  @override
  String get cropImage => 'Recortar imagen';

  @override
  String get photoPermissionRequired => 'Permiso de acceso a fotos requerido';

  @override
  String get photoPermissionDenied => 'Acceso a fotos denegado';

  @override
  String get imageProcessingError => 'Error al procesar la imagen';

  @override
  String get scanningFolder => 'Escaneando carpeta...';

  @override
  String get importingFiles => 'Importando archivos...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Importando $current/$total archivos... $songs canciones encontradas';
  }

  @override
  String processingFile(Object file) {
    return 'Procesando $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Añadir a lista de reproducción';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Añadido a \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Error al añadir a lista: $error';
  }

  @override
  String get deleteSong => 'Eliminar';

  @override
  String get importSongDialogTitle => 'Importar canción';

  @override
  String get audioOnly => 'Solo audio';

  @override
  String get addLyricsLater => 'Añadiré letras más tarde';

  @override
  String get audioWithLyricsZIP => 'Audio + ZIP con letras';

  @override
  String get importWithAllTranslations => 'Importar con todas las traducciones';

  @override
  String get importTranslationDialogTitle => 'Añadir traducción';

  @override
  String get loadTranslationFromZip => 'Cargar desde archivo ZIP';

  @override
  String get loadTranslationFromJson => 'Cargar desde archivo JSON';

  @override
  String get noAudioFilesSelected => 'No se seleccionaron archivos de audio';

  @override
  String failedToImportSongs(Object error) {
    return 'Error al importar canciones: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Error al importar canción: $error';
  }

  @override
  String get musicFolderNotSelected => 'Carpeta de música no seleccionada';

  @override
  String get generateLyrics => 'Generar letra';

  @override
  String get selectTextFileOrEnterText => 'Seleccionar archivo de texto o introducir texto';

  @override
  String get originalLanguage => 'Idioma original';

  @override
  String get translationLanguages => 'Idiomas de traducción';

  @override
  String get startMinuteForTimestamps => 'Minuto inicial para marcas de tiempo';

  @override
  String get transcriptionLanguage => 'Idioma de transcripción';

  @override
  String get generating => 'Generando...';

  @override
  String get generate => 'Generar';

  @override
  String get deepseekApiKey => 'Clave API DeepSeek';

  @override
  String get validateKey => 'Validar clave';

  @override
  String get keyIsValid => 'La clave es válida';

  @override
  String get keyIsInvalid => 'La clave no es válida';

  @override
  String get lyricsGenerationSuccess => 'Letra generada con éxito';

  @override
  String get lyricsGenerationError => 'Error al generar la letra';

  @override
  String get savingFiles => 'Guardando archivos...';

  @override
  String get enterText => 'Introducir texto';

  @override
  String get transcript => 'Transcripción';

  @override
  String get originalTextEditable => 'Texto original (editable)';

  @override
  String get selectLanguageToEdit => 'Seleccionar idioma para editar';

  @override
  String get moveLineUp => 'Mover línea hacia arriba';

  @override
  String get moveLineDown => 'Mover línea hacia abajo';

  @override
  String get moveAllTranslationsUp => 'Mover todas las traducciones hacia arriba';

  @override
  String get moveAllTranslationsDown => 'Mover todas las traducciones hacia abajo';

  @override
  String get translationSaved => '¡Traducción guardada!';

  @override
  String get translationSaveFailed => 'Error al guardar la traducción';

  @override
  String get loadTextTitle => 'Cargar texto';

  @override
  String get noOriginalTextWarning => 'Primero carga el texto original';

  @override
  String get selectLanguageOriginal => 'Idioma original';

  @override
  String get startTimestampMinutes => 'Inicio de marca de tiempo (minutos)';

  @override
  String get selectLanguageTranslation => 'Idioma de traducción';

  @override
  String get originalTextLoaded => 'Texto original cargado con éxito!';

  @override
  String get translationLoaded => 'Traducción cargada con éxito!';

  @override
  String get transcriptLoaded => 'Transcripción cargada con éxito!';

  @override
  String get selectTranslationLanguage => 'Idioma de traducción para transcripción';

  @override
  String get noTranslationWarning => 'No hay traducciones cargadas';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Discrepancia de líneas: $loaded líneas, esperado $expected';
  }

  @override
  String get loadTextTooltip => 'Cargar texto o traducción';

  @override
  String get loadFromFile => 'Cargar desde archivo';

  @override
  String get pasteFromClipboard => 'Pegar desde el portapapeles';

  @override
  String get audioNotificationService => 'Servicio de notificación de audio';

  @override
  String get audioNotificationServiceActive => 'Estado: ✅ Activo';

  @override
  String get audioNotificationServiceError => 'Estado: ❌ Error';

  @override
  String get errorLabel => 'Error:';

  @override
  String get audioNotificationServiceDescription => 'Este servicio proporciona notificaciones cuando la aplicación está minimizada';

  @override
  String get reorder => 'Reordenar';

  @override
  String get done => 'Listo';

  @override
  String get selectMultiple => 'Seleccionar varios';

  @override
  String get sortSongs => 'Ordenar canciones';

  @override
  String get importSong => 'Importar canción';

  @override
  String get sortDefault => 'Por defecto';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Más recientes';

  @override
  String get sortDateAsc => 'Más antiguas';

  @override
  String get importingSongs => 'Importando canciones...';

  @override
  String get noSongsInPlaylist => 'Ninguna canción en esta lista';

  @override
  String get addSongsFromLibraryHint => 'Añadir canciones de tu biblioteca';

  @override
  String get removedSongsFromPlaylist => 'Canciones eliminadas de la lista';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Error al eliminar canciones: $error';
  }

  @override
  String get deletePlaylistTitle => 'Eliminar lista de reproducción';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return '¿Estás seguro de eliminar \"$playlist\"?';
  }

  @override
  String get failedToDeletePlaylist => 'Error al eliminar lista:';

  @override
  String get specifyTranslationLanguage => 'Especificar idioma de traducción';

  @override
  String get languageNameLabel => 'Nombre del idioma';

  @override
  String get languageNameHint => 'Por ejemplo: Ruso, Del autor, Poético';

  @override
  String get translationTypeLabel => 'Tipo de traducción:';

  @override
  String get translationTypeNormal => 'Normal';

  @override
  String get translationTypeAuthor => 'Del autor';

  @override
  String get translationTypePoetic => 'Poético';

  @override
  String get translationTypeLiteral => 'Literal';

  @override
  String mp3FilesCount(Object count) {
    return 'Archivos MP3: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return '$count archivo(s) importado(s) (base de datos omitida)';
  }

  @override
  String get databaseMerged => 'Base de datos fusionada';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'Base de datos fusionada, archivos MP3: $count';
  }

  @override
  String get databaseReplaced => 'Base de datos reemplazada';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'Base de datos reemplazada, archivos MP3: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Confirmar reemplazo';

  @override
  String get confirmReplaceDatabaseWarning => '¿Estás seguro? Perderás todas las canciones y listas existentes!';

  @override
  String get replaceAll => 'Reemplazar todo';

  @override
  String get selectLanguages => 'Seleccionar idiomas';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Seleccionados: $count idiomas';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Seleccionados: $count';
  }

  @override
  String get promptPreset => 'Preajuste de prompt';

  @override
  String get balanced => 'Equilibrado';

  @override
  String get poetic => 'Poético';

  @override
  String get literal => 'Literal';

  @override
  String get customPromptOption => 'Personalizado...';

  @override
  String get editPrompt => 'Editar prompt';

  @override
  String get notSet => 'No configurado';

  @override
  String get showOrEditApiKey => 'Mostrar/Editar clave API';

  @override
  String get timeout => 'Tiempo de espera';

  @override
  String get model => 'Modelo';

  @override
  String get resetToPreset => 'Restablecer a preajuste';

  @override
  String get customPrompt => 'Prompt personalizado';

  @override
  String customPromptChars(Object count) {
    return 'Prompt personalizado ($count caracteres)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Usando preajuste: $preset';
  }

  @override
  String get characters => 'caracteres';

  @override
  String get deepSeekPromptTitle => 'Prompt de DeepSeek';

  @override
  String get customPromptLabel => 'Prompt personalizado';

  @override
  String get leaveEmptyToUseDefault => 'Dejar vacío para usar el prompt predeterminado';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Dejar vacío para usar el prompt predeterminado integrado en la aplicación';

  @override
  String get apiKeySaved => 'Clave API guardada';

  @override
  String get enterTimeout => 'Ingrese el tiempo de espera en segundos';

  @override
  String get validTimeoutRange => 'Por favor ingrese un tiempo de espera válido (1-3600 segundos)';

  @override
  String get customTimeout => 'Tiempo de espera personalizado';

  @override
  String get timeoutSeconds => 'Tiempo de espera (segundos)';

  @override
  String timeoutSetTo(Object value) {
    return 'Tiempo de espera establecido en $value segundos';
  }

  @override
  String get customModel => 'Modelo personalizado';

  @override
  String get modelName => 'Nombre del modelo';

  @override
  String get enterModelName => 'Ingrese el nombre exacto del modelo proporcionado por DeepSeek API';

  @override
  String get pleaseEnterModelName => 'Por favor ingrese un nombre de modelo';

  @override
  String modelSetTo(Object value) {
    return 'Modelo establecido en $value';
  }

  @override
  String get editCustomPrompt => 'Editar prompt personalizado';

  @override
  String get editPresetPrompt => 'Editar prompt preestablecido';

  @override
  String get editingPreset => 'Editando preajuste';

  @override
  String get anyChangesSaveAsCustom => 'Cualquier cambio se guardará como prompt personalizado. Use el botón \'Restablecer\' para restaurar el preajuste original.';

  @override
  String get useResetToRestorePreset => 'Use el botón \'Restablecer\' para restaurar el preajuste original';

  @override
  String get prompt => 'Prompt';

  @override
  String get promptSaved => 'Prompt guardado';

  @override
  String get usingPresetPrompt => 'Usando prompt preestablecido';

  @override
  String get apiKeyHint => 'Clave API';

  @override
  String get modelHint => 'ej. deepseek-v3';

  @override
  String get enterExactModelName => 'Ingrese el nombre exacto del modelo proporcionado por DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'Por favor ingrese la clave API primero';

  @override
  String get maxTokensRegular => 'Max Tokens (Normal)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Límite de tokens para solicitudes de traducción normales';

  @override
  String get maxTokensJsonHint => 'Límite de tokens para solicitudes de generación completa (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (normal) establecido en $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) establecido en $value';
  }

  @override
  String get refreshFolder => 'Actualizar carpeta';

  @override
  String get refreshingFolder => 'Actualizando carpeta...';

  @override
  String get playlistCreatedWithLink => '¡Lista de reproducción creada! Presiona \"Actualizar\" para cargar canciones de la carpeta';

  @override
  String refreshedPlaylist(Object count) {
    return 'Actualizado: $count canciones';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Error al actualizar: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Error al cargar canciones: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'La carpeta de música no existe';

  @override
  String successfullyImportedSongs(Object count) {
    return 'Importadas con éxito $count canciones';
  }

  @override
  String get noAudioFileSelected => 'Ningún archivo de audio seleccionado';

  @override
  String get noZipArchiveSelected => 'Ningún archivo ZIP seleccionado';

  @override
  String get noFolderConfigured => 'Carpeta no configurada';

  @override
  String get missingLyricsTranslations => 'Faltan letras/traducciones';

  @override
  String missingForSong(Object songName) {
    return 'Para \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Faltan: $files';
  }

  @override
  String get whatWouldYouLikeToDo => '¿Qué le gustaría hacer?';

  @override
  String get lyricsGeneratedSuccessfully => 'Letras generadas con éxito';

  @override
  String get setDeepSeekApiKey => 'Por favor configure la clave API DeepSeek en ajustes';

  @override
  String failedToOpenSong(Object error) {
    return 'Error al abrir canción: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'También eliminar archivos LRC y JSON';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Añadido a \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Error al añadir a lista: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return 'Exportadas $count canciones';
  }

  @override
  String get fileNotFound => 'Archivo no encontrado';

  @override
  String get selectZipFileNotJson => 'Por favor seleccione un archivo ZIP, no JSON o LRC';

  @override
  String get noFilesFoundInZip => 'No se encontraron archivos en el ZIP';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Formato de archivo ZIP no válido: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Error al importar: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return 'Encontradas $count traducciones';
  }

  @override
  String mp3ImportError(Object error) {
    return 'Error al importar MP3: $error';
  }

  @override
  String get importSongFirstToSearch => 'Importe una canción primero para buscar letras';

  @override
  String get lyricsFetched => 'Letras recuperadas';

  @override
  String get lyricsFoundUseCreate => 'Letras encontradas. Use para crear un archivo LRC sincronizado';

  @override
  String get deleteSelectedSongs => 'Eliminar canciones seleccionadas';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return '¿Está seguro de eliminar $count canciones?';
  }

  @override
  String get songsDeletedSuccessfully => 'Canciones eliminadas con éxito';

  @override
  String get storagePermissionRequired => 'Se requiere permiso de almacenamiento para acceder a carpetas.';

  @override
  String get enableStoragePermission => 'Por favor habilite el permiso de almacenamiento en ajustes.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get unableToSelectFolder => 'No se pudo seleccionar carpeta. Intente alternativa:';

  @override
  String get selectFilesInstead => 'Seleccionar archivos en su lugar';

  @override
  String get enterFolderPath => 'Por favor ingrese una ruta de carpeta';

  @override
  String get folderDoesNotExist => '✗ La carpeta no existe';

  @override
  String folderSetWithPath(Object path) {
    return 'Carpeta establecida: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Error al establecer carpeta: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'No se pudo seleccionar carpeta de letras. Intente alternativa:';

  @override
  String get useManualPath => 'Usar ruta manual (para pruebas)';

  @override
  String get enterFolderPathManually => 'Ingrese ruta de carpeta manualmente en lugar de usar selector de carpeta';

  @override
  String get folderPathLabel => 'Ruta de carpeta';

  @override
  String get folderPathHint => 'Ejemplo: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Ruta completa a su carpeta de música';

  @override
  String get setPath => 'Establecer ruta';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'Seleccionar archivo ZIP con letras para \"$title\"';
  }

  @override
  String get skip => 'Omitir';

  @override
  String get retry => 'Reintentar';

  @override
  String get failedToCopyLrcFile => 'Error al copiar archivo LRC';

  @override
  String copiedJsonFiles(Object count) {
    return 'Copiados $count archivos JSON';
  }

  @override
  String get failedToCopyJsonFiles => 'Error al copiar archivos JSON';

  @override
  String failedToDeleteSong(Object error) {
    return 'Error al eliminar canción: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return 'Añadidas $count canciones a \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'Añadir $count canciones a la lista';
  }

  @override
  String get failedToExportSongs => 'Error al exportar canciones';

  @override
  String get ok => 'Aceptar';

  @override
  String deleteSongConfirm(Object song) {
    return '¿Estás seguro de que quieres eliminar \"$song\"?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Seleccionar carpeta de música para esta lista';

  @override
  String get folderLinkedToPlaylist => 'Carpeta vinculada a la lista';

  @override
  String get folderUnlinkedFromPlaylist => 'Carpeta desvinculada de la lista';

  @override
  String get checkFolderAccess => 'Verificar acceso';

  @override
  String get checkingPermissions => 'Verificando permisos...';

  @override
  String get folderAccessible => '✓ Carpeta accesible';

  @override
  String get folderNotAccessible => '✗ Carpeta inaccesible';

  @override
  String audioFilesFound(Object count) {
    return '$count archivo(s) de audio encontrado(s)';
  }

  @override
  String lyricsFound(Object count) {
    return '$count archivo(s) de letras encontrado(s)';
  }

  @override
  String get noAudioFiles => 'No se encontraron archivos de audio';

  @override
  String get noLyricsFiles => 'No se encontraron archivos de letras';

  @override
  String errorCheckingAccess(Object error) {
    return 'Error al verificar acceso: $error';
  }

  @override
  String get folderPathColon => 'Ruta de carpeta:';

  @override
  String get permissionsStatus => 'Estado de permisos:';

  @override
  String get folderContent => 'Contenido de carpeta:';

  @override
  String get accessGranted => '✓ Acceso concedido';

  @override
  String get accessDenied => '✗ Acceso denegado';

  @override
  String get permissionRequestFailed => 'Error al solicitar permisos';

  @override
  String get pleaseGrantPermissions => 'Por favor, conceda permisos de almacenamiento para verificar la carpeta';

  @override
  String get refreshOnlySongs => 'Solo canciones';

  @override
  String get refreshEverything => 'Todo';

  @override
  String get refreshDialogDescription => '¿Qué te gustaría actualizar? \"Solo canciones\" acelera el proceso omitiendo letras.';

  @override
  String get mostSongs => 'Más canciones';

  @override
  String get playlistPlay => 'Lista de reproducción';

  @override
  String get musicNote => 'Nota musical';

  @override
  String get favorite => 'Favorito';

  @override
  String get libraryMusic => 'Biblioteca';

  @override
  String get tapToSelectFolder => 'Toca para seleccionar una carpeta con archivos de audio';

  @override
  String get showVerticalSlider => 'Slider vertical';

  @override
  String get showVerticalSliderSubtitle => 'Mostrar slider vertical de desplazamiento en el reproductor';

  @override
  String get transcriptionEnabled => 'Transcripción activada';

  @override
  String get transcriptionDisabled => 'Transcripción desactivada';

  @override
  String languageSelected(String language) {
    return 'Idioma seleccionado: $language';
  }

  @override
  String get noTranslationsScanning => 'Sin traducciones, escaneando carpeta...';

  @override
  String translationsLoadedCount(int count) {
    return 'Traducciones cargadas: $count';
  }

  @override
  String get translationsNotFound => 'No se encontraron traducciones para esta canción';

  @override
  String errorLoadingTranslations(String error) {
    return 'Error cargando traducciones: $error';
  }

  @override
  String languageNotAvailable(String settingLang, String availableLang) {
    return '$settingLang seleccionado pero no disponible. Abriendo: $availableLang';
  }

  @override
  String get errorAudioService => 'Error del Servicio de Audio';

  @override
  String get audioServiceFailed => 'No se pudo inicializar la reproducción de audio en segundo plano.';

  @override
  String get notificationMayNotAppear => 'La notificación del reproductor puede no aparecer.';

  @override
  String get lrcAndTranslationsSaved => 'LRC y todas las traducciones guardadas!';

  @override
  String translationDeleted(String name) {
    return 'Traducción \"$name\" eliminada';
  }

  @override
  String failedToDeleteTranslation(String error) {
    return 'Error al eliminar traducción: $error';
  }

  @override
  String get generatingTranslations => 'Generando traducciones';

  @override
  String get generatingProcessing => 'Procesando:';

  @override
  String get generatingLines => 'Líneas:';

  @override
  String generatingLinesOf(int current, int total) {
    return '$current de $total';
  }

  @override
  String generatingErrors(int count) {
    return 'Errores: $count';
  }

  @override
  String selectedLanguagesCountGen(int count) {
    return 'Seleccionados: $count';
  }

  @override
  String get transcriptionSection => 'Transcripción';

  @override
  String get translationsSection => 'Traducciones';

  @override
  String get translationLoadedSuccess => 'Traducción cargada exitosamente!';

  @override
  String get exportSuccessful => 'Exportación exitosa!';

  @override
  String get failedToExportSong => 'Error al exportar canción';

  @override
  String get deleteTranslationTitle => 'Eliminar traducción';

  @override
  String deleteTranslationConfirm(String name) {
    return '¿Eliminar traducción \"$name\"?';
  }

  @override
  String get lrcLoaded => 'Archivo LRC cargado';

  @override
  String get noFilesLoaded => 'No se encontraron archivos en el archivo';

  @override
  String failedToProcessArchive(String error) {
    return 'Error procesando archivo: $error';
  }

  @override
  String failedToLoadTranslationsShort(String error) {
    return 'Error al cargar: $error';
  }

  @override
  String get noFolderConfiguredMsg => 'Ninguna carpeta configurada';

  @override
  String failedToPlaySongMsg(String error) {
    return 'Error de reproducción: $error';
  }

  @override
  String addedSongsToPlaylistMsg(int count, String playlist) {
    return '$count canción(es) añadida(s) a \"$playlist\"';
  }

  @override
  String failedToAddSongsMsg(String error) {
    return 'Error al añadir: $error';
  }

  @override
  String addSongsButton(int count) {
    return 'Añadir $count';
  }

  @override
  String get removeSong => 'Eliminar';

  @override
  String failedToRemoveSongMsg(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String failedToReorderSongsMsg(String error) {
    return 'Error al reordenar: $error';
  }

  @override
  String failedToLoadSongsMsg(String error) {
    return 'Error al cargar: $error';
  }

  @override
  String errorLoadingText(String error) {
    return 'Error cargando texto: $error';
  }

  @override
  String lrcAndTranslationsLoaded(int count) {
    return 'LRC y $count traducción(es) cargadas';
  }

  @override
  String translationsOnlyLoaded(int count) {
    return '$count traducción(es) cargadas';
  }

  @override
  String get pleaseSetDeepSeekApiKey => 'Configure la clave API de DeepSeek en ajustes';

  @override
  String get lyricsGeneratedSuccessfullyMsg => 'Letras generadas exitosamente';

  @override
  String exportShareSubject(String title) {
    return 'LingoTune exportación: $title con letras y traducciones';
  }
}
