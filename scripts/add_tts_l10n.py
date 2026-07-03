"""Add offline-TTS localization keys to all 11 .arb files.

Generates keys for:
  - ttsSource + 5 related strings (источник озвучки: офлайн/система)
  - voicePackages + 13 related strings (управление моделями: статусы, кнопки)

Each key has translations for 11 languages: en, ru, ro, fr, de, es, it, pt, zh,
ar, uk. Three keys are parameterised (placeholder {lang}) — these get an
@"-prefixed metadata entry with placeholders info so flutter gen-l10n
generates the correct method signature.

Idempotent: skips keys already present. Preserves the .arb's 6-space indent
and JSON validity.
"""
import json
from pathlib import Path

L10N_DIR = Path(r"D:\Ai-LingoTune\app\lib\l10n")
INDENT = "      "  # 6 spaces, как в существующих .arb
LANGS = ("en", "ru", "ro", "fr", "de", "es", "it", "pt", "zh", "ar", "uk")

# (key, {lang: translation}). Порядок ключей = порядок вставки в .arb.
KEYS = {
    # === Источник TTS ===
    "ttsSource": {
        "en": "TTS source",
        "ru": "Источник озвучки",
        "ro": "Sursă TTS",
        "fr": "Source TTS",
        "de": "TTS-Quelle",
        "es": "Fuente TTS",
        "it": "Sorgente TTS",
        "pt": "Fonte TTS",
        "zh": "TTS来源",
        "ar": "مصدر النطق",
        "uk": "Джерело озвучки",
    },
    "ttsSourceOffline": {
        "en": "Offline",
        "ru": "Офлайн",
        "ro": "Offline",
        "fr": "Hors ligne",
        "de": "Offline",
        "es": "Sin conexión",
        "it": "Offline",
        "pt": "Offline",
        "zh": "离线",
        "ar": "دون اتصال",
        "uk": "Офлайн",
    },
    "ttsSourceSystem": {
        "en": "System",
        "ru": "Системный",
        "ro": "Sistem",
        "fr": "Système",
        "de": "System",
        "es": "Sistema",
        "it": "Sistema",
        "pt": "Sistema",
        "zh": "系统",
        "ar": "النظام",
        "uk": "Системний",
    },
    "ttsSourceOfflineSubtitle": {
        "en": "Built-in neural TTS (recommended, stable on all devices)",
        "ru": "Встроенный нейро-TTS (рекомендуется, стабильно на всех устройствах)",
        "ro": "TTS neural integrat (recomandat, stabil pe toate dispozitivele)",
        "fr": "TTS neuronal intégré (recommandé, stable sur tous les appareils)",
        "de": "Eingebautes neuronales TTS (empfohlen, stabil auf allen Geräten)",
        "es": "TTS neuronal integrado (recomendado, estable en todos los dispositivos)",
        "it": "TTS neurale integrato (consigliato, stabile su tutti i dispositivi)",
        "pt": "TTS neural integrado (recomendado, estável em todos os dispositivos)",
        "zh": "内置神经TTS（推荐，在所有设备上稳定）",
        "ar": "نطق عصبي مدمج (موصى به، مستقر على جميع الأجهزة)",
        "uk": "Вбудований нейро-TTS (рекомендовано, стабільно на всіх пристроях)",
    },
    "ttsSourceSystemSubtitle": {
        "en": "Android system TTS engine",
        "ru": "Системный движок Android",
        "ro": "Motor TTS de sistem Android",
        "fr": "Moteur TTS système Android",
        "de": "Android-System-TTS-Engine",
        "es": "Motor TTS del sistema Android",
        "it": "Motore TTS di sistema Android",
        "pt": "Motor TTS do sistema Android",
        "zh": "Android系统TTS引擎",
        "ar": "محرك النطق الخاص بنظام أندرويد",
        "uk": "Системний рушій TTS Android",
    },
    "ttsSourceSwitchedHint": {
        "en": "TTS source switched",
        "ru": "Источник озвучки переключён",
        "ro": "Sursa TTS a fost schimbată",
        "fr": "Source TTS modifiée",
        "de": "TTS-Quelle gewechselt",
        "es": "Fuente TTS cambiada",
        "it": "Sorgente TTS cambiata",
        "pt": "Fonte TTS alterada",
        "zh": "TTS来源已切换",
        "ar": "تم تغيير مصدر النطق",
        "uk": "Джерело озвучки змінено",
    },
    # === Голосовые пакеты ===
    "voicePackages": {
        "en": "Voice packages",
        "ru": "Голосовые пакеты",
        "ro": "Pachete vocale",
        "fr": "Paquets vocaux",
        "de": "Sprachpakete",
        "es": "Paquetes de voz",
        "it": "Pacchetti vocali",
        "pt": "Pacotes de voz",
        "zh": "语音包",
        "ar": "حزم الأصوات",
        "uk": "Голосові пакети",
    },
    "voicePackagesSubtitle": {
        "en": "Offline TTS models for languages",
        "ru": "Офлайн-TTS модели для языков",
        "ro": "Modele TTS offline pentru limbi",
        "fr": "Modèles TTS hors ligne pour les langues",
        "de": "Offline-TTS-Modelle für Sprachen",
        "es": "Modelos TTS sin conexión para idiomas",
        "it": "Modelli TTS offline per le lingue",
        "pt": "Modelos TTS offline para idiomas",
        "zh": "语言的离线TTS模型",
        "ar": "نماذج نطق دون اتصال للغات",
        "uk": "Офлайн-моделі TTS для мов",
    },
    "voicePackagesDescription": {
        "en": "Download offline neural TTS models so speech works without "
              "internet and stays stable on any device. The Russian model is "
              "bundled with the app; others can be downloaded here.",
        "ru": "Скачивайте офлайн-нейро TTS модели, чтобы озвучка работала без "
              "интернета и была стабильной на любом устройстве. Русская модель "
              "встроена в приложение; остальные можно скачать здесь.",
        "ro": "Descarcă modele TTS neurale offline pentru ca vorbirea să "
              "funcționeze fără internet și să fie stabilă pe orice "
              "dispozitiv. Modelul rus este inclus în aplicație; restul pot "
              "fi descărcate aici.",
        "fr": "Téléchargez des modèles TTS neuronaux hors ligne pour que la "
              "synthèse fonctionne sans internet et reste stable sur tout "
              "appareil. Le modèle russe est inclus ; les autres peuvent être "
              "téléchargés ici.",
        "de": "Lade neuronale Offline-TTS-Modelle herunter, damit die "
              "Sprachausgabe ohne Internet funktioniert und auf jedem Gerät "
              "stabil bleibt. Das russische Modell ist enthalten; andere "
              "können hier heruntergeladen werden.",
        "es": "Descarga modelos TTS neuronales sin conexión para que el habla "
              "funcione sin internet y sea estable en cualquier dispositivo. "
              "El modelo ruso está incluido; los demás se pueden descargar aquí.",
        "it": "Scarica modelli TTS neurali offline affinché la sintesi vocale "
              "funzioni senza internet e rimanga stabile su qualsiasi "
              "dispositivo. Il modello russo è incluso; gli altri possono "
              "essere scaricati qui.",
        "pt": "Baixe modelos TTS neurais offline para que a fala funcione sem "
              "internet e permaneça estável em qualquer dispositivo. O modelo "
              "russo está incluído; os outros podem ser baixados aqui.",
        "zh": "下载离线神经TTS模型，使语音功能在没有互联网时仍可工作，并在任何设备上保持稳定。"
              "俄语模型已内置；其他模型可在此下载。",
        "ar": "حمّل نماذج النطق العصبية دون اتصال ليعمل النطق بدون إنترنت ويبقى "
              "مستقراً على أي جهاز. النموذج الروسي مضمّن في التطبيق؛ يمكن تحميل "
              "الباقي هنا.",
        "uk": "Завантажуйте офлайн-нейро моделі TTS, щоб озвучка працювала без "
              "інтернету та була стабільною на будь-якому пристрої. Російська "
              "модель вбудована; інші можна завантажити тут.",
    },
    "voicePackageReady": {
        "en": "Ready",
        "ru": "Готово",
        "ro": "Gata",
        "fr": "Prêt",
        "de": "Bereit",
        "es": "Listo",
        "it": "Pronto",
        "pt": "Pronto",
        "zh": "就绪",
        "ar": "جاهز",
        "uk": "Готово",
    },
    "voicePackageBundled": {
        "en": "Bundled with the app",
        "ru": "Встроен в приложение",
        "ro": "Inclus în aplicație",
        "fr": "Inclus avec l'application",
        "de": "In der App enthalten",
        "es": "Incluido con la aplicación",
        "it": "Incluso nell'app",
        "pt": "Incluído no aplicativo",
        "zh": "已随应用内置",
        "ar": "مضمّن مع التطبيق",
        "uk": "Вбудовано в додаток",
    },
    "voicePackageDownload": {
        "en": "Download",
        "ru": "Скачать",
        "ro": "Descarcă",
        "fr": "Télécharger",
        "de": "Herunterladen",
        "es": "Descargar",
        "it": "Scarica",
        "pt": "Baixar",
        "zh": "下载",
        "ar": "تحميل",
        "uk": "Завантажити",
    },
    "voicePackageInstall": {
        "en": "Install",
        "ru": "Установить",
        "ro": "Instalează",
        "fr": "Installer",
        "de": "Installieren",
        "es": "Instalar",
        "it": "Installa",
        "pt": "Instalar",
        "zh": "安装",
        "ar": "تثبيت",
        "uk": "Встановити",
    },
    "voicePackageRetry": {
        "en": "Retry",
        "ru": "Повторить",
        "ro": "Reîncearcă",
        "fr": "Réessayer",
        "de": "Erneut versuchen",
        "es": "Reintentar",
        "it": "Riprova",
        "pt": "Tentar novamente",
        "zh": "重试",
        "ar": "إعادة المحاولة",
        "uk": "Спробувати знову",
    },
    "voicePackageDownloading": {
        "en": "Downloading...",
        "ru": "Скачивается...",
        "ro": "Se descarcă...",
        "fr": "Téléchargement...",
        "de": "Wird heruntergeladen...",
        "es": "Descargando...",
        "it": "Scaricamento...",
        "pt": "Baixando...",
        "zh": "下载中...",
        "ar": "جارٍ التحميل...",
        "uk": "Завантаження...",
    },
    "voicePackageExtracting": {
        "en": "Extracting...",
        "ru": "Распаковывается...",
        "ro": "Se extrage...",
        "fr": "Extraction...",
        "de": "Wird entpackt...",
        "es": "Extrayendo...",
        "it": "Estrazione...",
        "pt": "Extraindo...",
        "zh": "解压中...",
        "ar": "جارٍ الاستخراج...",
        "uk": "Розпаковується...",
    },
    "voicePackageError": {
        "en": "Error",
        "ru": "Ошибка",
        "ro": "Eroare",
        "fr": "Erreur",
        "de": "Fehler",
        "es": "Error",
        "it": "Errore",
        "pt": "Erro",
        "zh": "错误",
        "ar": "خطأ",
        "uk": "Помилка",
    },
    "voicePackageDelete": {
        "en": "Delete",
        "ru": "Удалить",
        "ro": "Șterge",
        "fr": "Supprimer",
        "de": "Löschen",
        "es": "Eliminar",
        "it": "Elimina",
        "pt": "Excluir",
        "zh": "删除",
        "ar": "حذف",
        "uk": "Видалити",
    },
    # === Параметризованные (с {lang}) ===
    "voicePackageInstalledSuccess": {
        "en": "Model for \"{lang}\" installed",
        "ru": "Модель для \"{lang}\" установлена",
        "ro": "Modelul pentru \"{lang}\" a fost instalat",
        "fr": "Modèle pour « {lang} » installé",
        "de": "Modell für \"{lang}\" installiert",
        "es": "Modelo para \"{lang}\" instalado",
        "it": "Modello per \"{lang}\" installato",
        "pt": "Modelo para \"{lang}\" instalado",
        "zh": "已安装\"{lang}\"的模型",
        "ar": "تم تثبيت نموذج \"{lang}\"",
        "uk": "Модель для \"{lang}\" встановлено",
    },
    "voicePackageInstalledFailed": {
        "en": "Failed to install model for \"{lang}\"",
        "ru": "Не удалось установить модель для \"{lang}\"",
        "ro": "Nu s-a putut instala modelul pentru \"{lang}\"",
        "fr": "Échec d'installation du modèle pour « {lang} »",
        "de": "Installation des Modells für \"{lang}\" fehlgeschlagen",
        "es": "Error al instalar el modelo para \"{lang}\"",
        "it": "Installazione del modello per \"{lang}\" fallita",
        "pt": "Falha ao instalar o modelo para \"{lang}\"",
        "zh": "安装\"{lang}\"的模型失败",
        "ar": "فشل تثبيت نموذج \"{lang}\"",
        "uk": "Не вдалося встановити модель для \"{lang}\"",
    },
    "voicePackageDeleteConfirm": {
        "en": "Delete model for \"{lang}\"? This frees up disk space.",
        "ru": "Удалить модель для \"{lang}\"? Это освободит место на диске.",
        "ro": "Ștergi modelul pentru \"{lang}\"? Asta va elibera spațiu pe disc.",
        "fr": "Supprimer le modèle pour « {lang} » ? Cela libère de l'espace.",
        "de": "Modell für \"{lang}\" löschen? Das gibt Speicherplatz frei.",
        "es": "¿Eliminar el modelo para \"{lang}\"? Esto libera espacio.",
        "it": "Eliminare il modello per \"{lang}\"? Libera spazio su disco.",
        "pt": "Excluir o modelo para \"{lang}\"? Isso libera espaço.",
        "zh": "删除\"{lang}\"的模型？这将释放磁盘空间。",
        "ar": "حذف نموذج \"{lang}\"؟ سيؤدي ذلك إلى تحرير مساحة.",
        "uk": "Видалити модель для \"{lang}\"? Це звільнить місце на диску.",
    },
}

