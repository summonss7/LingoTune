#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import sys

# Arabic translations
ar_translations = {
    "lyricsFolder": "مجلد الكلمات",
    "useLyricsFolder": "استخدام مجلد الكلمات",
    "useLyricsFolderDisabled": "معطل - يجب اختيار الملفات مع الصوت",
    "setLyricsFolder": "تعيين مجلد الكلمات",
    "selectFolder": "اختيار مجلد",
    "folderPath": "مسار المجلد",
    "examples": "أمثلة:",
    "defaultFolder": "الافتراضي: /LingoTune_Lyrics",
    "currentFolder": "المجلد الحالي:",
    "folderSetSuccessfully": "تم تعيين المجلد: {path}",
    "folderSetFailed": "المجلد غير موجود أو لا يمكن الوصول إليه",
    "resetToDefault": "إعادة تعيين إلى الافتراضي",
    "showCurrentFolder": "عرض المجلد الحالي",
    "changeFolder": "تغيير المجلد",
    "resetToDefaultFolder": "إعادة تعيين إلى المجلد الافتراضي",
    "folderReset": "إعادة تعيين إلى المجلد الافتراضي",
    "clearCache": "مسح ذاكرة التخزين المؤقت",
    "clearCacheSubtitle": "مسح الملفات المؤقتة",
    "cacheCleared": "تم مسح ذاكرة التخزين المؤقت",
    "resetSongLanguages": "إعادة تعيين لغات الأغاني",
    "resetSongLanguagesSubtitle": "استخدام اللغة الافتراضية من الإعدادات",
    "songLanguagesReset": "تم إعادة تعيين لغات الأغاني",
    "about": "حول",
    "translationsLoaded": "تم تحميل الترجمات بنجاح!",
    "failedToLoadTranslations": "فشل تحميل الترجمات: {error}",
    "editTranslations": "تعديل الترجمات",
    "loadTranslationsFromFile": "تحميل الترجمات من ملف",
    "loadTranslations": "تحميل الترجمات",
    "noFileSelected": "لم يتم اختيار ملف",
    "noLrcFileAssociated": "لا يوجد ملف LRC مرتبط بهذه الأغنية",
    "lrcFileSaved": "تم حفظ ملف LRC بنجاح!",
    "failedToSaveLrcFile": "فشل حفظ ملف LRC: {error}",
    "exitEditMode": "الخروج من وضع التعديل",
    "editTimestamps": "تعديل الطوابع الزمنية",
    "saveChanges": "حفظ التغييرات",
    "language": "اللغة",
    "loading": "جاري التحميل...",
    "noSongsFound": "لم يتم العثور على أغانٍ",
    "noPlaylistsFound": "لم يتم العثور على قوائم تشغيل",
    "selectSong": "اختر أغنية للتشغيل",
    "song": "أغنية",
    "artist": "الفنان",
    "duration": "المدة",
    "actions": "الإجراءات",
    "play": "تشغيل",
    "pause": "إيقاف مؤقت",
    "stop": "إيقاف",
    "previous": "السابق",
    "next": "التالي",
    "rewind10": "-10 ثانية",
    "forward10": "+10 ثانية",
    "repeat": "تكرار",
    "shuffle": "خلط",
    "volume": "مستوى الصوت",
    "speed": "السرعة",
    "lyrics": "الكلمات",
    "translations": "الترجمات",
    "originalText": "النص الأصلي",
    "translatedText": "النص المترجم",
    "showTranscription": "عرض النسخ الصوتي",
    "showTranscriptionSubtitle": "عرض دليل النطق",
    "showTranslationFirst": "الترجمة أولاً",
    "showTranslationFirstSubtitle": "عرض الترجمة قبل النص الأصلي",
    "italianLang": "Italiano",
    "portugueseLang": "Português",
    "lyricsEditor": "محرر الكلمات",
    "addLine": "إضافة سطر",
    "updateLine": "تحديث السطر",
    "deleteLine": "حذف السطر",
    "clearAll": "مسح الكل",
    "moveUp": "تحريك لأعلى",
    "moveDown": "تحريك لأسفل",
    "autoSyncLyrics": "مزامنة الكلمات تلقائياً",
    "exportLrc": "تصدير LRC (الأصلي)",
    "exportJson": "تصدير JSON (الترجمات)",
    "markTimestamp": "تحديد الطابع الزمني (إدخال)",
    "original": "الأصلي",
    "translation": "الترجمة",
    "audioFile": "ملف الصوت",
    "songTitle": "عنوان الأغنية",
    "browse": "تصفح",
    "audioControls": "ضوابط الصوت",
    "addEditLine": "إضافة/تعديل سطر",
    "instructions": "التعليمات",
    "lyricsEditorInstructions": "تعليمات مزامنة LRC:\\n\\n1. اختر ملف صوتي باستخدام زر تصفح\\n2. أدخل عنوان الأغنية والفنان (اختياري)\\n3. اضغط تشغيل لبدء الصوت\\n4. عندما يتم غناء سطر، أدخل النص الأصلي في حقل الأصلي\\n5. اضغط إدخال أو اضغط تحديد الطابع الزمني لتسجيل الوقت\\n6. أضف ترجمة اختيارياً في حقل الترجمة\\n7. كرر الخطوات 4-6 لكل سطر\\n8. استخدم تصدير LRC لحفظ الكلمات الأصلية مع الطوابع الزمنية\\n9. استخدم تصدير JSON لحفظ الترجمات\\n\\nنصائح:\\n- استخدم -10 ثانية/+10 ثانية للتنقل بسرعة في الأغنية\\n- يمكنك إعادة ترتيب الأسطر باستخدام تحريك لأعلى/لأسفل\\n- قم بتحميل ملفات JSON المحفوظة سابقاً لتعديل الترجمات",
    "welcome": "مرحباً",
    "welcomeMessage": "ابدأ رحلة تعلم اللغة بالموسيقى!",
    "importSongs": "استيراد الأغاني",
    "importSongsSubtitle": "إضافة ملفات صوتية من جهازك",
    "manageLibrary": "إدارة المكتبة",
    "manageLibrarySubtitle": "تنظيم أغانك وقوائم التشغيل",
    "syncLyrics": "مزامنة الكلمات",
    "syncLyricsSubtitle": "مزامنة الكلمات مع الصوت تلقائياً",
    "languageLearning": "تعلم اللغة • الموسيقى • الترجمات",
    "version": "الإصدار",
    "developer": "تم التطوير بواسطة",
    "website": "الموقع",
    "failedToCreatePlaylist": "فشل إنشاء قائمة التشغيل: {error}",
    "playlistCreated": "تم إنشاء قائمة التشغيل بنجاح!",
    "playlistDeleted": "تم حذف قائمة التشغيل بنجاح!",
    "playlistUpdated": "تم تحديث قائمة التشغيل بنجاح!",
    "songAdded": "تمت إضافة الأغنية بنجاح!",
    "songRemoved": "تمت إزالة الأغنية بنجاح!",
    "songDeleted": "تم حذف الأغنية بنجاح!",
    "error": "خطأ",
    "warning": "تحذير",
    "info": "معلومات",
    "success": "نجاح",
    "confirm": "تأكيد",
    "areYouSure": "هل أنت متأكد؟",
    "unsavedChanges": "لديك تغييرات غير محفوظة. هل تريد المتابعة؟",
    "selectLanguage": "اختيار اللغة",
    "appLanguage": "لغة التطبيق",
    "englishLang": "English",
    "russianLang": "Русский",
    "romanianLang": "Română",
    "frenchLang": "Français",
    "germanLang": "Deutsch",
    "spanishLang": "Español",
    "welcomeToLingoTune": "مرحباً بك في LingoTune",
    "folderSetupMessage": "اختر مجلداً لتخزين الكلمات والترجمات (ملفات LRC و JSON). هذا يجعل من السهل تنظيم مكتبة الموسيقى الخاصة بك.",
    "selectFolderNow": "اختيار المجلد الآن",
    "goToSettings": "الذهاب إلى الإعدادات",
    "setupLater": "الإعداد لاحقاً",
    "useDefaultFolder": "استخدام المجلد الافتراضي",
    "databaseFound": "تم العثور على قاعدة بيانات في ملف الاستيراد",
    "importDatabaseQuestion": "هل تريد استيراد قاعدة البيانات أيضاً؟",
    "mergeDatabase": "دمج",
    "replaceDatabase": "استبدال",
    "importDatabase": "استيراد قاعدة البيانات",
    "skipDatabase": "تخطي قاعدة البيانات",
    "mergeDatabaseDescription": "دمج الأغاني المستوردة مع مكتبتك (إضافة عناصر جديدة فقط)",
    "replaceDatabaseDescription": "استبدال مكتبتك بالكامل بقاعدة البيانات المستوردة (ستفقد جميع البيانات الموجودة)",
    "exporting": "جاري التصدير...",
    "exportingProgress": "جاري تصدير {current} من أصل {total} أغنية",
    "exportDatabaseIncluded": "قاعدة البيانات مضمنة في التصدير",
    "importSuccessWithDatabase": "تم استيراد {fileCount} ملف (ملفات) وقاعدة بيانات",
    "importSuccessNoDatabase": "تم استيراد {fileCount} ملف (ملفات)",
    "ukrainianLang": "الأوكرانية"
}

