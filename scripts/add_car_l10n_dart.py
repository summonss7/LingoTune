"""Regenerate the car-detection getters in app_localizations*.dart files.

LingoTune keeps the generated AppLocalizations files checked into lib/l10n
(no gen step at build time), so adding a key to .arb is only half the work —
the corresponding getters must be appended to:

- app_localizations.dart        (abstract getters)
- app_localizations_<lang>.dart (concrete overrides, one per language)
"""
import json
import re
from pathlib import Path

L10N_DIR = Path(r"D:\LingoTune\app\lib\l10n")
LANGS = ["en", "ru", "ro", "fr", "de", "es", "it", "pt", "zh", "ar", "uk"]
CAR_KEYS = [
    "carDetectionTitle",
    "carDetectionEnabled",
    "carDetectionDisabled",
    "carDetectionSensitivity",
    "carDetectionSensitivityHint",
    "carDetectionSensitivityHint",
    "carAlertSound",
    "carAlertSoundSubtitle",
    "carAlertVibration",
    "carAlertVibrationSubtitle",
    "carAlertVoice",
    "carAlertVoiceSubtitle",
    "carDetectionPrivacyNote",
    "carDetectionTooltip",
    "carDetectionStarted",
    "carDetectionMicDenied",
]
# Уникальные ключи в порядке добавления.
UNIQUE_KEYS: list[str] = []
for k in CAR_KEYS:
    if k not in UNIQUE_KEYS:
        UNIQUE_KEYS.append(k)


def escape_dart_string(s: str) -> str:
    """Экранирует строку для Dart single-quoted string literal."""
    return s.replace("\\", "\\\\").replace("'", "\\'")


def load_arb(lang: str) -> dict:
    path = L10N_DIR / f"app_{lang}.arb"
    return json.loads(path.read_text(encoding="utf-8"))


def update_abstract() -> int:
    """Добавляет абстрактные геттеры в app_localizations.dart перед
    последней закрывающей скобкой класса."""
    path = L10N_DIR / "app_localizations.dart"
    text = path.read_text(encoding="utf-8")

    en = load_arb("en")
    existing = set(re.findall(r"String get (\w+)", text))

    parts: list[str] = []
    for key in UNIQUE_KEYS:
        if key in existing:
            continue
        val = en.get(key, "")
        parts.append(
            "\n"
            f"  /// No description provided for @{key}.\n"
            "  ///\n"
            "  /// In en, this message translates to:\n"
            f"  /// **'{escape_dart_string(val)}'**\n"
            f"  String get {key};\n"
        )

    if not parts:
        return 0

    # Находим последний `String get ...;` перед закрывающей `}` класса.
    # Класс заканчивается первой `\n}` после последнего геттера.
    last_getter = re.findall(r"  String get \w+;", text)
    if not last_getter:
        return 0
    last = last_getter[-1]
    idx = text.rfind(last) + len(last)
    head = text[:idx]
    tail = text[idx:]
    new_text = head + "\n" + "\n".join(p.strip() for p in parts) + tail
    path.write_text(new_text, encoding="utf-8")
    return len(parts)


def update_lang(lang: str) -> int:
    """Добавляет конкретные геттеры в app_localizations_<lang>.dart."""
    path = L10N_DIR / f"app_localizations_{lang}.dart"
    text = path.read_text(encoding="utf-8")

    arb = load_arb(lang)
    existing = set(re.findall(r"String get (\w+)", text))

    parts: list[str] = []
    for key in UNIQUE_KEYS:
        if key in existing:
            continue
        val = arb.get(key, "")
        parts.append(
            f"  @override\n"
            f"  String get {key} => '{escape_dart_string(val)}';\n"
        )

    if not parts:
        return 0

    # Найти последний `String get ... => ...;` перед `\n}`.
    last_getter = re.findall(r"  String get \w+ => .*?;\n", text)
    if not last_getter:
        return 0
    last = last_getter[-1]
    idx = text.rfind(last) + len(last)
    head = text[:idx]
    tail = text[idx:]
    new_text = head + "\n".join(parts) + tail
    path.write_text(new_text, encoding="utf-8")
    return len(parts)


def main() -> None:
    n_abs = update_abstract()
    print(f"app_localizations.dart: +{n_abs} getters")
    for lang in LANGS:
        n = update_lang(lang)
        print(f"  app_localizations_{lang}.dart: +{n} getters")


if __name__ == "__main__":
    main()