# Метаданные для параметризованных ключей (@-префикс в .arb).
# Формат: "@key": {"placeholders": {"param": {}}}
METADATA = {
    "@voicePackageInstalledSuccess": {"placeholders": {"lang": {}}},
    "@voicePackageInstalledFailed": {"placeholders": {"lang": {}}},
    "@voicePackageDeleteConfirm": {"placeholders": {"lang": {}}},
}

# Порядок вставки: обычные ключи, после — @-метаданные НЕ вставляем как
# отдельные элементы, они идут перед соответствующим ключом. Поэтому
# формируем последовательность пар (key, value_json_str) с правильным
# порядком: @metadata перед значением.
PARAMETERIZED = {"voicePackageInstalledSuccess",
                 "voicePackageInstalledFailed",
                 "voicePackageDeleteConfirm"}


def escape_json_string(s: str) -> str:
    """Escape a Python string for embedding inside a JSON string literal."""
    # JSON requires escaping: " \ and control chars. Newlines → \n.
    out = []
    for ch in s:
        if ch == '"':
            out.append('\\"')
        elif ch == '\\':
            out.append('\\\\')
        elif ch == '\n':
            out.append('\\n')
        elif ch == '\r':
            out.append('\\r')
        elif ch == '\t':
            out.append('\\t')
        else:
            out.append(ch)
    return ''.join(out)


