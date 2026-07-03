#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
add_calibration_l10n.py — добавляет ключи локализации калибровки детектора
машин (v5.4.0) во все .arb файлы (11 языков) и сгенерированные
app_localizations*.dart (12 файлов).

Запуск:
    python scripts/add_calibration_l10n.py

Без зависимостей (только stdlib). Идемпотентный: повторный запуск добавит
только недостающие ключи.

35 ключей: 24 carCalibration* (UI) + 10 profileClass* (названия классов)
           + 1 carCalibrationSubtitle (для тайла в Настройках).
6 параметризованных: nearest/thresholdScore/recording/profilesCount/
                     deleteConfirm/demoLoaded.
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

# ---------------------------------------------------------------------------
# Конфигурация
# ---------------------------------------------------------------------------

L10N_DIR = Path(r"D:\Ai-LingoTune\app\lib\l10n")
LANGS: List[str] = ["en", "ru", "ro", "fr", "de", "es", "it", "pt", "zh", "ar", "uk"]


def _pc(values: List[str]) -> dict:
    """Helper: собрать словарь profileClass* по списку значений в порядке LANGS."""
    assert len(values) == len(LANGS), \
        f"Expected {len(LANGS)} values, got {len(values)}"
    return dict(zip(LANGS, values))


# ---------------------------------------------------------------------------
# Словарь ключей
#   "key": { "_params": [(name, type), ...],  # опционально
#            "en": "...", "ru": "...", ... }
# В .arb значения — ICU формат с {name}.
# В .dart — Dart-интерполяция с $name (получается из ICU преобразованием).
# ---------------------------------------------------------------------------

