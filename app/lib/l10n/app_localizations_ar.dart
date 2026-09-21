// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'لينغوتيون';

  @override
  String get library => 'المكتبة';

  @override
  String get playlists => 'قوائم التشغيل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get allSongs => 'جميع الأغاني';

  @override
  String get favorites => 'المفضلة';

  @override
  String get createPlaylist => 'إنشاء قائمة تشغيل';

  @override
  String get playlistName => 'اسم قائمة التشغيل';

  @override
  String get iconOptional => 'الأيقونة (اختياري)';

  @override
  String get cancel => 'إلغاء';

  @override
  String get create => 'إنشاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get save => 'حفظ';

  @override
  String get close => 'إغلاق';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get sort => 'ترتيب';

  @override
  String get addToFavorites => 'إضافة إلى المفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get addToPlaylist => 'إضافة إلى قائمة التشغيل';

  @override
  String get removeFromPlaylist => 'إزالة من قائمة التشغيل';

  @override
  String get addSongsToLibrary => 'إضافة أغاني من المكتبة';

  @override
  String get noSongsToAdd => 'لا توجد أغنية للإضافة';

  @override
  String addButtonText(Object count) {
    return 'إضافة $count';
  }

  @override
  String get selected => 'محددة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get autoScroll => 'التمرير التلقائي';

  @override
  String get autoScrollSubtitle => 'التمرير تلقائيًا إلى السطر الحالي';

  @override
  String get highlightNextLine => 'تمييز السطر التالي';

  @override
  String get highlightNextLineSubtitle => 'إظهار السطر التالي مع تمييز بسيط';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String get scrollOffset => 'إزاحة التمرير';

  @override
  String get scrollOffsetSubtitle => 'المسافة من أعلى الشاشة بالبكسل';

  @override
  String get autoScrollFocusOffset => 'إزاحة تركيز التمرير التلقائي';

  @override
  String get autoScrollFocusOffsetSubtitle => 'موضع التركيز الافتراضي للتمرير التلقائي (افتراضي: +50)';

  @override
  String get defaultTranslationLanguage => 'لغة الترجمة الافتراضية';

  @override
  String get defaultOriginalLanguage => 'اللغة الأصلية الافتراضية';

  @override
  String get russian => 'الروسية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get romanian => 'الرومانية';

  @override
  String get french => 'الفرنسية';

  @override
  String get german => 'الألمانية';

  @override
  String get spanish => 'الإسبانية';

  @override
  String get italian => 'الإيطالية';

  @override
  String get portuguese => 'البرتغالية';

  @override
  String get lyricsFolder => 'مجلد الكلمات';

  @override
  String get useLyricsFolder => 'استخدام مجلد الكلمات';

  @override
  String get useLyricsFolderDisabled => 'معطل - يجب اختيار الملفات مع الصوت';

  @override
  String get setLyricsFolder => 'تعيين مجلد الكلمات';

  @override
  String get selectFolder => 'اختيار مجلد';

  @override
  String get folderPath => 'مسار المجلد';

  @override
  String get examples => 'أمثلة:';

  @override
  String get defaultFolder => 'الافتراضي: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'المجلد الحالي:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'تم تعيين المجلد: $path';
  }

  @override
  String get folderSetFailed => 'المجلد غير موجود أو لا يمكن الوصول إليه';

  @override
  String get resetToDefault => 'إعادة التعيين إلى الافتراضي';

  @override
  String get showCurrentFolder => 'عرض المجلد الحالي';

  @override
  String get changeFolder => 'تغيير المجلد';

  @override
  String get resetToDefaultFolder => 'إعادة تعيين إلى المجلد الافتراضي';

  @override
  String get folderReset => 'إعادة تعيين إلى المجلد الافتراضي';

  @override
  String get clearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get clearCacheSubtitle => 'مسح الملفات المؤقتة';

  @override
  String get cacheCleared => 'تم مسح ذاكرة التخزين المؤقت';

  @override
  String get resetSongLanguages => 'إعادة تعيين لغات الأغاني';

  @override
  String get resetSongLanguagesSubtitle => 'استخدام اللغة الافتراضية من الإعدادات';

  @override
  String get songLanguagesReset => 'تم إعادة تعيين لغات الأغاني';

  @override
  String get about => 'حول';

  @override
  String get translationsLoaded => 'تم تحميل الترجمات بنجاح!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'فشل تحميل الترجمات: $error';
  }

  @override
  String get editTranslations => 'تعديل الترجمات';

  @override
  String get loadTranslationsFromFile => 'تحميل الترجمات من ملف';

  @override
  String get loadTextMenu => 'تحميل النص';

  @override
  String get loadTranslations => 'تحميل الترجمات';

  @override
  String get deleteTranslation => 'حذف الترجمة';

  @override
  String get noFileSelected => 'لم يتم اختيار ملف';

  @override
  String get noLrcFileAssociated => 'لا يوجد ملف LRC مرتبط بهذه الأغنية';

  @override
  String get lrcFileSaved => 'تم حفظ ملف LRC بنجاح!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'فشل حفظ ملف LRC: $error';
  }

  @override
  String get exitEditMode => 'الخروج من وضع التعديل';

  @override
  String get editTimestamps => 'تعديل الطوابع الزمنية';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get language => 'اللغة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noSongsFound => 'لم يتم العثور على أغانٍ';

  @override
  String get noPlaylistsFound => 'لم يتم العثور على قوائم تشغيل';

  @override
  String get selectSong => 'اختر أغنية للتشغيل';

  @override
  String get song => 'أغنية';

  @override
  String get artist => 'الفنان';

  @override
  String get duration => 'المدة';

  @override
  String get actions => 'الإجراءات';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get stop => 'إيقاف';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get rewind10 => '-10 ثانية';

  @override
  String get forward10 => '+10 ثانية';

  @override
  String get repeat => 'تكرار';

  @override
  String get shuffle => 'خلط';

  @override
  String get volume => 'مستوى الصوت';

  @override
  String get speed => 'السرعة';

  @override
  String get lyrics => 'الكلمات';

  @override
  String get translations => 'الترجمات';

  @override
  String get originalText => 'النص الأصلي';

  @override
  String get translatedText => 'النص المترجم';

  @override
  String get showTranscription => 'عرض النسخ الصوتي';

  @override
  String get showTranscriptionSubtitle => 'عرض دليل النطق';

  @override
  String get showTranslationFirst => 'الترجمة أولاً';

  @override
  String get showTranslationFirstSubtitle => 'عرض الترجمة قبل النص الأصلي';

  @override
  String get italianLang => 'الإيطالية';

  @override
  String get portugueseLang => 'البرتغالية';

  @override
  String get lyricsEditor => 'محرر الكلمات';

  @override
  String get addLine => 'إضافة سطر';

  @override
  String get updateLine => 'تحديث السطر';

  @override
  String get deleteLine => 'حذف السطر';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get moveUp => 'تحريك لأعلى';

  @override
  String get moveDown => 'تحريك لأسفل';

  @override
  String get autoSyncLyrics => 'مزامنة الكلمات تلقائياً';

  @override
  String get exportLrc => 'تصدير LRC (الأصلي)';

  @override
  String get exportJson => 'تصدير JSON (الترجمات)';

  @override
  String get markTimestamp => 'تحديد الطابع الزمني (إدخال)';

  @override
  String get original => 'الأصلي';

  @override
  String get translation => 'الترجمة';

  @override
  String get audioFile => 'ملف الصوت';

  @override
  String get songTitle => 'عنوان الأغنية';

  @override
  String get browse => 'تصفح';

  @override
  String get audioControls => 'ضوابط الصوت';

  @override
  String get addEditLine => 'إضافة/تعديل سطر';

  @override
  String get instructions => 'التعليمات';

  @override
  String get lyricsEditorInstructions => 'تعليمات مزامنة LRC:\\n\\n1. اختر ملف صوتي باستخدام زر تصفح\\n2. أدخل عنوان الأغنية والفنان (اختياري)\\n3. اضغط تشغيل لبدء الصوت\\n4. عندما يتم غناء سطر، أدخل النص الأصلي في حقل الأصلي\\n5. اضغط إدخال أو اضغط تحديد الطابع الزمني لتسجيل الوقت\\n6. أضف ترجمة اختيارياً في حقل الترجمة\\n7. كرر الخطوات 4-6 لكل سطر\\n8. استخدم تصدير LRC لحفظ الكلمات الأصلية مع الطوابع الزمنية\\n9. استخدم تصدير JSON لحفظ الترجمات\\n\\nنصائح:\\n- استخدم -10 ثانية/+10 ثانية للتنقل بسرعة في الأغنية\\n- يمكنك إعادة ترتيب الأسطر باستخدام تحريك لأعلى/لأسفل\\n- قم بتحميل ملفات JSON المحفوظة سابقاً لتعديل الترجمات';

  @override
  String get welcome => 'مرحباً';

  @override
  String get welcomeMessage => 'ابدأ رحلة تعلم اللغة بالموسيقى!';

  @override
  String get importSongs => 'استيراد الأغاني';

  @override
  String get importSongsSubtitle => 'إضافة ملفات صوتية من جهازك';

  @override
  String get manageLibrary => 'إدارة المكتبة';

  @override
  String get manageLibrarySubtitle => 'تنظيم أغانك وقوائم التشغيل';

  @override
  String get syncLyrics => 'مزامنة الكلمات';

  @override
  String get syncLyricsSubtitle => 'مزامنة الكلمات مع الصوت تلقائياً';

  @override
  String get languageLearning => 'تعلم اللغة • الموسيقى • الترجمات';

  @override
  String get version => 'الإصدار';

  @override
  String get developer => 'تم التطوير بواسطة';

  @override
  String get website => 'الموقع';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'فشل إنشاء قائمة التشغيل: $error';
  }

  @override
  String get playlistCreated => 'تم إنشاء قائمة التشغيل بنجاح!';

  @override
  String get playlistDeleted => 'تم حذف قائمة التشغيل بنجاح!';

  @override
  String get playlistUpdated => 'تم تحديث قائمة التشغيل بنجاح!';

  @override
  String get songAdded => 'تمت إضافة الأغنية بنجاح!';

  @override
  String get songRemoved => 'تمت إزالة الأغنية بنجاح!';

  @override
  String get songDeleted => 'تم حذف الأغنية بنجاح!';

  @override
  String get error => 'خطأ';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get success => 'نجح';

  @override
  String get confirm => 'تأكيد';

  @override
  String get areYouSure => 'هل أنت متأكد؟';

  @override
  String get unsavedChanges => 'لديك تغييرات غير محفوظة. هل تريد المتابعة؟';

  @override
  String get selectLanguage => 'اختيار اللغة';

  @override
  String get appLanguage => 'لغة التطبيق';

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
  String get welcomeToLingoTune => 'مرحباً بك في LingoTune';

  @override
  String get folderSetupMessage => 'اختر مجلداً لتخزين الكلمات والترجمات (ملفات LRC و JSON). هذا يجعل من السهل تنظيم مكتبة الموسيقى الخاصة بك.';

  @override
  String get selectFolderNow => 'اختيار المجلد الآن';

  @override
  String get goToSettings => 'الذهاب إلى الإعدادات';

  @override
  String get setupLater => 'الإعداد لاحقاً';

  @override
  String get useDefaultFolder => 'استخدام المجلد الافتراضي';

  @override
  String get databaseFound => 'تم العثور على قاعدة بيانات في ملف الاستيراد';

  @override
  String get importDatabaseQuestion => 'هل تريد استيراد قاعدة البيانات أيضاً؟';

  @override
  String get mergeDatabase => 'دمج';

  @override
  String get replaceDatabase => 'استبدال';

  @override
  String get importDatabase => 'استيراد قاعدة البيانات';

  @override
  String get skipDatabase => 'تخطي قاعدة البيانات';

  @override
  String get mergeDatabaseDescription => 'دمج الأغاني المستوردة مع مكتبتك (إضافة عناصر جديدة فقط)';

  @override
  String get replaceDatabaseDescription => 'استبدال مكتبتك بالكامل بقاعدة البيانات المستوردة (ستفقد جميع البيانات الموجودة)';

  @override
  String get exporting => 'جاري التصدير...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'جاري تصدير $current من أصل $total أغنية';
  }

  @override
  String get exportDatabaseIncluded => 'قاعدة البيانات مضمنة في التصدير';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'تم استيراد $fileCount ملف (ملفات) وقاعدة بيانات';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'تم استيراد $fileCount ملف (ملفات)';
  }

  @override
  String get chinese => 'الصينية';

  @override
  String get arabic => 'العربية';

  @override
  String get colorTheme => 'سمة اللون';

  @override
  String get themeNameAmethyst => 'جمشت';

  @override
  String get themeColorPurple => 'بنفسجي';

  @override
  String get themeColorBlue => 'أزرق';

  @override
  String get themeColorGreen => 'أخضر';

  @override
  String get themeColorOrange => 'برتقالي';

  @override
  String get themeColorRed => 'أحمر';

  @override
  String get themeColorPink => 'وردي';

  @override
  String get themeColorDeepOrange => 'برتقالي داكن';

  @override
  String get themeColorDarkRed => 'أحمر داكن';

  @override
  String get themeColorTeal => 'تيل';

  @override
  String get themeColorCyan => 'سماوي';

  @override
  String get themeColorAmber => 'عنبري';

  @override
  String get themeColorLime => 'ليموني';

  @override
  String get ukrainianLang => 'الأوكرانية';

  @override
  String get font => 'الخط';

  @override
  String get fontSettings => 'إعدادات الخط';

  @override
  String get systemFont => 'النظام';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'حجم النص الرئيسي';

  @override
  String get mainTextBold => 'النص الرئيسي عريض';

  @override
  String get translationSize => 'حجم الترجمة';

  @override
  String get translationBold => 'الترجمة عريضة';

  @override
  String get transcriptSize => 'حجم النسخ';

  @override
  String get transcriptBold => 'النسخ عريض';

  @override
  String get defaultStartScreen => 'شاشة البداية الافتراضية';

  @override
  String get defaultStartScreenSubtitle => 'الشاشة التي تعرض عند بدء التطبيق';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'إضافة إلى المكتبة عند الإضافة إلى قائمة التشغيل';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'إضافة الأغاني تلقائياً إلى المكتبة عند إضافتها إلى قائمة تشغيل';

  @override
  String get serviceMessages => 'رسائل الخدمة';

  @override
  String get serviceMessagesSubtitle => 'إظهار إشعارات الخدمة حول الترجمة والنسخ';

  @override
  String get serviceData => 'بيانات الخدمة';

  @override
  String get serviceDataSubtitle => 'إظهار تراكب التشخيص في وضع الدراسة';

  @override
  String get ttsEngine => 'محرك TTS';

  @override
  String get ttsEngineSubtitle => 'لم يتم العثور على محركات TTS — قد لا يرى التطبيق محركات النطق الخاصة بالنظام.';

  @override
  String get ttsEngineAuto => 'تلقائي (موصى به)';

  @override
  String get ttsEngineReloadHint => 'تم تغيير المحرك — يسري عند بدء وضع الدراسة التالي';

  @override
  String get includeMp3Files => 'تضمين ملفات MP3';

  @override
  String get includeMp3FilesSubtitle => 'سؤدي هذا إلى زيادة حجم الأرشيف';

  @override
  String get importMp3Files => 'استيراد ملفات MP3';

  @override
  String get importMp3FilesSubtitle => 'إضافة ملفات الموسيقى إلى المكتبة';

  @override
  String get exportSongs => 'تصدير الأغاني';

  @override
  String get import => 'استيراد';

  @override
  String get addMultiple => 'تحديد متعدد';

  @override
  String get addToPlaylistShort => 'إضافة';

  @override
  String get deleteShort => 'حذف';

  @override
  String get selectAllShort => 'الكل';

  @override
  String get deselectAllShort => 'مسح';

  @override
  String get exitSelectionMode => 'الخروج من وضع التحديد';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String get deleteSelected => 'حذف المحدد';

  @override
  String get addMultipleToPlaylist => 'إضافة إلى قائمة التشغيل';

  @override
  String get coverArt => 'صورة الغلاف';

  @override
  String get playlistCover => 'غلاف قائمة التشغيل';

  @override
  String get selectFromGallery => 'اختيار من المعرض';

  @override
  String get removeCover => 'إزالة الغلاف';

  @override
  String get coverUpdated => 'تم تحديث الغلاف';

  @override
  String get coverRemoved => 'تم إزالة الغلاف';

  @override
  String errorWithMessage(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get importFolders => 'استيراد المجلدات';

  @override
  String get selectMusicFolder => 'اختيار مجلد الموسيقى';

  @override
  String get folderWithAudioFiles => 'مجلد يحتوي على ملفات MP3/WAV';

  @override
  String get sameFolderForLyrics => 'نفس المجلد لكلمات الأغاني';

  @override
  String get selectLyricsFolder => 'اختيار مجلد كلمات الأغاني';

  @override
  String get folderWithLyricsFiles => 'مجلد يحتوي على ملفات LRC/JSON (اختياري)';

  @override
  String get pleaseEnterPlaylistName => 'الرجاء إدخال اسم قائمة التشغيل';

  @override
  String get pleaseSelectMusicFolder => 'الرجاء اختيار مجلد موسيقى';

  @override
  String get cropImage => 'قص الصورة';

  @override
  String get photoPermissionRequired => 'يتطلب إذن الوصول للصور';

  @override
  String get photoPermissionDenied => 'تم رفض الوصول للصور';

  @override
  String get imageProcessingError => 'فشل معالجة الصورة';

  @override
  String get scanningFolder => 'جاري المسح...';

  @override
  String get importingFiles => 'جاري الاستيراد...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'جاري الاستيراد $current/$total ملفات... تم العثور على $songs أغنية';
  }

  @override
  String processingFile(Object file) {
    return 'جاري المعالجة $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'إضافة إلى قائمة التشغيل';

  @override
  String addedToPlaylist(Object playlist) {
    return 'تمت الإضافة إلى \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'فشل الإضافة إلى قائمة التشغيل: $error';
  }

  @override
  String get deleteSong => 'حذف';

  @override
  String get importSongDialogTitle => 'استيراد أغنية';

  @override
  String get audioOnly => 'صوت فقط';

  @override
  String get addLyricsLater => 'سأضيف الكلمات لاحقًا';

  @override
  String get audioWithLyricsZIP => 'صوت + أرشيف ZIP بالكلمات';

  @override
  String get importWithAllTranslations => 'استيراد مع جميع الترجمات';

  @override
  String get importTranslationDialogTitle => 'إضافة ترجمة';

  @override
  String get loadTranslationFromZip => 'تحميل من أرشيف ZIP';

  @override
  String get loadTranslationFromJson => 'تحميل من ملف JSON';

  @override
  String get noAudioFilesSelected => 'لم يتم تحديد أي ملف صوتي';

  @override
  String failedToImportSongs(Object error) {
    return 'فشل استيراد الأغاني: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'فشل استيراد الأغنية: $error';
  }

  @override
  String get musicFolderNotSelected => 'لم يتم تحديد مجلد الموسيقى';

  @override
  String get generateLyrics => 'إنشاء كلمات';

  @override
  String get selectTextFileOrEnterText => 'اختيار ملف نص أو إدخال نص';

  @override
  String get originalLanguage => 'اللغة الأصلية';

  @override
  String get translationLanguages => 'لغات الترجمة';

  @override
  String get startMinuteForTimestamps => 'دقيقة البداية للطوابع الزمنية';

  @override
  String get transcriptionLanguage => 'لغة النسخ';

  @override
  String get generating => 'جاري الإنشاء...';

  @override
  String get generate => 'إنشاء';

  @override
  String get deepseekApiKey => 'مفتاح API DeepSeek';

  @override
  String get validateKey => 'التحقق من المفتاح';

  @override
  String get keyIsValid => 'المفتاح صحيح';

  @override
  String get keyIsInvalid => 'المفتاح غير صحيح';

  @override
  String get lyricsGenerationSuccess => 'تم إنشاء الكلمات بنجاح';

  @override
  String get lyricsGenerationError => 'فشل إنشاء الكلمات';

  @override
  String get savingFiles => 'جاري حفظ الملفات...';

  @override
  String get enterText => 'إدخال نص';

  @override
  String get transcript => 'نسخ';

  @override
  String get originalTextEditable => 'النص الأصلي (قابل للتعديل)';

  @override
  String get selectLanguageToEdit => 'اختر اللغة للتعديل';

  @override
  String get moveLineUp => 'نقل السطر للأعلى';

  @override
  String get moveLineDown => 'نقل السطر للأسفل';

  @override
  String get moveAllTranslationsUp => 'نقل جميع الترجمات للأعلى';

  @override
  String get moveAllTranslationsDown => 'نقل جميع الترجمات للأسفل';

  @override
  String get translationSaved => 'تم حفظ الترجمة!';

  @override
  String get translationSaveFailed => 'فشل حفظ الترجمة';

  @override
  String get loadTextTitle => 'تحميل النص';

  @override
  String get noOriginalTextWarning => 'يرجى تحميل النص الأصلي أولاً';

  @override
  String get selectLanguageOriginal => 'اللغة الأصلية';

  @override
  String get startTimestampMinutes => 'بداية الطابع الزمني (دقائق)';

  @override
  String get selectLanguageTranslation => 'لغة الترجمة';

  @override
  String get originalTextLoaded => 'تم تحميل النص الأصلي بنجاح!';

  @override
  String get translationLoaded => 'تم تحميل الترجمة بنجاح!';

  @override
  String get transcriptLoaded => 'تم تحميل النسخ بنجاح!';

  @override
  String get selectTranslationLanguage => 'لغة الترجمة للنسخ';

  @override
  String get noTranslationWarning => 'لم يتم تحميل أي ترجمة';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'عدم تطابق الأسطر: $loaded سطر، متوقع $expected';
  }

  @override
  String get loadTextTooltip => 'تحميل نص أو ترجمة';

  @override
  String get loadFromFile => 'التحميل من ملف';

  @override
  String get pasteFromClipboard => 'اللصق من الحافظة';

  @override
  String get audioNotificationService => 'خدمة الإشعارات الصوتية';

  @override
  String get audioNotificationServiceActive => 'الحالة: ✅ نشط';

  @override
  String get audioNotificationServiceError => 'الحالة: ❌ خطأ';

  @override
  String get errorLabel => 'خطأ:';

  @override
  String get audioNotificationServiceDescription => 'توفير هذه الخدمة إشعارات عند تصغير التطبيق';

  @override
  String get reorder => 'إعادة ترتيب';

  @override
  String get done => 'تم';

  @override
  String get selectMultiple => 'تحديد متعدد';

  @override
  String get sortSongs => 'ترتيب الأغاني';

  @override
  String get importSong => 'استيراد أغنية';

  @override
  String get sortDefault => 'افتراضي';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'الأحدث';

  @override
  String get sortDateAsc => 'الأقدم';

  @override
  String get importingSongs => 'استيراد الأغاني...';

  @override
  String get noSongsInPlaylist => 'لا توجد أغانٍ في هذه القائمة';

  @override
  String get addSongsFromLibraryHint => 'أضف أغانٍ من مكتبتك';

  @override
  String get removedSongsFromPlaylist => 'تمت إزالة الأغاني من قائمة التشغيل';

  @override
  String failedToRemoveSongs(Object error) {
    return 'فشل حذف الأغاني: $error';
  }

  @override
  String get deletePlaylistTitle => 'حذف قائمة التشغيل';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'هل أنت متأكد من حذف \"$playlist\"؟';
  }

  @override
  String get failedToDeletePlaylist => 'فشل حذف قائمة التشغيل:';

  @override
  String get specifyTranslationLanguage => 'تحديد لغة الترجمة';

  @override
  String get languageNameLabel => 'اسم اللغة';

  @override
  String get languageNameHint => 'مثال: الروسية، للمؤلف، الشعري';

  @override
  String get translationTypeLabel => 'نوع الترجمة:';

  @override
  String get translationTypeNormal => 'عادي';

  @override
  String get translationTypeAuthor => 'للمؤلف';

  @override
  String get translationTypePoetic => 'شعري';

  @override
  String get translationTypeLiteral => 'حرفي';

  @override
  String mp3FilesCount(Object count) {
    return 'ملفات MP3: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return 'تم استيراد $count ملف (تم تخطي قاعدة البيانات)';
  }

  @override
  String get databaseMerged => 'تم دمج قاعدة البيانات';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'تم دمج قاعدة البيانات، ملفات MP3: $count';
  }

  @override
  String get databaseReplaced => 'تم استبدال قاعدة البيانات';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'تم استبدال قاعدة البيانات، ملفات MP3: $count';
  }

  @override
  String get confirmReplaceDatabase => 'تأكيد الاستبدال';

  @override
  String get confirmReplaceDatabaseWarning => 'هل أنت متأكد؟ ستفقد جميع الأغاني وقوائم التشغيل الموجودة!';

  @override
  String get replaceAll => 'استبدال الكل';

  @override
  String get selectLanguages => 'اختيار اللغات';

  @override
  String selectedLanguagesCount(Object count) {
    return 'محدد: $count لغات';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'محدد: $count';
  }

  @override
  String get promptPreset => 'مسبق للمطالبة';

  @override
  String get balanced => 'متوازن';

  @override
  String get poetic => 'شعري';

  @override
  String get literal => 'حرفي';

  @override
  String get customPromptOption => 'مخصص...';

  @override
  String get editPrompt => 'تعديل المطالبة';

  @override
  String get notSet => 'لم يتم التعيين';

  @override
  String get showOrEditApiKey => 'عرض/تعديل مفتاح API';

  @override
  String get timeout => 'مهلة';

  @override
  String get model => 'النموذج';

  @override
  String get resetToPreset => 'إعادة تعيين إلى مسبق';

  @override
  String get customPrompt => 'مطالبة مخصصة';

  @override
  String customPromptChars(Object count) {
    return 'مطالبة مخصصة ($count أحرف)';
  }

  @override
  String usingPreset(Object preset) {
    return 'استخدام مسبق: $preset';
  }

  @override
  String get characters => 'أحرف';

  @override
  String get deepSeekPromptTitle => 'مطالبة DeepSeek';

  @override
  String get customPromptLabel => 'مطالبة مخصصة';

  @override
  String get leaveEmptyToUseDefault => 'اتركه فارغاً لاستخدام المطالبة الافتراضية';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'اتركه فارغاً لاستخدام المطالبة الافتراضية المدمجة في التطبيق';

  @override
  String get apiKeySaved => 'تم حفظ مفتاح API';

  @override
  String get enterTimeout => 'أدخل المهلة بالثواني';

  @override
  String get validTimeoutRange => 'الرجاء إدخال مهلة صالحة (1-3600 ثانية)';

  @override
  String get customTimeout => 'مهلة مخصصة';

  @override
  String get timeoutSeconds => 'مهلة (ثواني)';

  @override
  String timeoutSetTo(Object value) {
    return 'تم تعيين المهلة على $value ثانية';
  }

  @override
  String get customModel => 'نموذج مخصص';

  @override
  String get modelName => 'اسم النموذج';

  @override
  String get enterModelName => 'أدخل اسم النموذج الدقيق كما توفره DeepSeek API';

  @override
  String get pleaseEnterModelName => 'الرجاء إدخال اسم النموذج';

  @override
  String modelSetTo(Object value) {
    return 'تم تعيين النموذج على $value';
  }

  @override
  String get editCustomPrompt => 'تعديل المطالبة المخصصة';

  @override
  String get editPresetPrompt => 'تعديل المطالبة المسبقة';

  @override
  String get editingPreset => 'تعديل مسبق';

  @override
  String get anyChangesSaveAsCustom => 'سيتم حفظ أي تغييرات كمطالبة مخصصة. استخدم زر \'إعادة التعيين\' لاستعادة المسبق الأصلي.';

  @override
  String get useResetToRestorePreset => 'استخدم زر \'إعادة التعيين\' لاستعادة المسبق الأصلي';

  @override
  String get prompt => 'المطالبة';

  @override
  String get promptSaved => 'تم حفظ المطالبة';

  @override
  String get usingPresetPrompt => 'استخدام مطالبة مسبقة';

  @override
  String get apiKeyHint => 'مفتاح API';

  @override
  String get modelHint => 'مثال: deepseek-v3';

  @override
  String get enterExactModelName => 'أدخل اسم النموذج الدقيق كما توفره DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'الرجاء إدخال مفتاح API أولاً';

  @override
  String get maxTokensRegular => 'Max Tokens (عادي)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'حد الرموز لطلبات الترجمة العادية';

  @override
  String get maxTokensJsonHint => 'حد الرموز لطلبات التوليد الكاملة (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'تم تعيين Max tokens (عادي) على $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'تم تعيين Max tokens (JSON) على $value';
  }

  @override
  String get refreshFolder => 'تحديث المجلد';

  @override
  String get refreshingFolder => 'جاري تحديث المجلد...';

  @override
  String get playlistCreatedWithLink => 'تم إنشاء القائمة! اضغط \"تحديث\" لتحميل الأغاني من المجلد';

  @override
  String refreshedPlaylist(Object count) {
    return 'تم التحديث: $count أغنية';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'خطأ في التحديث: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'فشل تحميل الأغاني: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'مجلد الموسيقى غير موجود';

  @override
  String successfullyImportedSongs(Object count) {
    return 'تم استيراد $count أغنية بنجاح';
  }

  @override
  String get noAudioFileSelected => 'لم يتم تحديد ملف صوتي';

  @override
  String get noZipArchiveSelected => 'لم يتم تحديد أرشيف ZIP';

  @override
  String get noFolderConfigured => 'المجلد غير مكون';

  @override
  String get missingLyricsTranslations => 'كلمات الأغاني/الترجمات مفقودة';

  @override
  String missingForSong(Object songName) {
    return 'لـ \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'مفقودة: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'ماذا تريد أن تفعل؟';

  @override
  String get lyricsGeneratedSuccessfully => 'تم إنشاء كلمات الأغاني بنجاح';

  @override
  String get setDeepSeekApiKey => 'يرجى تكوين مفتاح API DeepSeek في الإعدادات';

  @override
  String failedToOpenSong(Object error) {
    return 'فشل فتح الأغنية: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'حذف ملفات LRC و JSON أيضًا';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'تمت الإضافة إلى \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'فشل الإضافة إلى قائمة التشغيل: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return 'تم تصدير $count أغنية';
  }

  @override
  String get fileNotFound => 'الملف غير موجود';

  @override
  String get selectZipFileNotJson => 'يرجى تحديد ملف ZIP، ليس JSON أو LRC';

  @override
  String get noFilesFoundInZip => 'لم يتم العثور على ملفات في ZIP';

  @override
  String invalidZipFileFormat(Object error) {
    return 'تنسيق ملف ZIP غير صالح: $error';
  }

  @override
  String importFailed(Object error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return 'تم العثور على $count ترجمة';
  }

  @override
  String mp3ImportError(Object error) {
    return 'خطأ استيراد MP3: $error';
  }

  @override
  String get importSongFirstToSearch => 'استورد أغنية أولاً للبحث عن كلمات الأغاني';

  @override
  String get lyricsFetched => 'تم جلب كلمات الأغاني';

  @override
  String get lyricsFoundUseCreate => 'تم العثور على كلمات الأغاني! استخدم لإنشاء ملف LRC متزامن';

  @override
  String get deleteSelectedSongs => 'حذف الأغاني المحددة';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'هل أنت متأكد من حذف $count أغنية؟';
  }

  @override
  String get songsDeletedSuccessfully => 'تم حذف الأغاني بنجاح';

  @override
  String get storagePermissionRequired => 'مطلوب إذن التخزين للوصول إلى المجلدات.';

  @override
  String get enableStoragePermission => 'يرجى تمكين إذن التخزين في إعدادات التطبيق.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get unableToSelectFolder => 'غير قادر على تحديد المجلد. جرب البديل:';

  @override
  String get selectFilesInstead => 'تحديد الملفات بدلاً من ذلك';

  @override
  String get enterFolderPath => 'يرجى إدخال مسار المجلد';

  @override
  String get folderDoesNotExist => '✗ المجلد غير موجود';

  @override
  String folderSetWithPath(Object path) {
    return 'تم تعيين المجلد: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'خطأ في تعيين المجلد: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'غير قادر على تحديد مجلد الكلمات. جرب البديل:';

  @override
  String get useManualPath => 'استخدام المسار اليدوي (للاختبار)';

  @override
  String get enterFolderPathManually => 'أدخل مسار المجلد يدويًا بدلاً من استخدام منتقي المجلد';

  @override
  String get folderPathLabel => 'مسار المجلد';

  @override
  String get folderPathHint => 'مثال: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'المسار الكامل لمجلد الموسيقى الخاص بك';

  @override
  String get setPath => 'تعيين المسار';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'تحديد أرشيف ZIP مع كلمات الأغاني لـ \"$title\"';
  }

  @override
  String get skip => 'تخطي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get failedToCopyLrcFile => 'فشل نسخ ملف LRC';

  @override
  String copiedJsonFiles(Object count) {
    return 'تم نسخ $count ملف JSON';
  }

  @override
  String get failedToCopyJsonFiles => 'فشل نسخ ملفات JSON';

  @override
  String failedToDeleteSong(Object error) {
    return 'فشل حذف الأغنية: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return 'تمت إضافة $count أغنية إلى \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'إضافة $count أغنية إلى قائمة التشغيل';
  }

  @override
  String get failedToExportSongs => 'فشل تصدير الأغاني';

  @override
  String get ok => 'موافق';

  @override
  String deleteSongConfirm(Object song) {
    return 'هل أنت متأكد من حذف \"$song\"؟';
  }

  @override
  String get selectMusicFolderForPlaylist => 'اختر مجلد الموسيقى لهذه القائمة';

  @override
  String get folderLinkedToPlaylist => 'تم ربط المجلد بقائمة التشغيل';

  @override
  String get folderUnlinkedFromPlaylist => 'تم إلغاء ربط المجلد من قائمة التشغيل';

  @override
  String get checkFolderAccess => 'التحقق من الوصول';

  @override
  String get checkingPermissions => 'جاري التحقق من الأذونات...';

  @override
  String get folderAccessible => '✓ المجلد متاح';

  @override
  String get folderNotAccessible => '✗ المجلد غير متاح';

  @override
  String audioFilesFound(Object count) {
    return 'تم العثور على $count ملف(ات) صوتي';
  }

  @override
  String lyricsFound(Object count) {
    return 'تم العثور على $count ملف(ات) كلمات';
  }

  @override
  String get noAudioFiles => 'لم يتم العثور على ملفات صوتية';

  @override
  String get noLyricsFiles => 'لم يتم العثور على ملفات كلمات';

  @override
  String errorCheckingAccess(Object error) {
    return 'خطأ في التحقق من الوصول: $error';
  }

  @override
  String get folderPathColon => 'مسار المجلد:';

  @override
  String get permissionsStatus => 'حالة الأذونات:';

  @override
  String get folderContent => 'محتوى المجلد:';

  @override
  String get accessGranted => '✓ تم منح الوصول';

  @override
  String get accessDenied => '✗ تم رفض الوصول';

  @override
  String get permissionRequestFailed => 'فشل طلب الأذونات';

  @override
  String get pleaseGrantPermissions => 'يرجى منح أذونات التخزين للتحقق من المجلد';

  @override
  String get refreshOnlySongs => 'الأغاني فقط';

  @override
  String get refreshEverything => 'كل شيء';

  @override
  String get refreshDialogDescription => 'ماذا تريد تحديثه؟ \"الأغاني فقط\" يسرع العملية عن طريق تخطي الكلمات.';

  @override
  String get mostSongs => 'معظم الأغاني';

  @override
  String get playlistPlay => 'قائمة التشغيل';

  @override
  String get musicNote => 'نغمة موسيقية';

  @override
  String get favorite => 'المفضلة';

  @override
  String get libraryMusic => 'المكتبة';

  @override
  String get tapToSelectFolder => 'اضغط لاختيار مجلد به ملفات صوتية';

  @override
  String get showVerticalSlider => 'شريط تمرير عمودي';

  @override
  String get showVerticalSliderSubtitle => 'عرض شريط التمرير العمودي في المشغل';

  @override
  String get transcriptionEnabled => 'النسخ ممكّن';

  @override
  String get transcriptionDisabled => 'النسخ معطّل';

  @override
  String languageSelected(String language) {
    return 'اللغة المختارة: $language';
  }

  @override
  String get noTranslationsScanning => 'لم يتم العثور على ترجمات، جاري فحص المجلد...';

  @override
  String translationsLoadedCount(int count) {
    return 'تم تحميل الترجمات: $count';
  }

  @override
  String get translationsNotFound => 'لم يتم العثور على ترجمات لهذه الأغنية';

  @override
  String errorLoadingTranslations(String error) {
    return 'خطأ في تحميل الترجمات: $error';
  }

  @override
  String languageNotAvailable(String settingLang, String availableLang) {
    return '$settingLang محدد ولكنه غير متاح. فتح: $availableLang';
  }

  @override
  String get errorAudioService => 'خطأ في خدمة الصوت';

  @override
  String get audioServiceFailed => 'فشل تهيئة تشغيل الصوت في الخلفية.';

  @override
  String get notificationMayNotAppear => 'قد لا تظهر إشعارات المشغل.';

  @override
  String get lrcAndTranslationsSaved => 'تم حفظ LRC وجميع الترجمات!';

  @override
  String translationDeleted(String name) {
    return 'تم حذف الترجمة \"$name\"';
  }

  @override
  String failedToDeleteTranslation(String error) {
    return 'فشل حذف الترجمة: $error';
  }

  @override
  String get generatingTranslations => 'جاري إنشاء الترجمات';

  @override
  String get generatingProcessing => 'المعالجة:';

  @override
  String get generatingLines => 'الأسطر:';

  @override
  String generatingLinesOf(int current, int total) {
    return '$current من $total';
  }

  @override
  String generatingErrors(int count) {
    return 'الأخطاء: $count';
  }

  @override
  String selectedLanguagesCountGen(int count) {
    return 'المحدد: $count';
  }

  @override
  String get transcriptionSection => 'النسخ';

  @override
  String get translationsSection => 'الترجمات';

  @override
  String get translationLoadedSuccess => 'تم تحميل الترجمة بنجاح!';

  @override
  String get exportSuccessful => 'تم التصدير بنجاح!';

  @override
  String get failedToExportSong => 'فشل تصدير الأغنية';

  @override
  String get deleteTranslationTitle => 'حذف الترجمة';

  @override
  String deleteTranslationConfirm(String name) {
    return 'هل تريد حذف ترجمة \"$name\"؟';
  }

  @override
  String get lrcLoaded => 'تم تحميل ملف LRC';

  @override
  String get noFilesLoaded => 'لم يتم العثور على ملفات في الأرشيف';

  @override
  String failedToProcessArchive(String error) {
    return 'فشل معالجة الأرشيف: $error';
  }

  @override
  String failedToLoadTranslationsShort(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get noFolderConfiguredMsg => 'لم يتم تكوين مجلد';

  @override
  String failedToPlaySongMsg(String error) {
    return 'فشل التشغيل: $error';
  }

  @override
  String addedSongsToPlaylistMsg(int count, String playlist) {
    return 'تمت إضافة $count أغنية/أغاني إلى \"$playlist\"';
  }

  @override
  String failedToAddSongsMsg(String error) {
    return 'فشل الإضافة: $error';
  }

  @override
  String addSongsButton(int count) {
    return 'إضافة $count';
  }

  @override
  String get removeSong => 'إزالة';

  @override
  String failedToRemoveSongMsg(String error) {
    return 'فشل الإزالة: $error';
  }

  @override
  String failedToReorderSongsMsg(String error) {
    return 'فشل إعادة الترتيب: $error';
  }

  @override
  String failedToLoadSongsMsg(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String errorLoadingText(String error) {
    return 'خطأ في تحميل النص: $error';
  }

  @override
  String lrcAndTranslationsLoaded(int count) {
    return 'تم تحميل LRC و$count ترجمة/ترجمات';
  }

  @override
  String translationsOnlyLoaded(int count) {
    return 'تم تحميل $count ترجمة/ترجمات';
  }

  @override
  String get pleaseSetDeepSeekApiKey => 'يرجى تعيين مفتاح DeepSeek API في الإعدادات';

  @override
  String get lyricsGeneratedSuccessfullyMsg => 'تم إنشاء الكلمات بنجاح';

  @override
  String exportShareSubject(String title) {
    return 'تصدير LingoTune: $title مع الكلمات والترجمات';
  }

  @override
  String get timestampOffset => 'إزاحة الطوابع الزمنية';

  @override
  String get timestampOffsetSubtitle => 'الإزاحة الافتراضية بالدقائق للطوابع الزمنية المُنشأة';

  @override
  String get resetTimestamps => 'إعادة تعيين الطوابع الزمنية';

  @override
  String get resetTimestampsConfirm => 'إعادة تعيين جميع الطوابع الزمنية إلى القيم الافتراضية؟';

  @override
  String get resetTimestampsSuccess => 'تم إعادة تعيين الطوابع الزمنية';

  @override
  String get saveAfterReset => 'حفظ التغييرات';

  @override
  String get saveAfterResetConfirm => 'حفظ التغييرات بعد إعادة التعيين؟';

  @override
  String get repeatOff => 'إيقاف التكرار';

  @override
  String get repeatAll => 'تكرار الكل';

  @override
  String get repeatOne => 'تكرار واحد';

  @override
  String get repeatAllPlaylists => 'تكرار جميع قوائم التشغيل';

  @override
  String get playFavoritesOnly => 'تشغيل المفضلة فقط';

  @override
  String get noFavoriteSongs => 'لا توجد أغاني مفضلة بعد';

  @override
  String get playbackSpeed => 'سرعة التشغيل';

  @override
  String get speedNormal => 'عادي';

  @override
  String get lyricsPositionOffset => 'تأخير مزامنة الكلمات';

  @override
  String get lyricsPositionOffsetSubtitle => 'تأخير التمييز بالثواني (زده إذا كان التمييز يسبق)';

  @override
  String get studyMode => 'دراسة';

  @override
  String get studyModeTooltip => 'وضع الدراسة: قراءة الترجمة ثم تشغيل كل سطر';

  @override
  String get studyModeStarted => 'بدأ وضع الدراسة';

  @override
  String get studyModeStartedNoVoice => 'بدأ وضع الدراسة (الأجزاء فقط — بدون صوت)';

  @override
  String get ttsLangMissingTitle => 'لا يوجد صوت لهذه اللغة';

  @override
  String get ttsLangMissingBody => 'جهازك لا يحتوي على صوت TTS مثبت للغة الترجمة. ثبّت محرك TTS يدعم هذه اللغة (مثل Google أو Yandex) من الإعدادات → تحويل النص إلى كلام، أو تابع في وضع الأجزاء فقط (بدون تعليق صوتي).';

  @override
  String get ttsContinueNoVoice => 'متابعة بدون صوت';

  @override
  String get studyModeStopped => 'تم إيقاف وضع الدراسة';

  @override
  String get studyModeNoLyrics => 'لا توجد كلمات متزامنة لهذه الأغنية';

  @override
  String get studyModeSettings => 'إعدادات وضع الدراسة';

  @override
  String get studyPerSongOverride => 'إعدادات مخصصة لهذه الأغنية';

  @override
  String get studyPerSongOverrideSubtitle => 'عند الإيقاف، تُستخدم الإعدادات العامة للتطبيق';

  @override
  String get studyModeOrder => 'الترتيب';

  @override
  String get studyModeOrderTranslationFirst => 'الترجمة أولاً';

  @override
  String get studyModeOrderOriginalFirst => 'الأصل أولاً';

  @override
  String get studyModeOrderOverlay => 'متداخل (الأصل منخفض)';

  @override
  String get studyModeSpeechRate => 'سرعة الكلام';

  @override
  String get studyModeSpeechVolume => 'مستوى صوت الكلام';

  @override
  String get studyModeLongPressHint => 'اضغط مطولاً للإعدادات';

  @override
  String get exportCurrentSong => 'تصدير الأغنية';

  @override
  String get studyModeOverlayTiming => 'متى يتحدث';

  @override
  String get studyModeOverlayAtStart => 'في بداية السطر';

  @override
  String get studyModeOverlayAtEnd => 'في نهاية السطر';

  @override
  String get studyModeOverlayAtBoth => 'البداية والنهاية';

  @override
  String get studyModeDuckVolume => 'مستوى صوت الأصل';

  @override
  String get studyModeTtsOffset => 'إزاحة توقيت الصوت';

  @override
  String get studyModeTtsOffsetHint => 'سالب — أبكر، موجب — متأخر (ث). وضع التراكب فقط';

  @override
  String get studyModeOpenSettings => 'إعدادات وضع الدراسة';

  @override
  String get carDetectionTitle => 'كشف السيارات';

  @override
  String get carDetectionEnabled => 'مفعّل';

  @override
  String get carDetectionDisabled => 'غير مفعّل';

  @override
  String get carDetectionSensitivity => 'الحساسية';

  @override
  String get carDetectionSensitivityHint => 'أعلى = تنبيهات أكثر (قد تسبب إنذارات كاذبة). أقل = إشارات قوية فقط.';

  @override
  String get carAlertSound => 'تنبيه صوتي';

  @override
  String get carAlertSoundSubtitle => 'صفير فوق الموسيقى';

  @override
  String get carAlertVibration => 'تنبيه بالاهتزاز';

  @override
  String get carAlertVibrationSubtitle => 'اهتزاز عند الكشف';

  @override
  String get carAlertVoice => 'تنبيه صوتي بالكلام';

  @override
  String get carAlertVoiceSubtitle => 'تحذير منطوق عبر TTS';

  @override
  String get carDetectionPrivacyNote => 'يتم تحليل الصوت على الجهاز فقط — لا يتم تسجيل أو إرسال أي شيء.';

  @override
  String get carDetectionTooltip => 'كشف السيارات عبر الميكروفون';

  @override
  String get carDetectionStarted => 'بدأ كشف السيارات — أستمع للمركبات';

  @override
  String get carDetectionMicDenied => 'تم رفض إذن الميكروفون — لا يمكن الكشف';

  @override
  String get carCalibrationTitle => 'معايرة الكاشف';

  @override
  String get carCalibrationSubtitle => 'درّب الكاشف على أصواتك';

  @override
  String get carCalibrationMicDenied => 'تم رفض الميكروفون — لا يمكن المعايرة';

  @override
  String get carCalibrationLive => 'الطيف المباشر';

  @override
  String get carCalibrationModeClassify => 'الوضع: تصنيف';

  @override
  String get carCalibrationModeThreshold => 'الوضع: عتبة';

  @override
  String carCalibrationNearest(String cls, String dist) {
    return 'الأقرب: $cls (d=$dist)';
  }

  @override
  String get carCalibrationNoMatch => 'لا تطابق';

  @override
  String carCalibrationThresholdScore(String score) {
    return 'النتيجة: $score';
  }

  @override
  String get carCalibrationRecordTitle => 'تسجيل عينة';

  @override
  String get carCalibrationClass => 'الفئة';

  @override
  String get carCalibrationName => 'اسم العينة';

  @override
  String get carCalibrationRecord => 'تسجيل 5 ثوانٍ';

  @override
  String carCalibrationRecording(int s) {
    return 'جارٍ التسجيل... $sث';
  }

  @override
  String carCalibrationProfilesCount(int n) {
    return 'الملفات الشخصية ($n)';
  }

  @override
  String get carCalibrationEmpty => 'لا توجد عينات — سجل الأولى';

  @override
  String get carCalibrationDelete => 'حذف';

  @override
  String carCalibrationDeleteConfirm(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get carCalibrationReset => 'إعادة تعيين الكل';

  @override
  String get carCalibrationResetConfirm => 'حذف جميع ملفات المعايرة؟';

  @override
  String get carCalibrationCancel => 'إلغاء';

  @override
  String get carCalibrationConfirm => 'حذف';

  @override
  String get carCalibrationLoadDemo => 'تحميل ملفات تجريبية';

  @override
  String get carCalibrationDemoPrefix => 'تجريبي';

  @override
  String carCalibrationDemoLoaded(int n) {
    return 'تم تحميل $n ملفات تجريبية';
  }

  @override
  String get profileClassCarClose => 'سيارة قريبة';

  @override
  String get profileClassCarFar => 'سيارة بعيدة';

  @override
  String get profileClassCarTruck => 'شاحنة';

  @override
  String get profileClassCarMotorcycle => 'دراجة نارية';

  @override
  String get profileClassWind => 'رياح';

  @override
  String get profileClassSteps => 'خطوات';

  @override
  String get profileClassVoice => 'صوت';

  @override
  String get profileClassStreet => 'شارع';

  @override
  String get profileClassMusic => 'موسيقى';

  @override
  String get profileClassOther => 'أخرى';

  @override
  String get ttsSource => 'مصدر النطق';

  @override
  String get ttsSourceOffline => 'دون اتصال';

  @override
  String get ttsSourceSystem => 'النظام';

  @override
  String get ttsSourceOfflineSubtitle => 'نطق عصبي مدمج (موصى به، مستقر على جميع الأجهزة)';

  @override
  String get ttsSourceSystemSubtitle => 'محرك النطق الخاص بنظام أندرويد';

  @override
  String get ttsSourceSwitchedHint => 'تم تغيير مصدر النطق';

  @override
  String get voicePackages => 'حزم الأصوات';

  @override
  String get voicePackagesSubtitle => 'نماذج نطق دون اتصال للغات';

  @override
  String get voicePackagesDescription => 'حمّل نماذج النطق العصبية دون اتصال ليعمل النطق بدون إنترنت ويبقى مستقراً على أي جهاز. النموذج الروسي مضمّن في التطبيق؛ يمكن تحميل الباقي هنا.';

  @override
  String get voicePackageReady => 'جاهز';

  @override
  String get voicePackageBundled => 'مضمّن مع التطبيق';

  @override
  String get voicePackageDownload => 'تحميل';

  @override
  String get voicePackageInstall => 'تثبيت';

  @override
  String get voicePackageRetry => 'إعادة المحاولة';

  @override
  String get voicePackageDownloading => 'جارٍ التحميل...';

  @override
  String get voicePackageExtracting => 'جارٍ الاستخراج...';

  @override
  String get voicePackageError => 'خطأ';

  @override
  String get voicePackageDelete => 'حذف';

  @override
  String voicePackageInstalledSuccess(Object lang) {
    return 'تم تثبيت نموذج \"$lang\"';
  }

  @override
  String voicePackageInstalledFailed(Object lang) {
    return 'فشل تثبيت نموذج \"$lang\"';
  }

  @override
  String voicePackageDeleteConfirm(Object lang) {
    return 'حذف نموذج \"$lang\"؟ سيؤدي ذلك إلى تحرير مساحة.';
  }

  @override
  String get lyricColors => 'ألوان الأسطر';

  @override
  String get lyricColorsTitle => 'ألوان الأسطر';

  @override
  String get lyricColorsUseCustom => 'ألوان مخصصة';

  @override
  String get lyricColorsPresets => 'إعدادات مسبقة';

  @override
  String get lyricColorsOriginal => 'الأصلي';

  @override
  String get lyricColorsTranslation => 'الترجمة';

  @override
  String get lyricColorsPreview => 'معاينة';

  @override
  String get lyricColorsDone => 'تم';

  @override
  String get lyricPresetDefault => 'افتراضي';

  @override
  String get lyricPresetBlueRed => 'الأصلي أزرق / الترجمة أحمر';

  @override
  String get lyricPresetRedBlue => 'الأصلي أحمر / الترجمة أزرق';

  @override
  String get lyricPresetGreenOrange => 'الأصلي أخضر / الترجمة برتقالي';

  @override
  String get lyricPresetContrast => 'تباين عالٍ';
}
