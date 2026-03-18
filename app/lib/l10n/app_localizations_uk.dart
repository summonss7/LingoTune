// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Бібліотека';

  @override
  String get playlists => 'Плейлисти';

  @override
  String get settings => 'Налаштування';

  @override
  String get allSongs => 'Всі пісні';

  @override
  String get favorites => 'Улюблені';

  @override
  String get createPlaylist => 'Створити плейлист';

  @override
  String get playlistName => 'Назва плейлисту';

  @override
  String get iconOptional => 'Іконка (опціонально)';

  @override
  String get cancel => 'Скасувати';

  @override
  String get create => 'Створити';

  @override
  String get delete => 'Видалити';

  @override
  String get edit => 'Редагувати';

  @override
  String get save => 'Зберегти';

  @override
  String get close => 'Закрити';

  @override
  String get search => 'Пошук';

  @override
  String get filter => 'Фільтр';

  @override
  String get sort => 'Сортування';

  @override
  String get addToFavorites => 'Додати до улюблених';

  @override
  String get removeFromFavorites => 'Видалити з улюблених';

  @override
  String get addToPlaylist => 'Додати до плейлисту';

  @override
  String get removeFromPlaylist => 'Видалити з плейліста';

  @override
  String get addSongsToLibrary => 'Додати пісні з бібліотеки';

  @override
  String get noSongsToAdd => 'Немає пісень для додавання';

  @override
  String addButtonText(Object count) {
    return 'Додати $count';
  }

  @override
  String get selected => 'обрано';

  @override
  String get darkMode => 'Темна тема';

  @override
  String get lightMode => 'Світла тема';

  @override
  String get autoScroll => 'Автопрокрутка';

  @override
  String get autoScrollSubtitle => 'Автоматично прокручувати до поточного рядка';

  @override
  String get highlightNextLine => 'Підсвітити наступний рядок';

  @override
  String get highlightNextLineSubtitle => 'Показати наступний рядок з легким підсвічуванням';

  @override
  String get fontSize => 'Розмір шрифта';

  @override
  String get scrollOffset => 'Зсув прокручування';

  @override
  String get scrollOffsetSubtitle => 'Відстань від верху екрана в пікселях';

  @override
  String get autoScrollFocusOffset => 'Фокус автоматичного прокручування';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Початкова позиція фокусу для автоматичного прокручування (за замовчуванням: +50)';

  @override
  String get defaultTranslationLanguage => 'Мова перекладу за замовчуванням';

  @override
  String get defaultOriginalLanguage => 'Оригінальна мова за замовчуванням';

  @override
  String get russian => 'Російська';

  @override
  String get english => 'Англійська';

  @override
  String get romanian => 'Румунська';

  @override
  String get french => 'Французька';

  @override
  String get german => 'Німецька';

  @override
  String get spanish => 'Іспанська';

  @override
  String get italian => 'Італійська';

  @override
  String get portuguese => 'Португальська';

  @override
  String get lyricsFolder => 'Папка текстів';

  @override
  String get useLyricsFolder => 'Використовувати папку текстів';

  @override
  String get useLyricsFolderDisabled => 'Вимкнено - файли повинні вибиратися разом з аудіо';

  @override
  String get setLyricsFolder => 'Встановити папку текстів';

  @override
  String get selectFolder => 'Вибрати папку';

  @override
  String get folderPath => 'Шлях до папки';

  @override
  String get examples => 'Приклади:';

  @override
  String get defaultFolder => 'За замовчуванням: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Поточна папка:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Папку встановлено: $path';
  }

  @override
  String get folderSetFailed => 'Папка не існує або немає доступу';

  @override
  String get resetToDefault => 'Скинути за замовчуванням';

  @override
  String get showCurrentFolder => 'Показати поточну папку';

  @override
  String get changeFolder => 'Змінити папку';

  @override
  String get resetToDefaultFolder => 'Скинути до папки за замовчуванням';

  @override
  String get folderReset => 'Скинуто до папки за замовчуванням';

  @override
  String get clearCache => 'Очистити кеш';

  @override
  String get clearCacheSubtitle => 'Видалити тимчасові файли';

  @override
  String get cacheCleared => 'Кеш очищено';

  @override
  String get resetSongLanguages => 'Скинути мови пісень';

  @override
  String get resetSongLanguagesSubtitle => 'Використовувати мову за замовчуванням з налаштувань';

  @override
  String get songLanguagesReset => 'Мови пісень скинуто';

  @override
  String get about => 'Про програму';

  @override
  String get translationsLoaded => 'Переклади успішно завантажено!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Не вдалося завантажити переклади: $error';
  }

  @override
  String get editTranslations => 'Редагувати переклади';

  @override
  String get loadTranslationsFromFile => 'Завантажити переклади з файлу';

  @override
  String get loadTextMenu => 'Завантажити текст';

  @override
  String get loadTranslations => 'Завантажити переклади';

  @override
  String get noFileSelected => 'Файл не вибрано';

  @override
  String get noLrcFileAssociated => 'Немає пов\'язаного LRC файлу з цією піснею';

  @override
  String get lrcFileSaved => 'LRC файл успішно збережено!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'Не вдалося зберегти LRC файл: $error';
  }

  @override
  String get exitEditMode => 'Вийти з режиму редагування';

  @override
  String get editTimestamps => 'Редагувати часові мітки';

  @override
  String get saveChanges => 'Зберегти зміни';

  @override
  String get language => 'Мова';

  @override
  String get loading => 'Завантаження...';

  @override
  String get noSongsFound => 'Пісень не знайдено';

  @override
  String get noPlaylistsFound => 'Плейлистів не знайдено';

  @override
  String get selectSong => 'Виберіть пісню для відтворення';

  @override
  String get song => 'Пісня';

  @override
  String get artist => 'Виконавець';

  @override
  String get duration => 'Тривалість';

  @override
  String get actions => 'Дії';

  @override
  String get play => 'Відтворити';

  @override
  String get pause => 'Пауза';

  @override
  String get stop => 'Стоп';

  @override
  String get previous => 'Попередній';

  @override
  String get next => 'Наступний';

  @override
  String get rewind10 => '-10с';

  @override
  String get forward10 => '+10с';

  @override
  String get repeat => 'Повторити';

  @override
  String get shuffle => 'Перемішати';

  @override
  String get volume => 'Гучність';

  @override
  String get speed => 'Швидкість';

  @override
  String get lyrics => 'Текст';

  @override
  String get translations => 'Переклади';

  @override
  String get originalText => 'Оригінальний текст';

  @override
  String get translatedText => 'Перекладений текст';

  @override
  String get showTranscription => 'Показати транскрипцію';

  @override
  String get showTranscriptionSubtitle => 'Відображати транскрипцію вимови';

  @override
  String get showTranslationFirst => 'Переклад першим';

  @override
  String get showTranslationFirstSubtitle => 'Показувати переклад перед оригіналом';

  @override
  String get italianLang => 'Італійська';

  @override
  String get portugueseLang => 'Португальська';

  @override
  String get lyricsEditor => 'Редактор текстів';

  @override
  String get addLine => 'Додати рядок';

  @override
  String get updateLine => 'Оновити рядок';

  @override
  String get deleteLine => 'Видалити рядок';

  @override
  String get clearAll => 'Очистити все';

  @override
  String get moveUp => 'Вгору';

  @override
  String get moveDown => 'Вниз';

  @override
  String get autoSyncLyrics => 'Автосинхронізація текстів';

  @override
  String get exportLrc => 'Експорт LRC (Оригінал)';

  @override
  String get exportJson => 'Експорт JSON (Переклади)';

  @override
  String get markTimestamp => 'Позначити час (Enter)';

  @override
  String get original => 'Оригінал';

  @override
  String get translation => 'Переклад';

  @override
  String get audioFile => 'Аудіофайл';

  @override
  String get songTitle => 'Назва пісні';

  @override
  String get browse => 'Огляд';

  @override
  String get audioControls => 'Керування аудіо';

  @override
  String get addEditLine => 'Додати/Редагувати рядок';

  @override
  String get instructions => 'Інструкції';

  @override
  String get lyricsEditorInstructions => 'Інструкції з синхронізації LRC:\n\n1. Виберіть аудіофайл, натиснувши кнопку Огляд\n2. Введіть назву пісні та виконавця (опціонально)\n3. Натисніть Відтворити для запуску аудіо\n4. Коли рядок співається, введіть оригінальний текст у поле \'Оригінал\'\n5. Натисніть Enter або \'Позначити час\' для запису позначки\n6. Опціонально додайте переклад у поле \'Переклад\'\n7. Повторіть кроки 4-6 для кожного рядка\n8. Використовуйте \'Експорт LRC\' для збереження оригінального тексту з позначками\n9. Використовуйте \'Експорт JSON\' для збереження перекладів\n\nПоради:\n- Використовуйте -10с/+10с для швидкої навігації по пісні\n- Ви можете змінювати порядок рядків за допомогою кнопок Вгору/Вниз\n- Завантажуйте раніше збережені JSON файли для редагування перекладів';

  @override
  String get welcome => 'Вітаємо';

  @override
  String get welcomeMessage => 'Почніть вивчення мов з музикою!';

  @override
  String get importSongs => 'Імпортувати пісні';

  @override
  String get importSongsSubtitle => 'Додати аудіофайли з пристрою';

  @override
  String get manageLibrary => 'Керувати бібліотекою';

  @override
  String get manageLibrarySubtitle => 'Організуйте свої пісні та плейлисти';

  @override
  String get syncLyrics => 'Синхронізувати тексти';

  @override
  String get syncLyricsSubtitle => 'Автоматична синхронізація текстів з аудіо';

  @override
  String get languageLearning => 'Вивчення мов • Музика • Переклади';

  @override
  String get version => 'Версія';

  @override
  String get developer => 'Розроблено';

  @override
  String get website => 'Вебсайт';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Не вдалося створити плейлист: $error';
  }

  @override
  String get playlistCreated => 'Плейлист успішно створено!';

  @override
  String get playlistDeleted => 'Плейлист успішно видалено!';

  @override
  String get playlistUpdated => 'Плейлист успішно оновлено!';

  @override
  String get songAdded => 'Пісня успішно додана!';

  @override
  String get songRemoved => 'Пісня успішно видалена!';

  @override
  String get songDeleted => 'Пісня успішно видалена!';

  @override
  String get error => 'Помилка';

  @override
  String get warning => 'Попередження';

  @override
  String get info => 'Інформація';

  @override
  String get success => 'Успішно';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get areYouSure => 'Ви впевнені?';

  @override
  String get unsavedChanges => 'У вас є незбережені зміни. Продовжити?';

  @override
  String get selectLanguage => 'Вибрати мову';

  @override
  String get appLanguage => 'Мова програми';

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
  String get welcomeToLingoTune => 'Вітаємо в LingoTune';

  @override
  String get folderSetupMessage => 'Виберіть папку для зберігання текстів та перекладів (LRC та JSON файли). Це спростить організацію вашої музичної бібліотеки.';

  @override
  String get selectFolderNow => 'Вибрати папку зараз';

  @override
  String get goToSettings => 'Перейти до налаштувань';

  @override
  String get setupLater => 'Налаштувати пізніше';

  @override
  String get useDefaultFolder => 'Використовувати папку за замовчуванням';

  @override
  String get databaseFound => 'Базу даних знайдено у файлі імпорту';

  @override
  String get importDatabaseQuestion => 'Хочете також імпортувати базу даних?';

  @override
  String get mergeDatabase => 'Об\'єднати';

  @override
  String get replaceDatabase => 'Замінити';

  @override
  String get importDatabase => 'Імпорт бази даних';

  @override
  String get skipDatabase => 'Пропустити базу даних';

  @override
  String get mergeDatabaseDescription => 'Об\'єднати імпортовані пісні з вашою бібліотекою (додає тільки нові елементи)';

  @override
  String get replaceDatabaseDescription => 'Замінити всю вашу бібліотеку імпортованою базою даних (ви втратите всі існуючі дані)';

  @override
  String get exporting => 'Експорт...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Експорт $current з $total пісень';
  }

  @override
  String get exportDatabaseIncluded => 'Базу даних включено в експорт';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'Імпортовано $fileCount файл(ів) та база даних';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'Імпортовано $fileCount файл(ів)';
  }

  @override
  String get chinese => 'Китайська';

  @override
  String get arabic => 'Арабська';

  @override
  String get colorTheme => 'Колір теми';

  @override
  String get themeColorPurple => 'Фиолетовий';

  @override
  String get themeColorBlue => 'Синій';

  @override
  String get themeColorGreen => 'Зелений';

  @override
  String get themeColorOrange => 'Помаранчевий';

  @override
  String get themeColorRed => 'Червоний';

  @override
  String get themeColorPink => 'Рожевий';

  @override
  String get themeColorDeepOrange => 'Темно-помаранчевий';

  @override
  String get themeColorDarkRed => 'Темно-червоний';

  @override
  String get themeColorTeal => 'Бірюзовий';

  @override
  String get themeColorCyan => 'Голубий';

  @override
  String get themeColorAmber => 'Янтарний';

  @override
  String get themeColorLime => 'Лаймовий';

  @override
  String get ukrainianLang => 'Українська';

  @override
  String get font => 'Шрифт';

  @override
  String get fontSettings => 'Налаштування шрифта';

  @override
  String get systemFont => 'Системний';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Розмір основного тексту';

  @override
  String get mainTextBold => 'Жирний основний текст';

  @override
  String get translationSize => 'Розмір перекладу';

  @override
  String get translationBold => 'Жирний переклад';

  @override
  String get transcriptSize => 'Розмір транскрипції';

  @override
  String get transcriptBold => 'Жирна транскрипція';

  @override
  String get defaultStartScreen => 'Початковий екран за замовчуванням';

  @override
  String get defaultStartScreenSubtitle => 'Екран, який буде показано при запуску програми';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Додавати до бібліотеки при додаванні до плейлисту';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Автоматично додавати пісні до бібліотеки при додаванні до плейлисту';

  @override
  String get serviceMessages => 'Службові повідомлення';

  @override
  String get serviceMessagesSubtitle => 'Показувати службові повідомлення про переклад і транскрипцію';

  @override
  String get includeMp3Files => 'Включити MP3 файли';

  @override
  String get includeMp3FilesSubtitle => 'Це збільшить розмір архіву';

  @override
  String get importMp3Files => 'Імпортувати MP3 файли';

  @override
  String get importMp3FilesSubtitle => 'Додати музичні файли до бібліотеки';

  @override
  String get exportSongs => 'Експортувати пісні';

  @override
  String get import => 'Імпорт';

  @override
  String get addMultiple => 'Вибрати кілька';

  @override
  String get addToPlaylistShort => 'Додати';

  @override
  String get deleteShort => 'Видалити';

  @override
  String get selectAllShort => 'Всі';

  @override
  String get deselectAllShort => 'Очистити';

  @override
  String get exitSelectionMode => 'Вийти з режиму вибору';

  @override
  String get selectAll => 'Вибрати всі';

  @override
  String get deselectAll => 'Зняти виділення';

  @override
  String get deleteSelected => 'Видалити вибрані';

  @override
  String get addMultipleToPlaylist => 'Додати до плейлисту';

  @override
  String get coverArt => 'Обкладинка';

  @override
  String get playlistCover => 'Обкладинка плейлисту';

  @override
  String get selectFromGallery => 'Вибрати з галереї';

  @override
  String get removeCover => 'Видалити обкладинку';

  @override
  String get coverUpdated => 'Обкладинку оновлено';

  @override
  String get coverRemoved => 'Обкладинку видалено';

  @override
  String errorWithMessage(Object error) {
    return 'Помилка: $error';
  }

  @override
  String get importFolders => 'Імпорт папок';

  @override
  String get selectMusicFolder => 'Вибрати папку з музикою';

  @override
  String get folderWithAudioFiles => 'Папка з файлами MP3/WAV';

  @override
  String get sameFolderForLyrics => 'Та сама папка для текстів';

  @override
  String get selectLyricsFolder => 'Вибрати папку з текстами';

  @override
  String get folderWithLyricsFiles => 'Папка з файлами LRC/JSON (опціонально)';

  @override
  String get pleaseEnterPlaylistName => 'Будь ласка, введіть назву плейлисту';

  @override
  String get pleaseSelectMusicFolder => 'Будь ласка, виберіть папку з музикою';

  @override
  String get cropImage => 'Обрізати зображення';

  @override
  String get photoPermissionRequired => 'Потрібен дозвіл на доступ до фото';

  @override
  String get photoPermissionDenied => 'Доступ до фото відмовлено';

  @override
  String get imageProcessingError => 'Не вдалося обробити зображення';

  @override
  String get scanningFolder => 'Сканування папки...';

  @override
  String get importingFiles => 'Імпортування файлів...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Імпортування $current/$total файлів... Знайдено $songs пісень';
  }

  @override
  String processingFile(Object file) {
    return 'Обробка $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Додати до плейлисту';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Додано до \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Не вдалося додати до плейлисту: $error';
  }

  @override
  String get deleteSong => 'Видалити';

  @override
  String get importSongDialogTitle => 'Імпортувати пісню';

  @override
  String get audioOnly => 'Тільки аудіо';

  @override
  String get addLyricsLater => 'Додам тексти пізніше';

  @override
  String get audioWithLyricsZIP => 'Аудіо + ZIP з текстами';

  @override
  String get importWithAllTranslations => 'Імпортувати з усіма перекладами';

  @override
  String get importTranslationDialogTitle => 'Додати переклад';

  @override
  String get loadTranslationFromZip => 'Завантажити з ZIP архіву';

  @override
  String get loadTranslationFromJson => 'Завантажити з JSON файлу';

  @override
  String get noAudioFilesSelected => 'Аудіофайли не вибрано';

  @override
  String failedToImportSongs(Object error) {
    return 'Не вдалося імпортувати пісні: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Не вдалося імпортувати пісню: $error';
  }

  @override
  String get musicFolderNotSelected => 'Папку з музикою не вибрано';

  @override
  String get generateLyrics => 'Згенерувати текст';

  @override
  String get selectTextFileOrEnterText => 'Вибрати текстовий файл або ввести текст';

  @override
  String get originalLanguage => 'Оригінальна мова';

  @override
  String get translationLanguages => 'Мови перекладу';

  @override
  String get startMinuteForTimestamps => 'Початкова хвилина для позначок часу';

  @override
  String get transcriptionLanguage => 'Мова транскрипції';

  @override
  String get generating => 'Генерація...';

  @override
  String get generate => 'Згенерувати';

  @override
  String get deepseekApiKey => 'API ключ DeepSeek';

  @override
  String get validateKey => 'Перевірити ключ';

  @override
  String get keyIsValid => 'Ключ дійсний';

  @override
  String get keyIsInvalid => 'Ключ недійсний';

  @override
  String get lyricsGenerationSuccess => 'Текст успішно згенеровано';

  @override
  String get lyricsGenerationError => 'Не вдалося згенерувати текст';

  @override
  String get savingFiles => 'Збереження файлів...';

  @override
  String get enterText => 'Ввести текст';

  @override
  String get transcript => 'Транскрипція';

  @override
  String get originalTextEditable => 'Оригінальний текст (редагований)';

  @override
  String get selectLanguageToEdit => 'Оберіть мову для редагування';

  @override
  String get moveLineUp => 'Перемістити рядок вгору';

  @override
  String get moveLineDown => 'Перемістити рядок вниз';

  @override
  String get moveAllTranslationsUp => 'Перемістити всі переклади вгору';

  @override
  String get moveAllTranslationsDown => 'Перемістити всі переклади вниз';

  @override
  String get translationSaved => 'Переклад збережено!';

  @override
  String get translationSaveFailed => 'Не вдалося зберегти переклад';

  @override
  String get loadTextTitle => 'Завантажити текст';

  @override
  String get noOriginalTextWarning => 'Спочатку завантажте оригінальний текст';

  @override
  String get selectLanguageOriginal => 'Оригінальна мова';

  @override
  String get startTimestampMinutes => 'Початок таймстампу (хвилини)';

  @override
  String get selectLanguageTranslation => 'Мова перекладу';

  @override
  String get originalTextLoaded => 'Оригінальний текст завантажено успішно!';

  @override
  String get translationLoaded => 'Переклад завантажено успішно!';

  @override
  String get transcriptLoaded => 'Транскрипцію завантажено успішно!';

  @override
  String get selectTranslationLanguage => 'Мова перекладу для транскрипції';

  @override
  String get noTranslationWarning => 'Немає завантажених перекладів';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Невідповідність рядків: $loaded рядків, очікується $expected';
  }

  @override
  String get loadTextTooltip => 'Завантажити текст або переклад';

  @override
  String get loadFromFile => 'Завантажити з файлу';

  @override
  String get pasteFromClipboard => 'Вставити з буфера обміну';

  @override
  String get audioNotificationService => 'Служба аудіо-сповіщень';

  @override
  String get audioNotificationServiceActive => 'Статус: ✅ Активний';

  @override
  String get audioNotificationServiceError => 'Статус: ❌ Помилка';

  @override
  String get errorLabel => 'Помилка:';

  @override
  String get audioNotificationServiceDescription => 'Ця служба надає сповіщення при згорнутій програмі';

  @override
  String get reorder => 'Впорядкувати';

  @override
  String get done => 'Готово';

  @override
  String get selectMultiple => 'Обрати кілька';

  @override
  String get sortSongs => 'Сортувати пісні';

  @override
  String get importSong => 'Імпортувати пісню';

  @override
  String get sortDefault => 'За замовчуванням';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Найновіші';

  @override
  String get sortDateAsc => 'Найдавніші';

  @override
  String get importingSongs => 'Імпорт пісень...';

  @override
  String get noSongsInPlaylist => 'У цьому плейлисті немає пісень';

  @override
  String get addSongsFromLibraryHint => 'Додати пісні з бібліотеки';

  @override
  String get removedSongsFromPlaylist => 'Пісні видалено з плейлисту';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Не вдалося видалити пісні: $error';
  }

  @override
  String get deletePlaylistTitle => 'Видалити плейлист';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'Ви впевнені, що хочете видалити \"$playlist\"?';
  }

  @override
  String get failedToDeletePlaylist => 'Не вдалося видалити плейлист:';

  @override
  String get specifyTranslationLanguage => 'Вкажіть мову перекладу';

  @override
  String get languageNameLabel => 'Назва мови';

  @override
  String get languageNameHint => 'Наприклад: Російська, Авторська, Поетична';

  @override
  String get translationTypeLabel => 'Тип перекладу:';

  @override
  String get translationTypeNormal => 'Звичайний';

  @override
  String get translationTypeAuthor => 'Авторський';

  @override
  String get translationTypePoetic => 'Поетичний';

  @override
  String get translationTypeLiteral => 'Дослівний';

  @override
  String mp3FilesCount(Object count) {
    return 'MP3 файлів: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return 'Імпортовано $count файл(ів) (базу даних пропущено)';
  }

  @override
  String get databaseMerged => 'Базу даних об\'єднано';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'Базу даних об\'єднано, MP3 файлів: $count';
  }

  @override
  String get databaseReplaced => 'Базу даних замінено';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'Базу даних замінено, MP3 файлів: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Підтвердити заміну';

  @override
  String get confirmReplaceDatabaseWarning => 'Ви впевнені? Ви втратите всі наявні пісні та плейлисти!';

  @override
  String get replaceAll => 'Замінити все';

  @override
  String get selectLanguages => 'Виберіть мови';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Вибрано: $count мов';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Вибрано: $count';
  }

  @override
  String get promptPreset => 'Пресет промпта';

  @override
  String get balanced => 'Збалансований';

  @override
  String get poetic => 'Поетичний';

  @override
  String get literal => 'Дословний';

  @override
  String get customPromptOption => 'Користувацький...';

  @override
  String get editPrompt => 'Редагувати промпт';

  @override
  String get notSet => 'Не задано';

  @override
  String get showOrEditApiKey => 'Показати/Редагувати ключ API';

  @override
  String get timeout => 'Тайм-аут';

  @override
  String get model => 'Модель';

  @override
  String get resetToPreset => 'Скинути до прсету';

  @override
  String get customPrompt => 'Користувацький промпт';

  @override
  String customPromptChars(Object count) {
    return 'Користувацький промпт ($count символів)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Використовується пресет: $preset';
  }

  @override
  String get characters => 'символів';

  @override
  String get deepSeekPromptTitle => 'Промпт DeepSeek';

  @override
  String get customPromptLabel => 'Користувацький промпт';

  @override
  String get leaveEmptyToUseDefault => 'Залиште порожнім для використання промпта за замовчуванням';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Залиште порожнім, щоб використати промпт за замовчуванням, вбудований у програму';

  @override
  String get apiKeySaved => 'Ключ API збережено';

  @override
  String get enterTimeout => 'Введіть тайм-аут у секундах';

  @override
  String get validTimeoutRange => 'Будь ласка, введіть коректний тайм-аут (1-3600 секунд)';

  @override
  String get customTimeout => 'Користувацький тайм-аут';

  @override
  String get timeoutSeconds => 'Тайм-аут (секунди)';

  @override
  String timeoutSetTo(Object value) {
    return 'Тайм-аут встановлено на $value секунд';
  }

  @override
  String get customModel => 'Користувацька модель';

  @override
  String get modelName => 'Назва моделі';

  @override
  String get enterModelName => 'Введіть точну назву моделі, надану DeepSeek API';

  @override
  String get pleaseEnterModelName => 'Будь ласка, введіть назву моделі';

  @override
  String modelSetTo(Object value) {
    return 'Модель встановлено на $value';
  }

  @override
  String get editCustomPrompt => 'Редагувати користувацький промпт';

  @override
  String get editPresetPrompt => 'Редагувати промпт пресета';

  @override
  String get editingPreset => 'Редагування пресета';

  @override
  String get anyChangesSaveAsCustom => 'Будь-які зміни будуть збережені як користувацький промпт. Використовуйте кнопку \'Скинути\' для відновлення оригінального пресета.';

  @override
  String get useResetToRestorePreset => 'Використовуйте кнопку \'Скинути\' для відновлення оригінального пресета';

  @override
  String get prompt => 'Промпт';

  @override
  String get promptSaved => 'Промпт збережено';

  @override
  String get usingPresetPrompt => 'Використовується промпт пресета';

  @override
  String get apiKeyHint => 'Ключ API';

  @override
  String get modelHint => 'напр., deepseek-v3';

  @override
  String get enterExactModelName => 'Введіть точну назву моделі, надану DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'Будь ласка, спочатку введіть ключ API';

  @override
  String get maxTokensRegular => 'Max Tokens (Звичайний)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Ліміт токенів для звичайних запитів перекладу';

  @override
  String get maxTokensJsonHint => 'Ліміт токенів для повних запитів генерації (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (звичайний) встановлено на $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) встановлено на $value';
  }

  @override
  String get refreshFolder => 'Оновити папку';

  @override
  String get refreshingFolder => 'Оновлення папки...';

  @override
  String get playlistCreatedWithLink => 'Плейлист створено! Натисніть \"Оновити\" для завантаження пісень з папки';

  @override
  String refreshedPlaylist(Object count) {
    return 'Оновлено: $count пісень';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Помилка оновлення: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Не вдалося завантажити пісні: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'Папка з музикою не існує';

  @override
  String successfullyImportedSongs(Object count) {
    return 'Успішно імпортовано $count пісень';
  }

  @override
  String get noAudioFileSelected => 'Аудіофайл не вибрано';

  @override
  String get noZipArchiveSelected => 'ZIP архів не вибрано';

  @override
  String get noFolderConfigured => 'Папка не налаштована';

  @override
  String get missingLyricsTranslations => 'Відсутні тексти/переклади';

  @override
  String missingForSong(Object songName) {
    return 'Для \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Відсутні: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'Що ви хочете зробити?';

  @override
  String get lyricsGeneratedSuccessfully => 'Тексти успішно згенеровані';

  @override
  String get setDeepSeekApiKey => 'Будь ласка, налаштуйте API ключ DeepSeek у налаштуваннях';

  @override
  String failedToOpenSong(Object error) {
    return 'Не вдалося відкрити пісню: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'Також видалити файли LRC та JSON';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Додано до \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Не вдалося додати до плейлисту: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return 'Експортовано $count пісень';
  }

  @override
  String get fileNotFound => 'Файл не знайдено';

  @override
  String get selectZipFileNotJson => 'Будь ласка, виберіть ZIP файл, а не JSON або LRC';

  @override
  String get noFilesFoundInZip => 'Файли не знайдено в ZIP архіві';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Невірний формат ZIP файлу: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Помилка імпорту: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return 'Знайдено $count перекладів';
  }

  @override
  String mp3ImportError(Object error) {
    return 'Помилка імпорту MP3: $error';
  }

  @override
  String get importSongFirstToSearch => 'Спочатку імпортуйте пісню для пошуку текстів';

  @override
  String get lyricsFetched => 'Тексти отримано';

  @override
  String get lyricsFoundUseCreate => 'Тексти знайдено. Використайте для створення синхронізованого LRC файлу';

  @override
  String get deleteSelectedSongs => 'Видалити вибрані пісні';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'Ви впевнені, що хочете видалити $count пісень?';
  }

  @override
  String get songsDeletedSuccessfully => 'Пісні успішно видалено';

  @override
  String get storagePermissionRequired => 'Потрібен дозвіл на доступ до папок.';

  @override
  String get enableStoragePermission => 'Будь ласка, увімкніть дозвіл на зберігання в налаштуваннях.';

  @override
  String get openSettings => 'Відкрити налаштування';

  @override
  String get unableToSelectFolder => 'Не вдалося вибрати папку. Спробуйте альтернативу:';

  @override
  String get selectFilesInstead => 'Вибрати файли замість папки';

  @override
  String get enterFolderPath => 'Будь ласка, введіть шлях до папки';

  @override
  String get folderDoesNotExist => '✗ Папка не існує';

  @override
  String folderSetWithPath(Object path) {
    return 'Папку встановлено: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Помилка встановлення папки: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'Не вдалося вибрати папку текстів. Спробуйте альтернативу:';

  @override
  String get useManualPath => 'Використати ручний шлях (для тестування)';

  @override
  String get enterFolderPathManually => 'Введіть шлях до папки вручну замість використання вибору папки';

  @override
  String get folderPathLabel => 'Шлях до папки';

  @override
  String get folderPathHint => 'Приклад: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Повний шлях до папки з музикою';

  @override
  String get setPath => 'Встановити шлях';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'Вибрати ZIP архів з текстами для \"$title\"';
  }

  @override
  String get skip => 'Пропустити';

  @override
  String get retry => 'Повторити';

  @override
  String get failedToCopyLrcFile => 'Не вдалося скопіювати LRC файл';

  @override
  String copiedJsonFiles(Object count) {
    return 'Скопійовано $count файлів JSON';
  }

  @override
  String get failedToCopyJsonFiles => 'Не вдалося скопіювати файли JSON';

  @override
  String failedToDeleteSong(Object error) {
    return 'Не вдалося видалити пісню: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return 'Додано $count пісень до \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'Додати $count пісень до плейлисту';
  }

  @override
  String get failedToExportSongs => 'Не вдалося експортувати пісні';

  @override
  String get ok => 'ОК';

  @override
  String deleteSongConfirm(Object song) {
    return 'Ви впевнені, що хочете видалити \"$song\"?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Оберіть папку з музикою для цього плейлисту';

  @override
  String get folderLinkedToPlaylist => 'Папку пов\'язано з плейлистом';

  @override
  String get folderUnlinkedFromPlaylist => 'Папку від\'єднано від плейлисту';

  @override
  String get checkFolderAccess => 'Перевірити доступ';

  @override
  String get checkingPermissions => 'Перевірка прав доступу...';

  @override
  String get folderAccessible => '✓ Папка доступна';

  @override
  String get folderNotAccessible => '✗ Папка недоступна';

  @override
  String audioFilesFound(Object count) {
    return 'Знайдено $count аудіо файл(ів)';
  }

  @override
  String lyricsFound(Object count) {
    return 'Знайдено $count файл(ів) з текстом';
  }

  @override
  String get noAudioFiles => 'Аудіо файли не знайдені';

  @override
  String get noLyricsFiles => 'Файли з текстом не знайдені';

  @override
  String errorCheckingAccess(Object error) {
    return 'Помилка перевірки доступу: $error';
  }

  @override
  String get folderPathColon => 'Шлях до папки:';

  @override
  String get permissionsStatus => 'Статус прав доступу:';

  @override
  String get folderContent => 'Зміст папки:';

  @override
  String get accessGranted => '✓ Доступ дозволено';

  @override
  String get accessDenied => '✗ Доступ заборонено';

  @override
  String get permissionRequestFailed => 'Не вдалося запросити дозволи';

  @override
  String get pleaseGrantPermissions => 'Будь ласка, надайте дозволи на доступ до сховища для перевірки папки';

  @override
  String get refreshOnlySongs => 'Тільки пісні';

  @override
  String get refreshEverything => 'Все';

  @override
  String get refreshDialogDescription => 'Що ви хочете оновити? \"Тільки пісні\" прискорює процес, пропускаючи тексти.';

  @override
  String get mostSongs => 'Найбільше пісень';
}
