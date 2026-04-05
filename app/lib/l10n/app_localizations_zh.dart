// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => '图书馆';

  @override
  String get playlists => '播放列表';

  @override
  String get settings => '设置';

  @override
  String get allSongs => '所有歌曲';

  @override
  String get favorites => '收藏';

  @override
  String get createPlaylist => '创建播放列表';

  @override
  String get playlistName => '播放列表名称';

  @override
  String get iconOptional => '图标（可选）';

  @override
  String get cancel => '取消';

  @override
  String get create => '创建';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get save => '保存';

  @override
  String get close => '关闭';

  @override
  String get search => '搜索';

  @override
  String get filter => '筛选';

  @override
  String get sort => '排序';

  @override
  String get addToFavorites => '添加到收藏';

  @override
  String get removeFromFavorites => '从收藏中移除';

  @override
  String get addToPlaylist => '添加到播放列表';

  @override
  String get removeFromPlaylist => '从播放列表中移除';

  @override
  String get addSongsToLibrary => '从资料库添加歌曲';

  @override
  String get noSongsToAdd => '没有可添加的歌曲';

  @override
  String addButtonText(Object count) {
    return '添加 $count';
  }

  @override
  String get selected => '已选择';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '浅色模式';

  @override
  String get autoScroll => '自动滚动';

  @override
  String get autoScrollSubtitle => '自动滚动到当前行';

  @override
  String get highlightNextLine => '高亮下一行';

  @override
  String get highlightNextLineSubtitle => '以微弱的高亮显示下一行';

  @override
  String get fontSize => '字体大小';

  @override
  String get scrollOffset => '滚动偏移';

  @override
  String get scrollOffsetSubtitle => '距屏幕顶部的像素距离';

  @override
  String get autoScrollFocusOffset => '自动滚动焦点偏移';

  @override
  String get autoScrollFocusOffsetSubtitle => '自动滚动的默认焦点位置（默认: +50）';

  @override
  String get showVerticalSlider => '垂直滑块';

  @override
  String get showVerticalSliderSubtitle => '显示侧边滚动滑块';

  @override
  String get defaultTranslationLanguage => '默认翻译语言';

  @override
  String get defaultOriginalLanguage => '默认源语言';

  @override
  String get russian => '俄语';

  @override
  String get english => '英语';

  @override
  String get romanian => '罗马尼亚语';

  @override
  String get french => '法语';

  @override
  String get german => '德语';

  @override
  String get spanish => '西班牙语';

  @override
  String get italian => '意大利语';

  @override
  String get portuguese => '葡萄牙语';

  @override
  String get lyricsFolder => '歌词文件夹';

  @override
  String get useLyricsFolder => '使用歌词文件夹';

  @override
  String get useLyricsFolderDisabled => '已禁用 - 必须与音频一起选择文件';

  @override
  String get setLyricsFolder => '设置歌词文件夹';

  @override
  String get selectFolder => '选择文件夹';

  @override
  String get folderPath => '文件夹路径';

  @override
  String get examples => '示例：';

  @override
  String get defaultFolder => '默认：/LingoTune_Lyrics';

  @override
  String get currentFolder => '当前文件夹：';

  @override
  String folderSetSuccessfully(Object path) {
    return '文件夹已设置：$path';
  }

  @override
  String get folderSetFailed => '文件夹不存在或无法访问';

  @override
  String get resetToDefault => '重置为默认';

  @override
  String get showCurrentFolder => '显示当前文件夹';

  @override
  String get changeFolder => '更改文件夹';

  @override
  String get resetToDefaultFolder => '重置为默认文件夹';

  @override
  String get folderReset => '重置为默认文件夹';

  @override
  String get clearCache => '清除缓存';

  @override
  String get clearCacheSubtitle => '清除临时文件';

  @override
  String get cacheCleared => '缓存已清除';

  @override
  String get resetSongLanguages => '重置歌曲语言';

  @override
  String get resetSongLanguagesSubtitle => '使用设置中的默认语言';

  @override
  String get songLanguagesReset => '歌曲语言已重置';

  @override
  String get about => '关于';

  @override
  String get translationsLoaded => '翻译加载成功！';

  @override
  String failedToLoadTranslations(Object error) {
    return '加载翻译失败：$error';
  }

  @override
  String get editTranslations => '编辑翻译';

  @override
  String get loadTranslationsFromFile => '从文件加载翻译';

  @override
  String get loadTextMenu => '加载文本';

  @override
  String get loadTranslations => '加载翻译';

  @override
  String get deleteTranslation => '删除翻译';

  @override
  String get noFileSelected => '未选择文件';

  @override
  String get noLrcFileAssociated => '此歌曲没有关联的LRC文件';

  @override
  String get lrcFileSaved => 'LRC文件保存成功！';

  @override
  String failedToSaveLrcFile(Object error) {
    return '保存LRC文件失败：$error';
  }

  @override
  String get exitEditMode => '退出编辑模式';

  @override
  String get editTimestamps => '编辑时间戳';

  @override
  String get saveChanges => '保存更改';

  @override
  String get language => '语言';

  @override
  String get loading => '加载中...';

  @override
  String get noSongsFound => '未找到歌曲';

  @override
  String get noPlaylistsFound => '未找到播放列表';

  @override
  String get selectSong => '选择要播放的歌曲';

  @override
  String get song => '歌曲';

  @override
  String get artist => '艺术家';

  @override
  String get duration => '持续时间';

  @override
  String get actions => '操作';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get stop => '停止';

  @override
  String get previous => '上一首';

  @override
  String get next => '下一首';

  @override
  String get rewind10 => '-10秒';

  @override
  String get forward10 => '+10秒';

  @override
  String get repeat => '重复';

  @override
  String get shuffle => '随机';

  @override
  String get volume => '音量';

  @override
  String get speed => '速度';

  @override
  String get lyrics => '歌词';

  @override
  String get translations => '翻译';

  @override
  String get originalText => '原文';

  @override
  String get translatedText => '译文';

  @override
  String get showTranscription => '显示音标';

  @override
  String get showTranscriptionSubtitle => '显示发音指南';

  @override
  String get showTranslationFirst => '翻译优先';

  @override
  String get showTranslationFirstSubtitle => '在原文之前显示翻译';

  @override
  String get italianLang => '意大利语';

  @override
  String get portugueseLang => '葡萄牙语';

  @override
  String get lyricsEditor => '歌词编辑器';

  @override
  String get addLine => '添加行';

  @override
  String get updateLine => '更新行';

  @override
  String get deleteLine => '删除行';

  @override
  String get clearAll => '清除全部';

  @override
  String get moveUp => '上移';

  @override
  String get moveDown => '下移';

  @override
  String get autoSyncLyrics => '自动同步歌词';

  @override
  String get exportLrc => '导出LRC（原文）';

  @override
  String get exportJson => '导出JSON（翻译）';

  @override
  String get markTimestamp => '标记时间戳（回车）';

  @override
  String get original => '原文';

  @override
  String get translation => '翻译';

  @override
  String get audioFile => '音频文件';

  @override
  String get songTitle => '歌曲标题';

  @override
  String get browse => '浏览';

  @override
  String get audioControls => '音频控制';

  @override
  String get addEditLine => '添加/编辑行';

  @override
  String get instructions => '说明';

  @override
  String get lyricsEditorInstructions => 'LRC同步器说明：\\n\\n1. 使用浏览按钮选择音频文件\\n2. 输入歌曲标题和艺术家（可选）\\n3. 点击播放开始音频\\n4. 当一行被唱出时，在原文字段中输入原文\\n5. 按回车或点击标记时间戳记录时间戳\\n6. 可选地在翻译字段中添加翻译\\n7. 对每行重复步骤4-6\\n8. 使用导出LRC保存带有时间戳的原始歌词\\n9. 使用导出JSON保存翻译\\n\\n提示：\\n- 使用-10秒/+10秒快速导航歌曲\\n- 可以使用上移/下移重新排序行\\n- 加载先前保存的JSON文件以编辑翻译';

  @override
  String get welcome => '欢迎';

  @override
  String get welcomeMessage => '开始您的语言学习音乐之旅！';

  @override
  String get importSongs => '导入歌曲';

  @override
  String get importSongsSubtitle => '从您的设备添加音频文件';

  @override
  String get manageLibrary => '管理库';

  @override
  String get manageLibrarySubtitle => '组织您的歌曲和播放列表';

  @override
  String get syncLyrics => '同步歌词';

  @override
  String get syncLyricsSubtitle => '自动将歌词与音频同步';

  @override
  String get languageLearning => '语言学习 • 音乐 • 翻译';

  @override
  String get version => '版本';

  @override
  String get developer => '开发人员';

  @override
  String get website => '网站';

  @override
  String failedToCreatePlaylist(Object error) {
    return '创建播放列表失败：$error';
  }

  @override
  String get playlistCreated => '播放列表创建成功！';

  @override
  String get playlistDeleted => '播放列表删除成功！';

  @override
  String get playlistUpdated => '播放列表更新成功！';

  @override
  String get songAdded => '歌曲添加成功！';

  @override
  String get songRemoved => '歌曲移除成功！';

  @override
  String get songDeleted => '歌曲删除成功！';

  @override
  String get error => '错误';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get success => '成功';

  @override
  String get confirm => '确认';

  @override
  String get areYouSure => '您确定吗？';

  @override
  String get unsavedChanges => '您有未保存的更改。继续吗？';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get appLanguage => '应用语言';

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
  String get welcomeToLingoTune => '欢迎使用LingoTune';

  @override
  String get folderSetupMessage => '选择一个文件夹来存储歌词和翻译（LRC和JSON文件）。这样可以轻松组织您的音乐库。';

  @override
  String get selectFolderNow => '立即选择文件夹';

  @override
  String get goToSettings => '转到设置';

  @override
  String get setupLater => '稍后设置';

  @override
  String get useDefaultFolder => '使用默认文件夹';

  @override
  String get databaseFound => '在导入文件中找到数据库';

  @override
  String get importDatabaseQuestion => '您也想导入数据库吗？';

  @override
  String get mergeDatabase => '合并';

  @override
  String get replaceDatabase => '替换';

  @override
  String get importDatabase => '导入数据库';

  @override
  String get skipDatabase => '跳过数据库';

  @override
  String get mergeDatabaseDescription => '将导入的歌曲与您的库合并（仅添加新项目）';

  @override
  String get replaceDatabaseDescription => '用导入的数据库替换您的整个库（您将丢失所有现有数据）';

  @override
  String get exporting => '导出中...';

  @override
  String exportingProgress(Object current, Object total) {
    return '正在导出$total首中的$current首歌曲';
  }

  @override
  String get exportDatabaseIncluded => '导出中包含数据库';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return '导入了$fileCount个文件和数据库';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return '导入了$fileCount个文件';
  }

  @override
  String get chinese => '中文';

  @override
  String get arabic => '阿拉伯语';

  @override
  String get colorTheme => '颜色主题';

  @override
  String get themeColorPurple => '紫色';

  @override
  String get themeColorBlue => '蓝色';

  @override
  String get themeColorGreen => '绿色';

  @override
  String get themeColorOrange => '橙色';

  @override
  String get themeColorRed => '红色';

  @override
  String get themeColorPink => '粉色';

  @override
  String get themeColorDeepOrange => '深橙色';

  @override
  String get themeColorDarkRed => '深红色';

  @override
  String get themeColorTeal => '青色';

  @override
  String get themeColorCyan => '青绿色';

  @override
  String get themeColorAmber => '琥珀色';

  @override
  String get themeColorLime => '酸橙色';

  @override
  String get ukrainianLang => '乌克兰语';

  @override
  String get font => '字体';

  @override
  String get fontSettings => '字体设置';

  @override
  String get systemFont => '系统';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => '主文本大小';

  @override
  String get mainTextBold => '主文本粗体';

  @override
  String get translationSize => '翻译大小';

  @override
  String get translationBold => '翻译粗体';

  @override
  String get transcriptSize => '音标大小';

  @override
  String get transcriptBold => '音标粗体';

  @override
  String get defaultStartScreen => '默认启动屏幕';

  @override
  String get defaultStartScreenSubtitle => '应用程序启动时显示的屏幕';

  @override
  String get addToLibraryWhenAddingToPlaylist => '添加到播放列表时添加到库';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => '将歌曲添加到播放列表时自动添加到库';

  @override
  String get serviceMessages => '服务消息';

  @override
  String get serviceMessagesSubtitle => '显示有关翻译和音标的服务通知';

  @override
  String get includeMp3Files => '包含 MP3 文件';

  @override
  String get includeMp3FilesSubtitle => '这将增加存档大小';

  @override
  String get importMp3Files => '导入 MP3 文件';

  @override
  String get importMp3FilesSubtitle => '将音乐文件添加到库中';

  @override
  String get exportSongs => '导出歌曲';

  @override
  String get import => '导入';

  @override
  String get addMultiple => '选择多个';

  @override
  String get addToPlaylistShort => '添加';

  @override
  String get deleteShort => '删除';

  @override
  String get selectAllShort => '全部';

  @override
  String get deselectAllShort => '清空';

  @override
  String get exitSelectionMode => '退出选择模式';

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String get deleteSelected => '删除选中的';

  @override
  String get addMultipleToPlaylist => '添加到播放列表';

  @override
  String get coverArt => '封面';

  @override
  String get playlistCover => '播放列表封面';

  @override
  String get selectFromGallery => '从图库选择';

  @override
  String get removeCover => '删除封面';

  @override
  String get coverUpdated => '封面已更新';

  @override
  String get coverRemoved => '封面已删除';

  @override
  String errorWithMessage(Object error) {
    return '错误: $error';
  }

  @override
  String get importFolders => '导入文件夹';

  @override
  String get selectMusicFolder => '选择音乐文件夹';

  @override
  String get folderWithAudioFiles => '包含MP3/WAV文件的文件夹';

  @override
  String get sameFolderForLyrics => '歌词使用同一文件夹';

  @override
  String get selectLyricsFolder => '选择歌词文件夹';

  @override
  String get folderWithLyricsFiles => '包含LRC/JSON文件的文件夹（可选）';

  @override
  String get pleaseEnterPlaylistName => '请输入播放列表名称';

  @override
  String get pleaseSelectMusicFolder => '请选择一个音乐文件夹';

  @override
  String get cropImage => '裁剪图片';

  @override
  String get photoPermissionRequired => '需要照片访问权限';

  @override
  String get photoPermissionDenied => '照片访问被拒绝';

  @override
  String get imageProcessingError => '图片处理失败';

  @override
  String get scanningFolder => '扫描文件夹中...';

  @override
  String get importingFiles => '导入文件中...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return '正在导入$current/$total个文件...找到$songs首歌曲';
  }

  @override
  String processingFile(Object file) {
    return '正在处理$file...';
  }

  @override
  String get addToPlaylistDialogTitle => '添加到播放列表';

  @override
  String addedToPlaylist(Object playlist) {
    return '已添加到 \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return '添加到播放列表失败: $error';
  }

  @override
  String get deleteSong => '删除';

  @override
  String get importSongDialogTitle => '导入歌曲';

  @override
  String get audioOnly => '仅音频';

  @override
  String get addLyricsLater => '稍后添加歌词';

  @override
  String get audioWithLyricsZIP => '音频 + 歌词ZIP';

  @override
  String get importWithAllTranslations => '导入所有翻译';

  @override
  String get importTranslationDialogTitle => '添加翻译';

  @override
  String get loadTranslationFromZip => '从 ZIP 存档加载';

  @override
  String get loadTranslationFromJson => '从 JSON 文件加载';

  @override
  String get noAudioFilesSelected => '未选择音频文件';

  @override
  String failedToImportSongs(Object error) {
    return '导入歌曲失败: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return '导入歌曲失败: $error';
  }

  @override
  String get musicFolderNotSelected => '未选择音乐文件夹';

  @override
  String get generateLyrics => '生成歌词';

  @override
  String get selectTextFileOrEnterText => '选择文本文件或输入文本';

  @override
  String get originalLanguage => '原始语言';

  @override
  String get translationLanguages => '翻译语言';

  @override
  String get startMinuteForTimestamps => '时间戳起始分钟';

  @override
  String get transcriptionLanguage => '转录语言';

  @override
  String get generating => '生成中...';

  @override
  String get generate => '生成';

  @override
  String get deepseekApiKey => 'DeepSeek API 密钥';

  @override
  String get validateKey => '验证密钥';

  @override
  String get keyIsValid => '密钥有效';

  @override
  String get keyIsInvalid => '密钥无效';

  @override
  String get lyricsGenerationSuccess => '歌词生成成功';

  @override
  String get lyricsGenerationError => '歌词生成失败';

  @override
  String get savingFiles => '正在保存文件...';

  @override
  String get enterText => '输入文本';

  @override
  String get transcript => '转录';

  @override
  String get originalTextEditable => '原文（可编辑）';

  @override
  String get selectLanguageToEdit => '选择要编辑的语言';

  @override
  String get moveLineUp => '上移行';

  @override
  String get moveLineDown => '下移行';

  @override
  String get moveAllTranslationsUp => '上移所有翻译';

  @override
  String get moveAllTranslationsDown => '下移所有翻译';

  @override
  String get translationSaved => '翻译已保存！';

  @override
  String get translationSaveFailed => '翻译保存失败';

  @override
  String get loadTextTitle => '加载文本';

  @override
  String get noOriginalTextWarning => '请先加载原始文本';

  @override
  String get selectLanguageOriginal => '原始语言';

  @override
  String get startTimestampMinutes => '开始时间戳（分钟）';

  @override
  String get selectLanguageTranslation => '翻译语言';

  @override
  String get originalTextLoaded => '原始文本加载成功！';

  @override
  String get translationLoaded => '翻译加载成功！';

  @override
  String get transcriptLoaded => '音标加载成功！';

  @override
  String get selectTranslationLanguage => '音标的翻译语言';

  @override
  String get noTranslationWarning => '没有加载的翻译';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return '行数不匹配：$loaded 行，预期 $expected';
  }

  @override
  String get loadTextTooltip => '加载文本或翻译';

  @override
  String get loadFromFile => '从文件加载';

  @override
  String get pasteFromClipboard => '从剪贴板粘贴';

  @override
  String get audioNotificationService => '音频通知服务';

  @override
  String get audioNotificationServiceActive => '状态：✅ 激活';

  @override
  String get audioNotificationServiceError => '状态：❌ 错误';

  @override
  String get errorLabel => '错误：';

  @override
  String get audioNotificationServiceDescription => '此服务在应用最小化时提供通知';

  @override
  String get reorder => '重新排序';

  @override
  String get done => '完成';

  @override
  String get selectMultiple => '选择多个';

  @override
  String get sortSongs => '排序歌曲';

  @override
  String get importSong => '导入歌曲';

  @override
  String get sortDefault => '默认';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => '最新';

  @override
  String get sortDateAsc => '最旧';

  @override
  String get importingSongs => '正在导入歌曲...';

  @override
  String get noSongsInPlaylist => '此播放列表中没有歌曲';

  @override
  String get addSongsFromLibraryHint => '从资料库添加歌曲';

  @override
  String get removedSongsFromPlaylist => '从播放列表移除歌曲';

  @override
  String failedToRemoveSongs(Object error) {
    return '删除歌曲失败: $error';
  }

  @override
  String get deletePlaylistTitle => '删除播放列表';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return '确定要删除\"$playlist\"吗？';
  }

  @override
  String get failedToDeletePlaylist => '无法删除播放列表：';

  @override
  String get specifyTranslationLanguage => '指定翻译语言';

  @override
  String get languageNameLabel => '语言名称';

  @override
  String get languageNameHint => '例如：俄语、作者、诗意';

  @override
  String get translationTypeLabel => '翻译类型：';

  @override
  String get translationTypeNormal => '普通';

  @override
  String get translationTypeAuthor => '作者';

  @override
  String get translationTypePoetic => '诗意';

  @override
  String get translationTypeLiteral => '直译';

  @override
  String mp3FilesCount(Object count) {
    return 'MP3 文件：$count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return '已导入 $count 个文件（跳过数据库）';
  }

  @override
  String get databaseMerged => '数据库已合并';

  @override
  String databaseMergedWithMp3(Object count) {
    return '数据库已合并，MP3 文件：$count';
  }

  @override
  String get databaseReplaced => '数据库已替换';

  @override
  String databaseReplacedWithMp3(Object count) {
    return '数据库已替换，MP3 文件：$count';
  }

  @override
  String get confirmReplaceDatabase => '确认替换';

  @override
  String get confirmReplaceDatabaseWarning => '确定吗？您将失去所有现有歌曲和播放列表！';

  @override
  String get replaceAll => '全部替换';

  @override
  String get selectLanguages => '选择语言';

  @override
  String selectedLanguagesCount(Object count) {
    return '已选择：$count 种语言';
  }

  @override
  String selectedSongsCount(Object count) {
    return '已选择：$count';
  }

  @override
  String get promptPreset => '提示词预设';

  @override
  String get balanced => '平衡';

  @override
  String get poetic => '诗意';

  @override
  String get literal => '直译';

  @override
  String get customPromptOption => '自定义...';

  @override
  String get editPrompt => '编辑提示词';

  @override
  String get notSet => '未设置';

  @override
  String get showOrEditApiKey => '显示/编辑API密钥';

  @override
  String get timeout => '超时';

  @override
  String get model => '模型';

  @override
  String get resetToPreset => '重置为预设';

  @override
  String get customPrompt => '自定义提示词';

  @override
  String customPromptChars(Object count) {
    return '自定义提示词（$count字符）';
  }

  @override
  String usingPreset(Object preset) {
    return '使用预设：$preset';
  }

  @override
  String get characters => '字符';

  @override
  String get deepSeekPromptTitle => 'DeepSeek提示词';

  @override
  String get customPromptLabel => '自定义提示词';

  @override
  String get leaveEmptyToUseDefault => '留空以使用默认提示词';

  @override
  String get leaveEmptyToUseDefaultPrompt => '留空以使用应用内置的默认提示词';

  @override
  String get apiKeySaved => 'API密钥已保存';

  @override
  String get enterTimeout => '输入超时时间（秒）';

  @override
  String get validTimeoutRange => '请输入有效的超时时间（1-3600秒）';

  @override
  String get customTimeout => '自定义超时';

  @override
  String get timeoutSeconds => '超时（秒）';

  @override
  String timeoutSetTo(Object value) {
    return '超时设置为$value秒';
  }

  @override
  String get customModel => '自定义模型';

  @override
  String get modelName => '模型名称';

  @override
  String get enterModelName => '输入DeepSeek API提供的确切模型名称';

  @override
  String get pleaseEnterModelName => '请输入模型名称';

  @override
  String modelSetTo(Object value) {
    return '模型设置为$value';
  }

  @override
  String get editCustomPrompt => '编辑自定义提示词';

  @override
  String get editPresetPrompt => '编辑预设提示词';

  @override
  String get editingPreset => '编辑预设';

  @override
  String get anyChangesSaveAsCustom => '任何更改将保存为自定义提示词。使用\'重置\'按钮恢复原始预设。';

  @override
  String get useResetToRestorePreset => '使用\'重置\'按钮恢复原始预设';

  @override
  String get prompt => '提示词';

  @override
  String get promptSaved => '提示词已保存';

  @override
  String get usingPresetPrompt => '使用预设提示词';

  @override
  String get apiKeyHint => 'API密钥';

  @override
  String get modelHint => '例如：deepseek-v3';

  @override
  String get enterExactModelName => '输入DeepSeek API提供的确切模型名称。';

  @override
  String get pleaseEnterApiKeyFirst => '请先输入API密钥';

  @override
  String get maxTokensRegular => 'Max Tokens（常规）';

  @override
  String get maxTokensJson => 'Max Tokens（JSON）';

  @override
  String get maxTokensRegularHint => '常规翻译请求的令牌限制';

  @override
  String get maxTokensJsonHint => '完整生成（JSON）请求的令牌限制';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens（常规）已设置为 $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens（JSON）已设置为 $value';
  }

  @override
  String get refreshFolder => '刷新文件夹';

  @override
  String get refreshingFolder => '正在刷新文件夹...';

  @override
  String get playlistCreatedWithLink => '播放列表已创建！点击\"刷新\"从文件夹加载歌曲';

  @override
  String refreshedPlaylist(Object count) {
    return '已刷新：$count 首歌曲';
  }

  @override
  String refreshPlaylistError(Object error) {
    return '刷新错误：$error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return '加载歌曲失败: $error';
  }

  @override
  String get musicFolderDoesNotExist => '音乐文件夹不存在';

  @override
  String successfullyImportedSongs(Object count) {
    return '成功导入 $count 首歌曲';
  }

  @override
  String get noAudioFileSelected => '未选择音频文件';

  @override
  String get noZipArchiveSelected => '未选择ZIP归档';

  @override
  String get noFolderConfigured => '未配置文件夹';

  @override
  String get missingLyricsTranslations => '缺少歌词/翻译';

  @override
  String missingForSong(Object songName) {
    return '对于 \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return '缺少: $files';
  }

  @override
  String get whatWouldYouLikeToDo => '您想做什么?';

  @override
  String get lyricsGeneratedSuccessfully => '歌词生成成功';

  @override
  String get setDeepSeekApiKey => '请在设置中配置DeepSeek API密钥';

  @override
  String failedToOpenSong(Object error) {
    return '打开歌曲失败: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => '同时删除LRC和JSON文件';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return '已添加到 \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return '添加到播放列表失败: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return '已导出 $count 首歌曲';
  }

  @override
  String get fileNotFound => '文件未找到';

  @override
  String get selectZipFileNotJson => '请选择ZIP文件,而不是JSON或LRC';

  @override
  String get noFilesFoundInZip => 'ZIP中未找到文件';

  @override
  String invalidZipFileFormat(Object error) {
    return '无效的ZIP文件格式: $error';
  }

  @override
  String importFailed(Object error) {
    return '导入失败: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return '找到 $count 个翻译';
  }

  @override
  String mp3ImportError(Object error) {
    return 'MP3导入错误: $error';
  }

  @override
  String get importSongFirstToSearch => '请先导入歌曲以搜索歌词';

  @override
  String get lyricsFetched => '歌词已获取';

  @override
  String get lyricsFoundUseCreate => '找到歌词! 用于创建同步的LRC文件';

  @override
  String get deleteSelectedSongs => '删除选中的歌曲';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return '您确定要删除 $count 首歌曲吗?';
  }

  @override
  String get songsDeletedSuccessfully => '歌曲删除成功';

  @override
  String get storagePermissionRequired => '需要存储权限才能访问文件夹.';

  @override
  String get enableStoragePermission => '请在设置中启用存储权限.';

  @override
  String get openSettings => '打开设置';

  @override
  String get unableToSelectFolder => '无法选择文件夹. 请尝试替代方案:';

  @override
  String get selectFilesInstead => '改为选择文件';

  @override
  String get enterFolderPath => '请输入文件夹路径';

  @override
  String get folderDoesNotExist => '✗ 文件夹不存在';

  @override
  String folderSetWithPath(Object path) {
    return '文件夹已设置: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return '设置文件夹错误: $error';
  }

  @override
  String get unableToSelectLyricsFolder => '无法选择歌词文件夹. 请尝试替代方案:';

  @override
  String get useManualPath => '使用手动路径(用于测试)';

  @override
  String get enterFolderPathManually => '手动输入文件夹路径而不是使用文件夹选择器';

  @override
  String get folderPathLabel => '文件夹路径';

  @override
  String get folderPathHint => '示例: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => '音乐文件夹的完整路径';

  @override
  String get setPath => '设置路径';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return '选择包含 \"$title\" 歌词的ZIP归档';
  }

  @override
  String get skip => '跳过';

  @override
  String get retry => '重试';

  @override
  String get failedToCopyLrcFile => '复制LRC文件失败';

  @override
  String copiedJsonFiles(Object count) {
    return '已复制 $count 个JSON文件';
  }

  @override
  String get failedToCopyJsonFiles => '复制JSON文件失败';

  @override
  String failedToDeleteSong(Object error) {
    return '删除歌曲失败: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return '已添加 $count 首歌曲到 \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return '添加 $count 首歌曲到播放列表';
  }

  @override
  String get failedToExportSongs => '导出歌曲失败';

  @override
  String get ok => '确定';

  @override
  String deleteSongConfirm(Object song) {
    return '您确定要删除 \"$song\" 吗?';
  }

  @override
  String get selectMusicFolderForPlaylist => '为此播放列表选择音乐文件夹';

  @override
  String get folderLinkedToPlaylist => '文件夹已链接到播放列表';

  @override
  String get folderUnlinkedFromPlaylist => '文件夹已从播放列表取消链接';

  @override
  String get checkFolderAccess => '检查文件夹访问权限';

  @override
  String get checkingPermissions => '正在检查权限...';

  @override
  String get folderAccessible => '✓ 文件夹可访问';

  @override
  String get folderNotAccessible => '✗ 文件夹无法访问';

  @override
  String audioFilesFound(Object count) {
    return '找到 $count 个音频文件';
  }

  @override
  String lyricsFound(Object count) {
    return '找到 $count 个歌词文件';
  }

  @override
  String get noAudioFiles => '未找到音频文件';

  @override
  String get noLyricsFiles => '未找到歌词文件';

  @override
  String errorCheckingAccess(Object error) {
    return '检查访问权限时出错: $error';
  }

  @override
  String get folderPathColon => '文件夹路径:';

  @override
  String get permissionsStatus => '权限状态:';

  @override
  String get folderContent => '文件夹内容:';

  @override
  String get accessGranted => '✓ 访问已授予';

  @override
  String get accessDenied => '✗ 访问被拒绝';

  @override
  String get permissionRequestFailed => '权限请求失败';

  @override
  String get pleaseGrantPermissions => '请授予存储权限以检查文件夹';

  @override
  String get refreshOnlySongs => '仅歌曲';

  @override
  String get refreshEverything => '所有内容';

  @override
  String get refreshDialogDescription => '您想更新什么? \"仅歌曲\" 通过跳过歌词加快处理速度。';

  @override
  String get mostSongs => '最多歌曲';
}