KEYS: Dict[str, dict] = {
    # ---- Заголовок и подзаголовок ----
    "carCalibrationTitle": {
        "en": "Detector calibration",
        "ru": "Калибровка детектора",
        "ro": "Calibrarea detectorului",
        "fr": "Calibrage du détecteur",
        "de": "Detektorkalibrierung",
        "es": "Calibración del detector",
        "it": "Calibrazione rilevatore",
        "pt": "Calibração do detector",
        "zh": "探测器校准",
        "ar": "معايرة الكاشف",
        "uk": "Калібрування детектора",
    },
    "carCalibrationSubtitle": {
        "en": "Train detector on your sounds",
        "ru": "Обучить детектор на ваших звуках",
        "ro": "Antrenează detectorul pe sunetele tale",
        "fr": "Entraînez le détecteur sur vos sons",
        "de": "Detektor mit deinen Sounds trainieren",
        "es": "Entrena el detector con tus sonidos",
        "it": "Allena il rilevatore sui tuoi suoni",
        "pt": "Treine o detector com seus sons",
        "zh": "用您的声音训练探测器",
        "ar": "درّب الكاشف على أصواتك",
        "uk": "Навчити детектор на ваших звуках",
    },
    "carCalibrationMicDenied": {
        "en": "Microphone permission denied — calibration impossible",
        "ru": "Нет доступа к микрофону — калибровка невозможна",
        "ro": "Acces la microfon refuzat — calibrare imposibilă",
        "fr": "Microphone refusé — calibrage impossible",
        "de": "Mikrofon verweigert — Kalibrierung nicht möglich",
        "es": "Micrófono denegado — calibración imposible",
        "it": "Microfono negato — calibrazione impossibile",
        "pt": "Microfone negado — calibração impossível",
        "zh": "麦克风权限被拒绝 — 无法校准",
        "ar": "تم رفض الميكروفون — لا يمكن المعايرة",
        "uk": "Немає доступу до мікрофона — калібрування неможливе",
    },
    # ---- Live-визуализация ----
    "carCalibrationLive": {
        "en": "Live spectrum",
        "ru": "Live-спектр",
        "ro": "Spectru live",
        "fr": "Spectre en direct",
        "de": "Live-Spektrum",
        "es": "Espectro en vivo",
        "it": "Spettro live",
        "pt": "Espectro ao vivo",
        "zh": "实时频谱",
        "ar": "الطيف المباشر",
        "uk": "Live-спектр",
    },
    "carCalibrationModeClassify": {
        "en": "Mode: classify",
        "ru": "Режим: классификация",
        "ro": "Mod: clasificare",
        "fr": "Mode : classification",
        "de": "Modus: Klassifikation",
        "es": "Modo: clasificar",
        "it": "Modalità: classifica",
        "pt": "Modo: classificar",
        "zh": "模式：分类",
        "ar": "الوضع: تصنيف",
        "uk": "Режим: класифікація",
    },
    "carCalibrationModeThreshold": {
        "en": "Mode: threshold",
        "ru": "Режим: пороги",
        "ro": "Mod: prag",
        "fr": "Mode : seuil",
        "de": "Modus: Schwellwert",
        "es": "Modo: umbral",
        "it": "Modalità: soglia",
        "pt": "Modo: limite",
        "zh": "模式：阈值",
        "ar": "الوضع: عتبة",
        "uk": "Режим: пороги",
    },
    "carCalibrationNearest": {
        "_params": [("cls", "String"), ("dist", "String")],
        "en": "Nearest: {cls} (d={dist})",
        "ru": "Ближайший: {cls} (d={dist})",
        "ro": "Cel mai apropiat: {cls} (d={dist})",
        "fr": "Le plus proche : {cls} (d={dist})",
        "de": "Nächste: {cls} (d={dist})",
        "es": "Más cercano: {cls} (d={dist})",
        "it": "Più vicino: {cls} (d={dist})",
        "pt": "Mais próximo: {cls} (d={dist})",
        "zh": "最近：{cls} (d={dist})",
        "ar": "الأقرب: {cls} (d={dist})",
        "uk": "Найближчий: {cls} (d={dist})",
    },
    "carCalibrationNoMatch": {
        "en": "No match",
        "ru": "Нет совпадения",
        "ro": "Nicio potrivire",
        "fr": "Pas de correspondance",
        "de": "Keine Übereinstimmung",
        "es": "Sin coincidencia",
        "it": "Nessuna corrispondenza",
        "pt": "Sem correspondência",
        "zh": "无匹配",
        "ar": "لا تطابق",
        "uk": "Немає збігу",
    },
    "carCalibrationThresholdScore": {
        "_params": [("score", "String")],
        "en": "Score: {score}",
        "ru": "Очки: {score}",
        "ro": "Scor: {score}",
        "fr": "Score : {score}",
        "de": "Wert: {score}",
        "es": "Puntuación: {score}",
        "it": "Punteggio: {score}",
        "pt": "Pontuação: {score}",
        "zh": "分数：{score}",
        "ar": "النتيجة: {score}",
        "uk": "Бали: {score}",
    },
    # ---- Запись эталона ----
    "carCalibrationRecordTitle": {
        "en": "Record sample",
        "ru": "Записать эталон",
        "ro": "Înregistrează eșantion",
        "fr": "Enregistrer un échantillon",
        "de": "Muster aufnehmen",
        "es": "Grabar muestra",
        "it": "Registra campione",
        "pt": "Gravar amostra",
        "zh": "录制样本",
        "ar": "تسجيل عينة",
        "uk": "Записати еталон",
    },
    "carCalibrationClass": {
        "en": "Class",
        "ru": "Класс",
        "ro": "Clasă",
        "fr": "Classe",
        "de": "Klasse",
        "es": "Clase",
        "it": "Classe",
        "pt": "Classe",
        "zh": "类别",
        "ar": "الفئة",
        "uk": "Клас",
    },
    "carCalibrationName": {
        "en": "Sample name",
        "ru": "Имя эталона",
        "ro": "Numele eșantionului",
        "fr": "Nom de l'échantillon",
        "de": "Mustername",
        "es": "Nombre de la muestra",
        "it": "Nome del campione",
        "pt": "Nome da amostra",
        "zh": "样本名称",
        "ar": "اسم العينة",
        "uk": "Ім'я еталону",
    },
    "carCalibrationRecord": {
        "en": "Record 5 sec",
        "ru": "Записать 5 сек",
        "ro": "Înregistrează 5 sec",
        "fr": "Enregistrer 5 s",
        "de": "5 Sek. aufnehmen",
        "es": "Grabar 5 s",
        "it": "Registra 5 sec",
        "pt": "Gravar 5 s",
        "zh": "录制 5 秒",
        "ar": "تسجيل 5 ثوانٍ",
        "uk": "Записати 5 сек",
    },
    "carCalibrationRecording": {
        "_params": [("s", "int")],
        "en": "Recording... {s}s",
        "ru": "Запись... {s} с",
        "ro": "Înregistrare... {s}s",
        "fr": "Enregistrement... {s}s",
        "de": "Aufnahme... {s}s",
        "es": "Grabando... {s}s",
        "it": "Registrazione... {s}s",
        "pt": "Gravando... {s}s",
        "zh": "录制中... {s}秒",
        "ar": "جارٍ التسجيل... {s}ث",
        "uk": "Запис... {s} з",
    },
    # ---- Список эталонов ----
    "carCalibrationProfilesCount": {
        "_params": [("n", "int")],
        "en": "Profiles ({n})",
        "ru": "Эталоны ({n})",
        "ro": "Profiluri ({n})",
        "fr": "Profils ({n})",
        "de": "Profile ({n})",
        "es": "Perfiles ({n})",
        "it": "Profili ({n})",
        "pt": "Perfis ({n})",
        "zh": "样本（{n}）",
        "ar": "الملفات الشخصية ({n})",
        "uk": "Еталони ({n})",
    },
    "carCalibrationEmpty": {
        "en": "No samples yet — record your first",
        "ru": "Эталонов нет — запишите первый",
        "ro": "Niciun eșantion — înregistrează primul",
        "fr": "Aucun échantillon — enregistrez le premier",
        "de": "Keine Muster — nimm das erste auf",
        "es": "Sin muestras — graba la primera",
        "it": "Nessun campione — registra il primo",
        "pt": "Sem amostras — grave a primeira",
        "zh": "暂无样本 — 录制第一个",
        "ar": "لا توجد عينات — سجل الأولى",
        "uk": "Еталонів немає — запишіть перший",
    },
    "carCalibrationDelete": {
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
    "carCalibrationDeleteConfirm": {
        "_params": [("name", "String")],
        "en": "Delete \"{name}\"?",
        "ru": "Удалить \"{name}\"?",
        "ro": "Ștergi \"{name}\"?",
        "fr": "Supprimer « {name} » ?",
        "de": "\"{name}\" löschen?",
        "es": "¿Eliminar \"{name}\"?",
        "it": "Eliminare \"{name}\"?",
        "pt": "Excluir \"{name}\"?",
        "zh": "删除\"{name}\"？",
        "ar": "حذف \"{name}\"؟",
        "uk": "Видалити \"{name}\"?",
    },
    "carCalibrationReset": {
        "en": "Reset all",
        "ru": "Сбросить всё",
        "ro": "Resetează tot",
        "fr": "Tout réinitialiser",
        "de": "Alle zurücksetzen",
        "es": "Restablecer todo",
        "it": "Ripristina tutto",
        "pt": "Redefinir tudo",
        "zh": "全部重置",
        "ar": "إعادة تعيين الكل",
        "uk": "Скинути все",
    },
    "carCalibrationResetConfirm": {
        "en": "Delete all calibration profiles?",
        "ru": "Удалить все эталоны?",
        "ro": "Ștergi toate profilurile de calibrare?",
        "fr": "Supprimer tous les profils de calibrage ?",
        "de": "Alle Kalibrierungsprofile löschen?",
        "es": "¿Eliminar todos los perfiles de calibración?",
        "it": "Eliminare tutti i profili di calibrazione?",
        "pt": "Excluir todos os perfis de calibração?",
        "zh": "删除所有校准配置文件？",
        "ar": "حذف جميع ملفات المعايرة؟",
        "uk": "Видалити всі еталони?",
    },
    "carCalibrationCancel": {
        "en": "Cancel",
        "ru": "Отмена",
        "ro": "Anulează",
        "fr": "Annuler",
        "de": "Abbrechen",
        "es": "Cancelar",
        "it": "Annulla",
        "pt": "Cancelar",
        "zh": "取消",
        "ar": "إلغاء",
        "uk": "Скасувати",
    },
    "carCalibrationConfirm": {
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
    "carCalibrationLoadDemo": {
        "en": "Load demo profiles",
        "ru": "Загрузить демо-эталоны",
        "ro": "Încarcă profiluri demo",
        "fr": "Charger profils démo",
        "de": "Demo-Profile laden",
        "es": "Cargar perfiles demo",
        "it": "Carica profili demo",
        "pt": "Carregar perfis demo",
        "zh": "加载示例配置",
        "ar": "تحميل ملفات تجريبية",
        "uk": "Завантажити демо-еталони",
    },
    "carCalibrationDemoPrefix": {
        "en": "Demo",
        "ru": "Демо",
        "ro": "Demo",
        "fr": "Démo",
        "de": "Demo",
        "es": "Demo",
        "it": "Demo",
        "pt": "Demo",
        "zh": "示例",
        "ar": "تجريبي",
        "uk": "Демо",
    },
    "carCalibrationDemoLoaded": {
        "_params": [("n", "int")],
        "en": "Loaded {n} demo profiles",
        "ru": "Загружено {n} демо-эталонов",
        "ro": "Încărcate {n} profiluri demo",
        "fr": "{n} profils démo chargés",
        "de": "{n} Demo-Profile geladen",
        "es": "{n} perfiles demo cargados",
        "it": "{n} profili demo caricati",
        "pt": "{n} perfis demo carregados",
        "zh": "已加载 {n} 个示例",
        "ar": "تم تحميل {n} ملفات تجريبية",
        "uk": "Завантажено {n} демо-еталонів",
    },
    # ---- 10 названий классов ----
    "profileClassCarClose": _pc(
        ["Car close", "Машина близко", "Mașină aproape", "Voiture proche",
         "Auto nah", "Coche cerca", "Auto vicina", "Carro perto",
         "近距离汽车", "سيارة قريبة", "Машина близько"]),
    "profileClassCarFar": _pc(
        ["Car far", "Машина далеко", "Mașină departe", "Voiture loin",
         "Auto fern", "Coche lejos", "Auto lontana", "Carro longe",
         "远距离汽车", "سيارة بعيدة", "Машина далеко"]),
    "profileClassCarTruck": _pc(
        ["Truck", "Грузовик", "Camion", "Camion", "LKW", "Camión",
         "Camion", "Caminhão", "卡车", "شاحنة", "Вантажівка"]),
    "profileClassCarMotorcycle": _pc(
        ["Motorcycle", "Мотоцикл", "Motocicletă", "Moto", "Motorrad",
         "Motocicleta", "Moto", "Moto", "摩托车", "دراجة نارية", "Мотоцикл"]),
    "profileClassWind": _pc(
        ["Wind", "Ветер", "Vânt", "Vent", "Wind", "Viento", "Vento",
         "Vento", "风", "رياح", "Вітер"]),
    "profileClassSteps": _pc(
        ["Steps", "Шаги", "Pași", "Pas", "Schritte", "Pasos", "Passi",
         "Passos", "脚步声", "خطوات", "Кроки"]),
    "profileClassVoice": _pc(
        ["Voice", "Голос", "Voce", "Voix", "Stimme", "Voz", "Voce",
         "Voz", "人声", "صوت", "Голос"]),
    "profileClassStreet": _pc(
        ["Street", "Улица", "Stradă", "Rue", "Straße", "Calle", "Strada",
         "Rua", "街道", "شارع", "Вулиця"]),
    "profileClassMusic": _pc(
        ["Music", "Музыка", "Muzică", "Musique", "Musik", "Música",
         "Musica", "Música", "音乐", "موسيقى", "Музика"]),
    "profileClassOther": _pc(
        ["Other", "Прочее", "Altele", "Autre", "Sonstiges", "Otro",
         "Altro", "Outro", "其他", "أخرى", "Інше"]),
}


# ---------------------------------------------------------------------------
# Утилиты
# ---------------------------------------------------------------------------

def escape_dart_string(s: str) -> str:
    """Экранирование одинарной кавычки для Dart-строки."""
    return s.replace("\\", "\\\\").replace("'", "\\'")


def dart_interpolate(template_arb: str, params: List[Tuple[str, str]]) -> str:
    """Преобразует ICU {name} → Dart ${name} (всегда фигурные скобки для
    безопасности — иначе '$s' + 's' = '$ss' воспринимается как переменная ss)."""
    s = escape_dart_string(template_arb)
    for name, _ in params:
        s = s.replace("{" + name + "}", "${" + name + "}")
    return s


def _format_signature(key: str, params: List[Tuple[str, str]]) -> str:
    """Dart-сигнатура: getter или метод."""
    if not params:
        return f"String get {key}"
    args = ", ".join(f"{ptype} {pname}" for pname, ptype in params)
    return f"String {key}({args})"


# ---------------------------------------------------------------------------
# 1. Обновление .arb файлов
# ---------------------------------------------------------------------------

def update_arb(lang: str) -> int:
    """Добавляет недостающие ключи в app_<lang>.arb. Возвращает кол-во добавленных."""
    path = L10N_DIR / f"app_{lang}.arb"
    if not path.exists():
        print(f"⚠ ARB file not found: {path}")
        return 0
    text = path.read_text(encoding="utf-8")
    try:
        data = json.loads(text)
    except json.JSONDecodeError as e:
        print(f"✗ {path.name}: invalid JSON ({e})")
        return 0

    added = 0
    for key, meta in KEYS.items():
        if key in data:
            continue
        if lang not in meta:
            print(f"⚠ {key}: no translation for '{lang}', skipping")
            continue
        data[key] = meta[lang]
        added += 1
        params = meta.get("_params")
        if params:
            placeholders = {pname: {"type": ptype} for pname, ptype in params}
            data["@" + key] = {"placeholders": placeholders}

    if added == 0:
        print(f"✓ {path.name}: up-to-date")
        return 0

    # Сериализация с 6-пробельным отступом (как в оригиналах).
    pad = "      "
    items = []
    for k, v in data.items():
        key_repr = json.dumps(k, ensure_ascii=False)
        val_repr = json.dumps(v, ensure_ascii=False)
        items.append(f"{pad}{key_repr}: {val_repr}")
    out = "{\n" + ",\n".join(items) + "\n}\n"
    path.write_text(out, encoding="utf-8")
    print(f"✓ {path.name}: +{added} keys")
    return added


# ---------------------------------------------------------------------------
# 2. Обновление app_localizations.dart (abstract)
# ---------------------------------------------------------------------------

def update_dart_abstract() -> int:
    """Добавляет abstract-геттеры/методы в app_localizations.dart."""
    path = L10N_DIR / "app_localizations.dart"
    content = path.read_text(encoding="utf-8")

    # Найти тело класса AppLocalizations: от объявления до первой `}` на
    # новой строке без отступа (конец класса).
    m = re.search(r"(abstract class AppLocalizations\b.*?)(^\})",
                  content, re.MULTILINE | re.DOTALL)
    if not m:
        print(f"✗ {path.name}: cannot find class AppLocalizations")
        return 0
    class_body = m.group(1)
    end_pos = m.start(2)

    to_add = []
    for key, meta in KEYS.items():
        params = meta.get("_params", [])
        sig = _format_signature(key, params)
        # Пропускаем, если сигнатура уже присутствует (с необяз. пробелами/;).
        if re.search(re.escape(sig) + r"\s*;", class_body):
            continue
        to_add.append((key, meta))

    if not to_add:
        print(f"✓ {path.name}: up-to-date")
        return 0

    blocks = []
    for key, meta in to_add:
        params = meta.get("_params", [])
        sig = _format_signature(key, params)
        en_val = meta.get("en", "")
        en_repr = json.dumps(en_val, ensure_ascii=False)
        blocks.append(
            f"  /// No description provided for @{key}.\n"
            f"  ///\n"
            f"  /// In en, this message translates to:\n"
            f"  /// **{en_repr}**\n"
            f"  {sig};"
        )
    insert = "\n".join(blocks) + "\n"
    new_content = content[:end_pos] + insert + content[end_pos:]
    path.write_text(new_content, encoding="utf-8")
    print(f"✓ {path.name}: +{len(to_add)} abstract members")
    return len(to_add)


# ---------------------------------------------------------------------------
# 3. Обновление app_localizations_<lang>.dart (конкретные реализации)
# ---------------------------------------------------------------------------

def update_dart_lang(lang: str) -> int:
    """Добавляет override-имплементации в app_localizations_<lang>.dart."""
    path = L10N_DIR / f"app_localizations_{lang}.dart"
    content = path.read_text(encoding="utf-8")
    lang_title = lang[0].upper() + lang[1:]
    # class AppLocalizationsRu extends AppLocalizations { ... }
    m = re.search(
        rf"(class AppLocalizations{lang_title}\b[^{{]*?\{{.*?)(^\}})",
        content, re.MULTILINE | re.DOTALL,
    )
    if not m:
        print(f"✗ {path.name}: cannot find class AppLocalizations{lang_title}")
        return 0
    class_body = m.group(1)
    end_pos = m.start(2)

    to_add = []
    for key, meta in KEYS.items():
        if lang not in meta:
            continue
        params = meta.get("_params", [])
        sig = _format_signature(key, params)
        # Проверяем что такой сигнатуры ещё нет.
        if params:
            # Метод: ищем "String key(" — признак определения.
            if re.search(rf"\bString\s+{re.escape(key)}\s*\(", class_body):
                continue
        else:
            if re.search(rf"\bString\s+get\s+{re.escape(key)}\b", class_body):
                continue
        to_add.append((key, meta))

    if not to_add:
        print(f"✓ {path.name}: up-to-date")
        return 0

    blocks = []
    for key, meta in to_add:
        params = meta.get("_params", [])
        template = meta[lang]
        if params:
            args = ", ".join(f"{ptype} {pname}" for pname, ptype in params)
            value = dart_interpolate(template, params)
            blocks.append(
                f"  @override\n"
                f"  String {key}({args}) {{\n"
                f"    return '{value}';\n"
                f"  }}"
            )
        else:
            value = escape_dart_string(template)
            blocks.append(
                f"  @override\n"
                f"  String get {key} => '{value}';"
            )
    insert = "\n".join(blocks) + "\n"
    new_content = content[:end_pos] + insert + content[end_pos:]
    path.write_text(new_content, encoding="utf-8")
    print(f"✓ {path.name}: +{len(to_add)} members")
    return len(to_add)


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main() -> None:
    print("=== add_calibration_l10n.py ===")
    print(f"L10N dir: {L10N_DIR}")
    n_param = sum(1 for k in KEYS if KEYS[k].get("_params"))
    print(f"Keys: {len(KEYS)} ({n_param} parameterized)")
    print(f"Langs: {', '.join(LANGS)}")
    print()

    total_arb = sum(update_arb(lang) for lang in LANGS)
    print()
    n_abs = update_dart_abstract()
    print()
    total_dart = sum(update_dart_lang(lang) for lang in LANGS)

    print(f"\nDone. ARB additions: {total_arb}, "
          f"abstract: {n_abs}, lang-impl: {total_dart}")


if __name__ == "__main__":
    main()
