// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Библиотека';

  @override
  String get playlists => 'Плейлисты';

  @override
  String get settings => 'Настройки';

  @override
  String get allSongs => 'Все песни';

  @override
  String get favorites => 'Избранное';

  @override
  String get createPlaylist => 'Создать плейлист';

  @override
  String get playlistName => 'Название плейлиста';

  @override
  String get iconOptional => 'Иконка (опционально)';

  @override
  String get cancel => 'Отмена';

  @override
  String get create => 'Создать';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get save => 'Сохранить';

  @override
  String get close => 'Закрыть';

  @override
  String get search => 'Поиск';

  @override
  String get filter => 'Фильтр';

  @override
  String get sort => 'Сортировка';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get removeFromFavorites => 'Убрать из избранного';

  @override
  String get addToPlaylist => 'Добавить в плейлист';

  @override
  String get removeFromPlaylist => 'Удалить из плейлиста';

  @override
  String get addSongsToLibrary => 'Добавить песни из библиотеки';

  @override
  String get noSongsToAdd => 'Нет песен для добавления';

  @override
  String addButtonText(Object count) {
    return 'Добавить $count';
  }

  @override
  String get selected => 'выбрано';

  @override
  String get darkMode => 'Темная тема';

  @override
  String get lightMode => 'Светлая тема';

  @override
  String get autoScroll => 'Автопрокрутка';

  @override
  String get autoScrollSubtitle => 'Автоматически прокручивать к текущей строке';

  @override
  String get highlightNextLine => 'Подсветка следующей строки';

  @override
  String get highlightNextLineSubtitle => 'Показать следующую строку с легкой подсветкой';

  @override
  String get fontSize => 'Размер шрифта';

  @override
  String get scrollOffset => 'Смещение скролла';

  @override
  String get scrollOffsetSubtitle => 'Расстояние от верха экрана в пикселях';

  @override
  String get autoScrollFocusOffset => 'Фокус автопрокрутки';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Начальное положение фокуса для автопрокрутки (по умолчанию: +50)';

  @override
  String get defaultTranslationLanguage => 'Язык перевода по умолчанию';

  @override
  String get defaultOriginalLanguage => 'Язык оригинала по умолчанию';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'Английский';

  @override
  String get romanian => 'Румынский';

  @override
  String get french => 'Французский';

  @override
  String get german => 'Немецкий';

  @override
  String get spanish => 'Испанский';

  @override
  String get italian => 'Итальянский';

  @override
  String get portuguese => 'Португальский';

  @override
  String get lyricsFolder => 'Папка с текстами песен';

  @override
  String get useLyricsFolder => 'Использовать папку текстов';

  @override
  String get useLyricsFolderDisabled => 'Отключено - файлы должны выбираться вместе с аудио';

  @override
  String get setLyricsFolder => 'Установить папку текстов';

  @override
  String get selectFolder => 'Выбрать папку';

  @override
  String get folderPath => 'Путь к папке';

  @override
  String get examples => 'Примеры:';

  @override
  String get defaultFolder => 'По умолчанию: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Текущая папка:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Папка установлена: $path';
  }

  @override
  String get folderSetFailed => 'Папка не существует или нет доступа';

  @override
  String get resetToDefault => 'Сбросить по умолчанию';

  @override
  String get showCurrentFolder => 'Показать текущую папку';

  @override
  String get changeFolder => 'Изменить папку';

  @override
  String get resetToDefaultFolder => 'Сбросить папку по умолчанию';

  @override
  String get folderReset => 'Сбросить папку по умолчанию';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get clearCacheSubtitle => 'Удалить временные файлы';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get resetSongLanguages => 'Сбросить языки песен';

  @override
  String get resetSongLanguagesSubtitle => 'Использовать язык по умолчанию из настроек';

  @override
  String get songLanguagesReset => 'Языки песен сброшены';

  @override
  String get about => 'О приложении';

  @override
  String get translationsLoaded => 'Переводы успешно загружены!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Не удалось загрузить переводы: $error';
  }

  @override
  String get editTranslations => 'Редактировать переводы';

  @override
  String get loadTranslationsFromFile => 'Загрузить переводы из файла';

  @override
  String get loadTextMenu => 'Загрузить текст';

  @override
  String get loadTranslations => 'Загрузить переводы';

  @override
  String get deleteTranslation => 'Удалить перевод';

  @override
  String get noFileSelected => 'Файл не выбран';

  @override
  String get noLrcFileAssociated => 'Нет связанного файла LRC с этой песней';

  @override
  String get lrcFileSaved => 'Файл LRC успешно сохранен!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'Не удалось сохранить файл LRC: $error';
  }

  @override
  String get exitEditMode => 'Выйти из режима редактирования';

  @override
  String get editTimestamps => 'Редактировать временные метки';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get language => 'Язык';

  @override
  String get loading => 'Загрузка...';

  @override
  String get noSongsFound => 'Песни не найдены';

  @override
  String get noPlaylistsFound => 'Плейлисты не найдены';

  @override
  String get selectSong => 'Выбрать песню для воспроизведения';

  @override
  String get song => 'Песня';

  @override
  String get artist => 'Исполнитель';

  @override
  String get duration => 'Длительность';

  @override
  String get actions => 'Действия';

  @override
  String get play => 'Воспроизведение';

  @override
  String get pause => 'Пауза';

  @override
  String get stop => 'Стоп';

  @override
  String get previous => 'Предыдущий';

  @override
  String get next => 'Следующий';

  @override
  String get rewind10 => '-10с';

  @override
  String get forward10 => '+10с';

  @override
  String get repeat => 'Повтор';

  @override
  String get shuffle => 'Перемешать';

  @override
  String get volume => 'Громкость';

  @override
  String get speed => 'Скорость';

  @override
  String get lyrics => 'Текст';

  @override
  String get translations => 'Переводы';

  @override
  String get originalText => 'Оригинальный текст';

  @override
  String get translatedText => 'Переведенный текст';

  @override
  String get showTranscription => 'Показать транскрипцию';

  @override
  String get showTranscriptionSubtitle => 'Показывать руководство по произношению';

  @override
  String get showTranslationFirst => 'Сначала перевод';

  @override
  String get showTranslationFirstSubtitle => 'Показывать перевод перед оригинальным текстом';

  @override
  String get italianLang => 'Итальянский';

  @override
  String get portugueseLang => 'Португальский';

  @override
  String get lyricsEditor => 'Редактор текста';

  @override
  String get addLine => 'Добавить строку';

  @override
  String get updateLine => 'Обновить строку';

  @override
  String get deleteLine => 'Удалить строку';

  @override
  String get clearAll => 'Очистить все';

  @override
  String get moveUp => 'Вверх';

  @override
  String get moveDown => 'Вниз';

  @override
  String get autoSyncLyrics => 'Автосинхронизация текстов';

  @override
  String get exportLrc => 'Экспорт LRC (Оригинал)';

  @override
  String get exportJson => 'Экспорт JSON (Переводы)';

  @override
  String get markTimestamp => 'Пометить время (Enter)';

  @override
  String get original => 'Оригинал';

  @override
  String get translation => 'Перевод';

  @override
  String get audioFile => 'Аудиофайл';

  @override
  String get songTitle => 'Название песни';

  @override
  String get browse => 'Обзор';

  @override
  String get audioControls => 'Управление аудио';

  @override
  String get addEditLine => 'Добавить/Редактировать строку';

  @override
  String get instructions => 'Инструкции';

  @override
  String get lyricsEditorInstructions => 'Инструкции по синхронизации LRC:\n\n1. Выберите аудиофайл, нажав кнопку Обзор\n2. Введите название песни и исполнителя (опционально)\n3. Нажмите Воспроизвести для запуска аудио\n4. Когда поется строка, введите оригинальный текст в поле \'Оригинал\'\n5. Нажмите Enter или \'Пометить время\' для записи временной метки\n6. Опционально добавьте перевод в поле \'Перевод\'\n7. Повторите шаги 4-6 для каждой строки\n8. Используйте \'Экспорт LRC\' для сохранения оригинального текста с временными метками\n9. Используйте \'Экспорт JSON\' для сохранения переводов\n\nСоветы:\n- Используйте -10с/+10с для быстрой навигации по песне\n- Вы можете переупорядочивать строки, используя Вверх/Вниз\n- Загружайте ранее сохраненные JSON файлы для редактирования переводов';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get welcomeMessage => 'Начните свой путь изучения языков с музыкой!';

  @override
  String get importSongs => 'Импортировать песни';

  @override
  String get importSongsSubtitle => 'Добавить аудиофайлы с вашего устройства';

  @override
  String get manageLibrary => 'Управление библиотекой';

  @override
  String get manageLibrarySubtitle => 'Организуйте ваши песни и плейлисты';

  @override
  String get syncLyrics => 'Синхронизировать текст';

  @override
  String get syncLyricsSubtitle => 'Автоматическая синхронизация текста с аудио';

  @override
  String get languageLearning => 'Изучение языков • Музыка • Переводы';

  @override
  String get version => 'Версия';

  @override
  String get developer => 'Разработано';

  @override
  String get website => 'Веб-сайт';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Не удалось создать плейлист: $error';
  }

  @override
  String get playlistCreated => 'Плейлист успешно создан!';

  @override
  String get playlistDeleted => 'Плейлист успешно удален!';

  @override
  String get playlistUpdated => 'Плейлист успешно обновлен!';

  @override
  String get songAdded => 'Песня успешно добавлена!';

  @override
  String get songRemoved => 'Песня успешно удалена!';

  @override
  String get songDeleted => 'Песня успешно удалена!';

  @override
  String get error => 'Ошибка';

  @override
  String get warning => 'Предупреждение';

  @override
  String get info => 'Информация';

  @override
  String get success => 'Успешно';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get areYouSure => 'Вы уверены?';

  @override
  String get unsavedChanges => 'У вас есть несохраненные изменения. Продолжить?';

  @override
  String get selectLanguage => 'Выбрать язык';

  @override
  String get appLanguage => 'Язык приложения';

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
  String get welcomeToLingoTune => 'Добро пожаловать в LingoTune';

  @override
  String get folderSetupMessage => 'Выберите папку для хранения текстов и переводов (LRC и JSON файлы). Это упростит организацию вашей музыкальной библиотеки.';

  @override
  String get selectFolderNow => 'Выбрать папку сейчас';

  @override
  String get goToSettings => 'Перейти в настройки';

  @override
  String get setupLater => 'Настроить позже';

  @override
  String get useDefaultFolder => 'Использовать папку по умолчанию';

  @override
  String get databaseFound => 'База данных найдена в файле импорта';

  @override
  String get importDatabaseQuestion => 'Хотите также импортировать базу данных?';

  @override
  String get mergeDatabase => 'Объединить';

  @override
  String get replaceDatabase => 'Заменить';

  @override
  String get importDatabase => 'Импорт базы данных';

  @override
  String get skipDatabase => 'Пропустить базу данных';

  @override
  String get mergeDatabaseDescription => 'Объединить импортированные песни с вашей библиотекой (добавляет только новые элементы)';

  @override
  String get replaceDatabaseDescription => 'Заменить всю вашу библиотеку импортированной базой данных (вы потеряете все существующие данные)';

  @override
  String get exporting => 'Экспорт...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Экспорт $current из $total песен';
  }

  @override
  String get exportDatabaseIncluded => 'База данных включена в экспорт';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'Импортировано $fileCount файл(ов) и база данных';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'Импортировано $fileCount файл(ов)';
  }

  @override
  String get chinese => 'Китайский';

  @override
  String get arabic => 'Арабский';

  @override
  String get colorTheme => 'Цветовая тема';

  @override
  String get themeColorPurple => 'Фиолетовый';

  @override
  String get themeColorBlue => 'Синий';

  @override
  String get themeColorGreen => 'Зеленый';

  @override
  String get themeColorOrange => 'Оранжевый';

  @override
  String get themeColorRed => 'Красный';

  @override
  String get themeColorPink => 'Розовый';

  @override
  String get themeColorDeepOrange => 'Темно-оранжевый';

  @override
  String get themeColorDarkRed => 'Темно-красный';

  @override
  String get themeColorTeal => 'Бирюзовый';

  @override
  String get themeColorCyan => 'Голубой';

  @override
  String get themeColorAmber => 'Янтарный';

  @override
  String get themeColorLime => 'Лаймовый';

  @override
  String get ukrainianLang => 'Украинский';

  @override
  String get font => 'Шрифт';

  @override
  String get fontSettings => 'Настройки шрифта';

  @override
  String get systemFont => 'Системный';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Размер основного текста';

  @override
  String get mainTextBold => 'Жирный основной текст';

  @override
  String get translationSize => 'Размер перевода';

  @override
  String get translationBold => 'Жирный перевод';

  @override
  String get transcriptSize => 'Размер транскрипции';

  @override
  String get transcriptBold => 'Жирная транскрипция';

  @override
  String get defaultStartScreen => 'Начальный экран по умолчанию';

  @override
  String get defaultStartScreenSubtitle => 'Экран, который будет показан при запуске приложения';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Добавлять в библиотеку при добавлении в плейлист';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Автоматически добавлять песни в библиотеку при добавлении в плейлист';

  @override
  String get serviceMessages => 'Служебные сообщения';

  @override
  String get serviceMessagesSubtitle => 'Показывать служебные уведомления о переводе и транскрипции';

  @override
  String get includeMp3Files => 'Включить MP3 файлы';

  @override
  String get includeMp3FilesSubtitle => 'Это увеличит размер архива';

  @override
  String get importMp3Files => 'Импорт MP3 файлов';

  @override
  String get importMp3FilesSubtitle => 'Добавить музыкальные файлы в библиотеку';

  @override
  String get exportSongs => 'Экспорт песен';

  @override
  String get import => 'Импорт';

  @override
  String get addMultiple => 'Выбрать несколько';

  @override
  String get addToPlaylistShort => 'Добавить';

  @override
  String get deleteShort => 'Удалить';

  @override
  String get selectAllShort => 'Все';

  @override
  String get deselectAllShort => 'Очистить';

  @override
  String get exitSelectionMode => 'Выйти из режима выбора';

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get deselectAll => 'Снять выделение';

  @override
  String get deleteSelected => 'Удалить выбранные';

  @override
  String get addMultipleToPlaylist => 'Добавить к плейлисту';

  @override
  String get coverArt => 'Обложка';

  @override
  String get playlistCover => 'Обложка плейлиста';

  @override
  String get selectFromGallery => 'Выбрать из галереи';

  @override
  String get removeCover => 'Удалить обложку';

  @override
  String get coverUpdated => 'Обложка обновлена';

  @override
  String get coverRemoved => 'Обложка удалена';

  @override
  String errorWithMessage(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get importFolders => 'Импорт папок';

  @override
  String get selectMusicFolder => 'Выбрать папку с музыкой';

  @override
  String get folderWithAudioFiles => 'Папка с файлами MP3/WAV';

  @override
  String get sameFolderForLyrics => 'Та же папка для текстов';

  @override
  String get selectLyricsFolder => 'Выбрать папку с текстами';

  @override
  String get folderWithLyricsFiles => 'Папка с файлами LRC/JSON (опционально)';

  @override
  String get pleaseEnterPlaylistName => 'Пожалуйста, введите название плейлиста';

  @override
  String get pleaseSelectMusicFolder => 'Пожалуйста, выберите папку с музыкой';

  @override
  String get cropImage => 'Обрезать изображение';

  @override
  String get photoPermissionRequired => 'Требуется разрешение на доступ к фото';

  @override
  String get photoPermissionDenied => 'Доступ к фото отклонен';

  @override
  String get imageProcessingError => 'Ошибка обработки изображения';

  @override
  String get scanningFolder => 'Сканирование папки...';

  @override
  String get importingFiles => 'Импортирование файлов...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Импортирование $current/$total файлов... Найдено $songs песен';
  }

  @override
  String processingFile(Object file) {
    return 'Обработка $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Добавить к плейлисту';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Добавлено к \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Не удалось добавить к плейлисту: $error';
  }

  @override
  String get deleteSong => 'Удалить';

  @override
  String get importSongDialogTitle => 'Импортировать песню';

  @override
  String get audioOnly => 'Только аудио';

  @override
  String get addLyricsLater => 'Добавлю тексты позже';

  @override
  String get audioWithLyricsZIP => 'Аудио + ZIP с текстами';

  @override
  String get importWithAllTranslations => 'Импортировать со всеми переводами';

  @override
  String get importTranslationDialogTitle => 'Добавить перевод';

  @override
  String get loadTranslationFromZip => 'Загрузить из ZIP архива';

  @override
  String get loadTranslationFromJson => 'Загрузить из JSON файла';

  @override
  String get noAudioFilesSelected => 'Аудиофайлы не выбраны';

  @override
  String failedToImportSongs(Object error) {
    return 'Не удалось импортировать песни: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Не удалось импортировать песню: $error';
  }

  @override
  String get musicFolderNotSelected => 'Папка с музыкой не выбрана';

  @override
  String get generateLyrics => 'Сгенерировать текст';

  @override
  String get selectTextFileOrEnterText => 'Выбрать текстовый файл или ввести текст';

  @override
  String get originalLanguage => 'Оригинальный язык';

  @override
  String get translationLanguages => 'Языки перевода';

  @override
  String get startMinuteForTimestamps => 'Начальная минута для временных меток';

  @override
  String get transcriptionLanguage => 'Язык транскрипции';

  @override
  String get generating => 'Генерация...';

  @override
  String get generate => 'Сгенерировать';

  @override
  String get deepseekApiKey => 'API ключ DeepSeek';

  @override
  String get validateKey => 'Проверить ключ';

  @override
  String get keyIsValid => 'Ключ действителен';

  @override
  String get keyIsInvalid => 'Ключ недействителен';

  @override
  String get lyricsGenerationSuccess => 'Текст успешно сгенерирован';

  @override
  String get lyricsGenerationError => 'Ошибка генерации текста';

  @override
  String get savingFiles => 'Сохранение файлов...';

  @override
  String get enterText => 'Ввести текст';

  @override
  String get transcript => 'Транскрипция';

  @override
  String get originalTextEditable => 'Оригинальный текст (редактируемый)';

  @override
  String get selectLanguageToEdit => 'Выберите язык для редактирования';

  @override
  String get moveLineUp => 'Переместить строку вверх';

  @override
  String get moveLineDown => 'Переместить строку вниз';

  @override
  String get moveAllTranslationsUp => 'Сдвинуть все переводы вверх';

  @override
  String get moveAllTranslationsDown => 'Сдвинуть все переводы вниз';

  @override
  String get translationSaved => 'Перевод сохранен!';

  @override
  String get translationSaveFailed => 'Не удалось сохранить перевод';

  @override
  String get loadTextTitle => 'Загрузить текст';

  @override
  String get noOriginalTextWarning => 'Сначала загрузите оригинальный текст';

  @override
  String get selectLanguageOriginal => 'Язык оригинала';

  @override
  String get startTimestampMinutes => 'Начало таймстампа (минуты)';

  @override
  String get selectLanguageTranslation => 'Язык перевода';

  @override
  String get originalTextLoaded => 'Оригинальный текст загружен успешно!';

  @override
  String get translationLoaded => 'Перевод загружен успешно!';

  @override
  String get transcriptLoaded => 'Транскрипция загружена успешно!';

  @override
  String get selectTranslationLanguage => 'Язык перевода для транскрипции';

  @override
  String get noTranslationWarning => 'Нет загруженных переводов';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Несоответствие строк: $loaded строк, ожидается $expected';
  }

  @override
  String get loadTextTooltip => 'Загрузить текст или перевод';

  @override
  String get loadFromFile => 'Загрузить из файла';

  @override
  String get pasteFromClipboard => 'Вставить из буфера обмена';

  @override
  String get audioNotificationService => 'Сервис аудио-уведомлений';

  @override
  String get audioNotificationServiceActive => 'Статус: ✅ Активен';

  @override
  String get audioNotificationServiceError => 'Статус: ❌ Ошибка';

  @override
  String get errorLabel => 'Ошибка:';

  @override
  String get audioNotificationServiceDescription => 'Эта служба предоставляет уведомления при свернутом приложении';

  @override
  String get reorder => 'Изменить порядок';

  @override
  String get done => 'Готово';

  @override
  String get selectMultiple => 'Выбрать несколько';

  @override
  String get sortSongs => 'Сортировать песни';

  @override
  String get importSong => 'Импортировать песню';

  @override
  String get sortDefault => 'По умолчанию';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Новые';

  @override
  String get sortDateAsc => 'Старые';

  @override
  String get importingSongs => 'Импорт песен...';

  @override
  String get noSongsInPlaylist => 'В этом плейлисте нет песен';

  @override
  String get addSongsFromLibraryHint => 'Добавить песни из библиотеки';

  @override
  String get removedSongsFromPlaylist => 'Удалены песни из плейлиста';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Не удалось удалить песни: $error';
  }

  @override
  String get deletePlaylistTitle => 'Удалить плейлист';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'Вы уверены, что хотите удалить \"$playlist\"?';
  }

  @override
  String get failedToDeletePlaylist => 'Не удалось удалить плейлист:';

  @override
  String get specifyTranslationLanguage => 'Укажите язык перевода';

  @override
  String get languageNameLabel => 'Название языка';

  @override
  String get languageNameHint => 'Например: Русский, Авторский, Поэтический';

  @override
  String get translationTypeLabel => 'Тип перевода:';

  @override
  String get translationTypeNormal => 'Обычный';

  @override
  String get translationTypeAuthor => 'Авторский';

  @override
  String get translationTypePoetic => 'Поэтический';

  @override
  String get translationTypeLiteral => 'Буквальный';

  @override
  String mp3FilesCount(Object count) {
    return 'MP3 файлов: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return 'Импортировано $count файл(ов) (база данных пропущена)';
  }

  @override
  String get databaseMerged => 'База данных объединена';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'База данных объединена, MP3 файлов: $count';
  }

  @override
  String get databaseReplaced => 'База данных заменена';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'База данных заменена, MP3 файлов: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Подтвердить замену';

  @override
  String get confirmReplaceDatabaseWarning => 'Вы уверены? Вы потеряете все существующие песни и плейлисты!';

  @override
  String get replaceAll => 'Заменить все';

  @override
  String get selectLanguages => 'Выберите языки';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Выбрано: $count языков';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Выбрано: $count';
  }

  @override
  String get promptPreset => 'Пресет промпта';

  @override
  String get balanced => 'Сбалансированный';

  @override
  String get poetic => 'Поэтичный';

  @override
  String get literal => 'Буквальный';

  @override
  String get customPromptOption => 'Пользовательский...';

  @override
  String get editPrompt => 'Редактировать промпт';

  @override
  String get notSet => 'Не задано';

  @override
  String get showOrEditApiKey => 'Показать/Редактировать ключ API';

  @override
  String get timeout => 'Таймаут';

  @override
  String get model => 'Модель';

  @override
  String get resetToPreset => 'Сбросить к пресету';

  @override
  String get customPrompt => 'Пользовательский промпт';

  @override
  String customPromptChars(Object count) {
    return 'Пользовательский промпт ($count символов)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Используется пресет: $preset';
  }

  @override
  String get characters => 'символов';

  @override
  String get deepSeekPromptTitle => 'Промпт DeepSeek';

  @override
  String get customPromptLabel => 'Пользовательский промпт';

  @override
  String get leaveEmptyToUseDefault => 'Оставьте пустым для использования промпта по умолчанию';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Оставьте пустым, чтобы использовать промпт по умолчанию, встроенный в приложение';

  @override
  String get apiKeySaved => 'API ключ сохранен';

  @override
  String get enterTimeout => 'Введите таймаут в секундах';

  @override
  String get validTimeoutRange => 'Пожалуйста, введите корректный таймаут (1-3600 секунд)';

  @override
  String get customTimeout => 'Пользовательский таймаут';

  @override
  String get timeoutSeconds => 'Таймаут (секунды)';

  @override
  String timeoutSetTo(Object value) {
    return 'Таймаут установлен на $value секунд';
  }

  @override
  String get customModel => 'Пользовательская модель';

  @override
  String get modelName => 'Название модели';

  @override
  String get enterModelName => 'Введите точное название модели, предоставленное DeepSeek API';

  @override
  String get pleaseEnterModelName => 'Пожалуйста, введите название модели';

  @override
  String modelSetTo(Object value) {
    return 'Модель установлена на $value';
  }

  @override
  String get editCustomPrompt => 'Редактировать пользовательский промпт';

  @override
  String get editPresetPrompt => 'Редактировать пресет промпта';

  @override
  String get editingPreset => 'Редактирование пресета';

  @override
  String get anyChangesSaveAsCustom => 'Любые изменения сохранятся как пользовательский промпт. Используйте кнопку \'Сбросить\' для восстановления оригинального пресета.';

  @override
  String get useResetToRestorePreset => 'Используйте кнопку \'Сбросить\' для восстановления оригинального пресета';

  @override
  String get prompt => 'Промпт';

  @override
  String get promptSaved => 'Промпт сохранен';

  @override
  String get usingPresetPrompt => 'Используется пресет промпта';

  @override
  String get apiKeyHint => 'Ключ API';

  @override
  String get modelHint => 'например, deepseek-v3';

  @override
  String get enterExactModelName => 'Введите точное название модели, предоставленное DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'Пожалуйста, сначала введите ключ API';

  @override
  String get maxTokensRegular => 'Max Tokens (Обычный)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Лимит токенов для обычных запросов перевода';

  @override
  String get maxTokensJsonHint => 'Лимит токенов для полных запросов генерации (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (обычный) установлен на $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) установлен на $value';
  }

  @override
  String get refreshFolder => 'Обновить папку';

  @override
  String get refreshingFolder => 'Обновление папки...';

  @override
  String get playlistCreatedWithLink => 'Плейлист создан! Нажмите \"Обновить\" для загрузки песен из папки';

  @override
  String refreshedPlaylist(Object count) {
    return 'Обновлено: $count песен';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Ошибка обновления: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Не удалось загрузить песни: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'Папка с музыкой не существует';

  @override
  String successfullyImportedSongs(Object count) {
    return 'Успешно импортировано $count песен';
  }

  @override
  String get noAudioFileSelected => 'Аудиофайл не выбран';

  @override
  String get noZipArchiveSelected => 'ZIP архив не выбран';

  @override
  String get noFolderConfigured => 'Папка не настроена';

  @override
  String get missingLyricsTranslations => 'Отсутствуют тексты/переводы';

  @override
  String missingForSong(Object songName) {
    return 'Для \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Отсутствуют: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'Что вы хотите сделать?';

  @override
  String get lyricsGeneratedSuccessfully => 'Текст успешно сгенерирован';

  @override
  String get setDeepSeekApiKey => 'Пожалуйста, установите API ключ DeepSeek в настройках';

  @override
  String failedToOpenSong(Object error) {
    return 'Не удалось открыть песню: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'Также удалить файлы LRC и JSON';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Добавлено в \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Не удалось добавить в плейлист: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return 'Экспортировано $count песен';
  }

  @override
  String get fileNotFound => 'Файл не найден';

  @override
  String get selectZipFileNotJson => 'Пожалуйста, выберите ZIP файл, а не JSON или LRC';

  @override
  String get noFilesFoundInZip => 'Файлы не найдены в ZIP архиве';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Неверный формат ZIP файла: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return 'Найдено $count переводов';
  }

  @override
  String mp3ImportError(Object error) {
    return 'Ошибка импорта MP3: $error';
  }

  @override
  String get importSongFirstToSearch => 'Сначала импортируйте песню для поиска текстов';

  @override
  String get lyricsFetched => 'Тексты получены';

  @override
  String get lyricsFoundUseCreate => 'Тексты найдены! Используйте для создания синхронизированного LRC файла';

  @override
  String get deleteSelectedSongs => 'Удалить выбранные песни';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'Вы уверены, что хотите удалить $count песен?';
  }

  @override
  String get songsDeletedSuccessfully => 'Песни успешно удалены';

  @override
  String get storagePermissionRequired => 'Требуется разрешение на доступ к папкам.';

  @override
  String get enableStoragePermission => 'Пожалуйста, включите разрешение на хранилище в настройках приложения.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get unableToSelectFolder => 'Не удалось выбрать папку. Попробуйте альтернативу:';

  @override
  String get selectFilesInstead => 'Выбрать файлы вместо папки';

  @override
  String get enterFolderPath => 'Пожалуйста, введите путь к папке';

  @override
  String get folderDoesNotExist => '✗ Папка не существует';

  @override
  String folderSetWithPath(Object path) {
    return 'Папка установлена: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Ошибка установки папки: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'Не удалось выбрать папку с текстами. Попробуйте альтернативу:';

  @override
  String get useManualPath => 'Использовать ручной путь (для тестирования)';

  @override
  String get enterFolderPathManually => 'Введите путь к папке вручную вместо использования выбора папки';

  @override
  String get folderPathLabel => 'Путь к папке';

  @override
  String get folderPathHint => 'Пример: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Полный путь к папке с музыкой';

  @override
  String get setPath => 'Установить путь';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'Выбрать ZIP архив с текстами для \"$title\"';
  }

  @override
  String get skip => 'Пропустить';

  @override
  String get retry => 'Повторить';

  @override
  String get failedToCopyLrcFile => 'Не удалось скопировать LRC файл';

  @override
  String copiedJsonFiles(Object count) {
    return 'Скопировано $count файлов JSON';
  }

  @override
  String get failedToCopyJsonFiles => 'Не удалось скопировать файлы JSON';

  @override
  String failedToDeleteSong(Object error) {
    return 'Не удалось удалить песню: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return 'Добавлено $count песен в \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'Добавить $count песен в плейлист';
  }

  @override
  String get failedToExportSongs => 'Не удалось экспортировать песни';

  @override
  String get ok => 'ОК';

  @override
  String deleteSongConfirm(Object song) {
    return 'Вы уверены, что хотите удалить \"$song\"?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Выберите папку с музыкой для этого плейлиста';

  @override
  String get folderLinkedToPlaylist => 'Папка связана с плейлистом';

  @override
  String get folderUnlinkedFromPlaylist => 'Папка отвязана от плейлиста';

  @override
  String get checkFolderAccess => 'Проверить доступ';

  @override
  String get checkingPermissions => 'Проверка прав доступа...';

  @override
  String get folderAccessible => '✓ Папка доступна';

  @override
  String get folderNotAccessible => '✗ Папка недоступна';

  @override
  String audioFilesFound(Object count) {
    return 'Найдено $count аудио файл(ов)';
  }

  @override
  String lyricsFound(Object count) {
    return 'Найдено $count файл(ов) с текстом';
  }

  @override
  String get noAudioFiles => 'Аудио файлы не найдены';

  @override
  String get noLyricsFiles => 'Файлы с текстом не найдены';

  @override
  String errorCheckingAccess(Object error) {
    return 'Ошибка проверки доступа: $error';
  }

  @override
  String get folderPathColon => 'Путь к папке:';

  @override
  String get permissionsStatus => 'Статус разрешений:';

  @override
  String get folderContent => 'Содержимое папки:';

  @override
  String get accessGranted => '✓ Доступ разрешен';

  @override
  String get accessDenied => '✗ Доступ запрещен';

  @override
  String get permissionRequestFailed => 'Не удалось запросить разрешения';

  @override
  String get pleaseGrantPermissions => 'Пожалуйста, предоставьте разрешения на доступ к хранилищу для проверки папки';

  @override
  String get refreshOnlySongs => 'Только песни';

  @override
  String get refreshEverything => 'Всё';

  @override
  String get refreshDialogDescription => 'Что вы хотите обновить? \"Только песни\" ускоряет процесс, пропуская тексты.';

  @override
  String get mostSongs => 'Больше всего песен';

  @override
  String get playlistPlay => 'Плейлист';

  @override
  String get musicNote => 'Нота';

  @override
  String get favorite => 'Избранное';

  @override
  String get libraryMusic => 'Библиотека';

  @override
  String get tapToSelectFolder => 'Нажмите, чтобы выбрать папку с аудиофайлами';

  @override
  String get showVerticalSlider => 'Вертикальный слайдер';

  @override
  String get showVerticalSliderSubtitle => 'Показывать вертикальный слайдер смещения в плеере';

  @override
  String get transcriptionEnabled => 'Транскрипция включена';

  @override
  String get transcriptionDisabled => 'Транскрипция выключена';

  @override
  String languageSelected(String language) {
    return 'Выбран язык: $language';
  }

  @override
  String get noTranslationsScanning => 'Переводов нет, сканируем папку...';

  @override
  String translationsLoadedCount(int count) {
    return 'Загружено переводов: $count';
  }

  @override
  String get translationsNotFound => 'Переводов не найдено для этой песни';

  @override
  String errorLoadingTranslations(String error) {
    return 'Ошибка загрузки переводов: $error';
  }

  @override
  String languageNotAvailable(String settingLang, String availableLang) {
    return 'В настройках выбран $settingLang, но перевода нет. Открываю: $availableLang';
  }

  @override
  String get errorAudioService => 'Ошибка Audio Service';

  @override
  String get audioServiceFailed => 'Не удалось инициализировать фоновое воспроизведение.';

  @override
  String get notificationMayNotAppear => 'Уведомление плеера может не появиться.';

  @override
  String get lrcAndTranslationsSaved => 'LRC и все переводы сохранены!';

  @override
  String translationDeleted(String name) {
    return 'Перевод \"$name\" удалён';
  }

  @override
  String failedToDeleteTranslation(String error) {
    return 'Ошибка удаления перевода: $error';
  }

  @override
  String get generatingTranslations => 'Генерация переводов';

  @override
  String get generatingProcessing => 'Обработка:';

  @override
  String get generatingLines => 'Строки:';

  @override
  String generatingLinesOf(int current, int total) {
    return '$current из $total';
  }

  @override
  String generatingErrors(int count) {
    return 'Ошибки: $count';
  }

  @override
  String selectedLanguagesCountGen(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get transcriptionSection => 'Транскрипция';

  @override
  String get translationsSection => 'Переводы';

  @override
  String get translationLoadedSuccess => 'Перевод загружен успешно!';

  @override
  String get exportSuccessful => 'Экспорт успешен!';

  @override
  String get failedToExportSong => 'Не удалось экспортировать песню';

  @override
  String get deleteTranslationTitle => 'Удалить перевод';

  @override
  String deleteTranslationConfirm(String name) {
    return 'Удалить перевод \"$name\"?';
  }

  @override
  String get lrcLoaded => 'LRC файл загружен';

  @override
  String get noFilesLoaded => 'Файлы не найдены в архиве';

  @override
  String failedToProcessArchive(String error) {
    return 'Ошибка обработки архива: $error';
  }

  @override
  String failedToLoadTranslationsShort(String error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get noFolderConfiguredMsg => 'Папка не настроена';

  @override
  String failedToPlaySongMsg(String error) {
    return 'Ошибка воспроизведения: $error';
  }

  @override
  String addedSongsToPlaylistMsg(int count, String playlist) {
    return 'Добавлено $count песен в \"$playlist\"';
  }

  @override
  String failedToAddSongsMsg(String error) {
    return 'Ошибка добавления: $error';
  }

  @override
  String addSongsButton(int count) {
    return 'Добавить $count';
  }

  @override
  String get removeSong => 'Удалить';

  @override
  String failedToRemoveSongMsg(String error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String failedToReorderSongsMsg(String error) {
    return 'Ошибка сортировки: $error';
  }

  @override
  String failedToLoadSongsMsg(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String errorLoadingText(String error) {
    return 'Ошибка загрузки текста: $error';
  }

  @override
  String lrcAndTranslationsLoaded(int count) {
    return 'LRC и $count перевод(ов) загружено';
  }

  @override
  String translationsOnlyLoaded(int count) {
    return 'Загружено $count перевод(ов)';
  }

  @override
  String get pleaseSetDeepSeekApiKey => 'Установите DeepSeek API ключ в настройках';

  @override
  String get lyricsGeneratedSuccessfullyMsg => 'Тексты сгенерированы успешно';

  @override
  String exportShareSubject(String title) {
    return 'LingoTune экспорт: $title с лирикой и переводами';
  }

  @override
  String get timestampOffset => 'Смещение временных меток';

  @override
  String get timestampOffsetSubtitle => 'Смещение по умолчанию в минутах для генерируемых меток';

  @override
  String get resetTimestamps => 'Сбросить метки';

  @override
  String get resetTimestampsConfirm => 'Сбросить все временные метки к значениям по умолчанию?';

  @override
  String get resetTimestampsSuccess => 'Временные метки сброшены';

  @override
  String get saveAfterReset => 'Сохранить изменения';

  @override
  String get saveAfterResetConfirm => 'Сохранить изменения после сброса меток?';

  @override
  String get repeatOff => 'Повтор выкл';

  @override
  String get repeatAll => 'Повтор всех';

  @override
  String get repeatOne => 'Повтор одной';

  @override
  String get repeatAllPlaylists => 'Повтор всех плейлистов';

  @override
  String get playbackSpeed => 'Скорость воспроизведения';

  @override
  String get speedNormal => 'Обычная';

  @override
  String get lyricsPositionOffset => 'Задержка синхронизации текста';

  @override
  String get lyricsPositionOffsetSubtitle => 'Задержка подсветки в секундах (увеличьте, если подсветка спешит)';

  @override
  String get studyMode => 'Изучение';

  @override
  String get studyModeTooltip => 'Режим изучения: озвучить перевод, затем фразу из песни';

  @override
  String get studyModeStarted => 'Режим изучения включён';

  @override
  String get studyModeStopped => 'Режим изучения выключен';

  @override
  String get studyModeNoLyrics => 'Нет текста с временными метками для этой песни';

  @override
  String get studyModeSettings => 'Настройки режима изучения';

  @override
  String get studyModeOrder => 'Порядок';

  @override
  String get studyModeOrderTranslationFirst => 'Сначала перевод';

  @override
  String get studyModeOrderOriginalFirst => 'Сначала оригинал';

  @override
  String get studyModeOrderOverlay => 'Поверх (тихий оригинал)';

  @override
  String get studyModeSpeechRate => 'Скорость речи';

  @override
  String get studyModeLongPressHint => 'Долгое нажатие — настройки';

  @override
  String get exportCurrentSong => 'Экспорт песни';

  @override
  String get studyModeOverlayTiming => 'Когда говорить';

  @override
  String get studyModeOverlayAtStart => 'В начале строки';

  @override
  String get studyModeOverlayAtEnd => 'В конце строки';

  @override
  String get studyModeOverlayAtBoth => 'В начале и в конце';

  @override
  String get studyModeDuckVolume => 'Громкость оригинала';

  @override
  String get studyModeOpenSettings => 'Настройки режима изучения';
}