def build_entries_for_lang(lang: str, existing_keys: set[str]) -> list[tuple[str, str]]:
    """Build (key, json_value_string) pairs to insert, in correct order.

    Returns only pairs whose key isn't already present.
    """
    pairs: list[tuple[str, str]] = []
    for key, translations in KEYS.items():
        # Сначала @-метадата (если параметризованный), потом сам ключ.
        if key in PARAMETERIZED:
            mkey = f"@{key}"
            if mkey not in existing_keys:
                meta_json = json.dumps(METADATA[mkey], ensure_ascii=False)
                pairs.append((mkey, meta_json))
        if key not in existing_keys:
            pairs.append((key, f'"{escape_json_string(translations[lang])}"'))
    return pairs


def update_arb(lang: str) -> int:
    path = L10N_DIR / f"app_{lang}.arb"
    text = path.read_text(encoding="utf-8")
    existing = set(json.loads(text).keys())
    to_add = build_entries_for_lang(lang, existing)
    if not to_add:
        return 0

    # Найдём позицию закрывающей }. ARB формат: ...,\n  "last": "x"\n}
    close_idx = text.rfind("}")
    head = text[:close_idx].rstrip()
    parts = []
    for i, (k, v) in enumerate(to_add):
        suffix = "," if i < len(to_add) - 1 else ""
        parts.append(f'{INDENT}"{k}": {v}{suffix}')
    if head.endswith("{"):
        # Пустой объект (не должно быть в наших arb) — без ведущей запятой.
        new_text = head + "\n" + "\n".join(parts) + "\n" + text[close_idx:]
    else:
        new_text = head + ",\n" + "\n".join(parts) + "\n" + text[close_idx:]

    path.write_text(new_text, encoding="utf-8")
    return len(to_add)


def main() -> None:
    total = 0
    for lang in LANGS:
        n = update_arb(lang)
        print(f"  {lang}: +{n} entries")
        total += n
    print(f"Total entries added: {total}")


if __name__ == "__main__":
    main()