# Chinese translations
zh_translations = {
    "lyricsFolder": "歌词文件夹",
    "useLyricsFolder": "使用歌词文件夹",
    "useLyricsFolderDisabled": "已禁用 - 必须与音频一起选择文件",
    "setLyricsFolder": "设置歌词文件夹",
    "selectFolder": "选择文件夹",
    "folderPath": "文件夹路径",
    "examples": "示例：",
    "defaultFolder": "默认：/LingoTune_Lyrics",
    "currentFolder": "当前文件夹：",
    "folderSetSuccessfully": "文件夹已设置：{path}",
    "folderSetFailed": "文件夹不存在或无法访问",
    "resetToDefault": "重置为默认",
    "showCurrentFolder": "显示当前文件夹",
    "changeFolder": "更改文件夹",
    "resetToDefaultFolder": "重置为默认文件夹",
    "folderReset": "重置为默认文件夹",
    "clearCache": "清除缓存",
    "clearCacheSubtitle": "清除临时文件",
    "cacheCleared": "缓存已清除",
    "resetSongLanguages": "重置歌曲语言",
    "resetSongLanguagesSubtitle": "使用设置中的默认语言",
    "songLanguagesReset": "歌曲语言已重置",
    "about": "关于",
    "translationsLoaded": "翻译加载成功！",
    "failedToLoadTranslations": "加载翻译失败：{error}",
    "editTranslations": "编辑翻译",
    "loadTranslationsFromFile": "从文件加载翻译",
    "loadTranslations": "加载翻译",
    "noFileSelected": "未选择文件",
    "noLrcFileAssociated": "此歌曲没有关联的LRC文件",
    "lrcFileSaved": "LRC文件保存成功！",
    "failedToSaveLrcFile": "保存LRC文件失败：{error}",
    "exitEditMode": "退出编辑模式",
    "editTimestamps": "编辑时间戳",
    "saveChanges": "保存更改",
    "language": "语言",
    "loading": "加载中...",
    "noSongsFound": "未找到歌曲",
    "noPlaylistsFound": "未找到播放列表",
    "selectSong": "选择要播放的歌曲",
    "song": "歌曲",
    "artist": "艺术家",
    "duration": "持续时间",
    "actions": "操作",
    "play": "播放",
    "pause": "暂停",
    "stop": "停止",
    "previous": "上一首",
    "next": "下一首",
    "rewind10": "-10秒",
    "forward10": "+10秒",
    "repeat": "重复",
    "shuffle": "随机",
    "volume": "音量",
    "speed": "速度",
    "lyrics": "歌词",
    "translations": "翻译",
    "originalText": "原文",
    "translatedText": "译文",
    "showTranscription": "显示音标",
    "showTranscriptionSubtitle": "显示发音指南",
    "showTranslationFirst": "翻译优先",
    "showTranslationFirstSubtitle": "在原文之前显示翻译",
    "italianLang": "Italiano",
    "portugueseLang": "Português",
    "lyricsEditor": "歌词编辑器",
    "addLine": "添加行",
    "updateLine": "更新行",
    "deleteLine": "删除行",
    "clearAll": "清除全部",
    "moveUp": "上移",
    "moveDown": "下移",
    "autoSyncLyrics": "自动同步歌词",
    "exportLrc": "导出LRC（原文）",
    "exportJson": "导出JSON（翻译）",
    "markTimestamp": "标记时间戳（回车）",
    "original": "原文",
    "translation": "翻译",
    "audioFile": "音频文件",
    "songTitle": "歌曲标题",
    "browse": "浏览",
    "audioControls": "音频控制",
    "addEditLine": "添加/编辑行",
    "instructions": "说明",
    "lyricsEditorInstructions": "LRC同步器说明：\\n\\n1. 使用浏览按钮选择音频文件\\n2. 输入歌曲标题和艺术家（可选）\\n3. 点击播放开始音频\\n4. 当一行被唱出时，在原文字段中输入原文\\n5. 按回车或点击标记时间戳记录时间戳\\n6. 可选地在翻译字段中添加翻译\\n7. 对每行重复步骤4-6\\n8. 使用导出LRC保存带有时间戳的原始歌词\\n9. 使用导出JSON保存翻译\\n\\n提示：\\n- 使用-10秒/+10秒快速导航歌曲\\n- 可以使用上移/下移重新排序行\\n- 加载先前保存的JSON文件以编辑翻译",
    "welcome": "欢迎",
    "welcomeMessage": "开始您的语言学习音乐之旅！",
    "importSongs": "导入歌曲",
    "importSongsSubtitle": "从您的设备添加音频文件",
    "manageLibrary": "管理库",
    "manageLibrarySubtitle": "组织您的歌曲和播放列表",
    "syncLyrics": "同步歌词",
    "syncLyricsSubtitle": "自动将歌词与音频同步",
    "languageLearning": "语言学习 • 音乐 • 翻译",
    "version": "版本",
    "developer": "开发人员",
    "website": "网站",
    "failedToCreatePlaylist": "创建播放列表失败：{error}",
    "playlistCreated": "播放列表创建成功！",
    "playlistDeleted": "播放列表删除成功！",
    "playlistUpdated": "播放列表更新成功！",
    "songAdded": "歌曲添加成功！",
    "songRemoved": "歌曲移除成功！",
    "songDeleted": "歌曲删除成功！",
    "error": "错误",
    "warning": "警告",
    "info": "信息",
    "success": "成功",
    "confirm": "确认",
    "areYouSure": "您确定吗？",
    "unsavedChanges": "您有未保存的更改。继续吗？",
    "selectLanguage": "选择语言",
    "appLanguage": "应用语言",
    "englishLang": "English",
    "russianLang": "Русский",
    "romanianLang": "Română",
    "frenchLang": "Français",
    "germanLang": "Deutsch",
    "spanishLang": "Español",
    "welcomeToLingoTune": "欢迎使用LingoTune",
    "folderSetupMessage": "选择一个文件夹来存储歌词和翻译（LRC和JSON文件）。这样可以轻松组织您的音乐库。",
    "selectFolderNow": "立即选择文件夹",
    "goToSettings": "转到设置",
    "setupLater": "稍后设置",
    "useDefaultFolder": "使用默认文件夹",
    "databaseFound": "在导入文件中找到数据库",
    "importDatabaseQuestion": "您也想导入数据库吗？",
    "mergeDatabase": "合并",
    "replaceDatabase": "替换",
    "importDatabase": "导入数据库",
    "skipDatabase": "跳过数据库",
    "mergeDatabaseDescription": "将导入的歌曲与您的库合并（仅添加新项目）",
    "replaceDatabaseDescription": "用导入的数据库替换您的整个库（您将丢失所有现有数据）",
    "exporting": "导出中...",
    "exportingProgress": "正在导出{total}首中的{current}首歌曲",
    "exportDatabaseIncluded": "导出中包含数据库",
    "importSuccessWithDatabase": "导入了{fileCount}个文件和数据库",
    "importSuccessNoDatabase": "导入了{fileCount}个文件",
    "ukrainianLang": "乌克兰语",
    "mainTextSize": "主文本大小",
    "mainTextBold": "主文本粗体",
    "translationSize": "翻译大小",
    "translationBold": "翻译粗体",
    "transcriptSize": "音标大小",
    "transcriptBold": "音标粗体",
    "serviceMessages": "服务消息",
    "serviceMessagesSubtitle": "显示有关翻译和音标的服务通知"
}

def update_language(language_code):
    """Update ARB file for specified language"""
    
    translations_map = {
        'ar': ar_translations,
        'zh': zh_translations,
    }
    
    if language_code not in translations_map:
        print(f"Error: Language '{language_code}' not supported")
        print("Supported languages: ar, zh")
        return False
    
    translations = translations_map[language_code]
    
    # Read English ARB as template
    with open(r'D:\ProjectAI\LingoTune\app\lib\l10n\app_en.arb', 'r', encoding='utf-8') as f:
        en_arb = json.load(f)
    
    # Read current ARB
    ar_file = f'D:\\ProjectAI\\LingoTune\\app\\lib\\l10n\\app_{language_code}.arb'
    with open(ar_file, 'r', encoding='utf-8') as f:
        current_arb = json.load(f)
    
    # Create complete ARB
    complete_arb = {
        "@@locale": language_code
    }
    
    # Copy all keys from English, using existing translations
    for key in en_arb:
        if key == "@@locale":
            continue
        if key in current_arb:
            complete_arb[key] = current_arb[key]
        elif key in translations:
            complete_arb[key] = translations[key]
        else:
            complete_arb[key] = en_arb[key]
    
    # Save complete ARB
    with open(ar_file, 'w', encoding='utf-8') as f:
        json.dump(complete_arb, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Successfully created complete {language_code.upper()} ARB file with {len(complete_arb)} keys")
    return True

def main():
    """Main function"""
    print("🌍 LingoTune Localization Updater")
    print("=" * 50)
    print()
    print("Supported languages:")
    print("  1. Arabic (ar)")
    print("  2. Chinese (zh)")
    print("  3. All languages")
    print()
    
    choice = input("Select language (1-3) [default: 3]: ").strip() or "3"
    
    if choice == "1":
        update_language('ar')
    elif choice == "2":
        update_language('zh')
    elif choice == "3":
        print()
        print("Updating all languages...")
        for lang in ['ar', 'zh']:
            print()
            print(f"Updating {lang}...")
            print("-" * 50)
            update_language(lang)
            print("-" * 50)
    else:
        print("Invalid choice")
    
    print()
    print("=" * 50)
    print("✅ Localization update completed!")
    print()

if __name__ == '__main__':
    main()
