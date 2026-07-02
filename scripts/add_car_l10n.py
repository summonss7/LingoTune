"""Add car-detection localization keys to all 11 .arb files.

Minimal-edit approach: parse the existing JSON to detect which keys are already
present, then insert the new keys right before the closing ``}`` while keeping
the original formatting of existing entries. This preserves the file's ordering
and indentation style used by LingoTune's .arb files.
"""
import json
import re
from pathlib import Path

L10N_DIR = Path(r"D:\Ai-LingoTune\app\lib\l10n")
INDENT = "      "  # 6 spaces, как в существующих .arb

KEYS = {
    "carDetectionTitle": {
        "en": "Car Detection",
        "ru": "Детекция машин",
        "ro": "Detecție mașini",
        "fr": "Détection de voitures",
        "de": "Autoerkennung",
        "es": "Detección de coches",
        "it": "Rilevamento auto",
        "pt": "Detecção de carros",
        "zh": "汽车检测",
        "ar": "كشف السيارات",
        "uk": "Детекція машин",
    },
    "carDetectionEnabled": {
        "en": "Enabled",
        "ru": "Включено",
        "ro": "Activat",
        "fr": "Activé",
        "de": "Aktiviert",
        "es": "Activado",
        "it": "Attivo",
        "pt": "Ativado",
        "zh": "已启用",
        "ar": "مفعّل",
        "uk": "Увімкнено",
    },
    "carDetectionDisabled": {
        "en": "Disabled",
        "ru": "Выключено",
        "ro": "Dezactivat",
        "fr": "Désactivé",
        "de": "Deaktiviert",
        "es": "Desactivado",
        "it": "Disattivo",
        "pt": "Desativado",
        "zh": "已停用",
        "ar": "غير مفعّل",
        "uk": "Вимкнено",
    },
    "carDetectionSensitivity": {
        "en": "Sensitivity",
        "ru": "Чувствительность",
        "ro": "Sensibilitate",
        "fr": "Sensibilité",
        "de": "Empfindlichkeit",
        "es": "Sensibilidad",
        "it": "Sensibilità",
        "pt": "Sensibilidade",
        "zh": "灵敏度",
        "ar": "الحساسية",
        "uk": "Чутливість",
    },
    "carDetectionSensitivityHint": {
        "en": "Higher = more alerts (may cause false positives). Lower = only strong signals.",
        "ru": "Выше = больше срабатываний (возможны ложные). Ниже = только сильные сигналы.",
        "ro": "Mai sus = mai multe alerte (posibile alarme false). Mai jos = doar semnale puternice.",
        "fr": "Plus haut = plus d'alertes (faux positifs possibles). Plus bas = signaux forts uniquement.",
        "de": "Höher = mehr Alarme (Fehlalarme möglich). Niedriger = nur starke Signale.",
        "es": "Más alto = más alertas (posibles falsos positivos). Más bajo = solo señales fuertes.",
        "it": "Più alto = più allerte (possibili falsi positivi). Più basso = solo segnali forti.",
        "pt": "Maior = mais alertas (possíveis falsos positivos). Menor = apenas sinais fortes.",
        "zh": "越高 = 越多警报（可能误报）。越低 = 仅强信号。",
        "ar": "أعلى = تنبيهات أكثر (قد تسبب إنذارات كاذبة). أقل = إشارات قوية فقط.",
        "uk": "Вище = більше спрацьовувань (можливі хибні). Нижче = лише сильні сигнали.",
    },
    "carAlertSound": {
        "en": "Sound alert",
        "ru": "Звуковое предупреждение",
        "ro": "Alertă sonoră",
        "fr": "Alerte sonore",
        "de": "Ton-Warnung",
        "es": "Alerta sonora",
        "it": "Allerta sonora",
        "pt": "Alerta sonoro",
        "zh": "声音警报",
        "ar": "تنبيه صوتي",
        "uk": "Звукове попередження",
    },
    "carAlertSoundSubtitle": {
        "en": "Beep over the music",
        "ru": "Сигнал поверх музыки",
        "ro": "Bip peste muzică",
        "fr": "Bip par-dessus la musique",
        "de": "Signalton über der Musik",
        "es": "Pitido sobre la música",
        "it": "Bip sopra la musica",
        "pt": "Bipe sobre a música",
        "zh": "在音乐上发出哔声",
        "ar": "صفير فوق الموسيقى",
        "uk": "Сигнал поверх музики",
    },
    "carAlertVibration": {
        "en": "Vibration alert",
        "ru": "Вибрация",
        "ro": "Vibrație",
        "fr": "Vibration",
        "de": "Vibration",
        "es": "Vibración",
        "it": "Vibrazione",
        "pt": "Vibração",
        "zh": "振动警报",
        "ar": "تنبيه بالاهتزاز",
        "uk": "Вібрація",
    },
    "carAlertVibrationSubtitle": {
        "en": "Haptic feedback on detection",
        "ru": "Тактильная отдача при детекции",
        "ro": "Feedback haptic la detecție",
        "fr": "Retour haptique lors de la détection",
        "de": "Haptisches Feedback bei Erkennung",
        "es": "Respuesta háptica al detectar",
        "it": "Feedback aptico al rilevamento",
        "pt": "Feedback háptico na detecção",
        "zh": "检测到时震动反馈",
        "ar": "اهتزاز عند الكشف",
        "uk": "Тактильний відгук при детекції",
    },
    "carAlertVoice": {
        "en": "Voice alert",
        "ru": "Голосовое предупреждение",
        "ro": "Alertă vocală",
        "fr": "Alerte vocale",
        "de": "Sprach-Warnung",
        "es": "Alerta por voz",
        "it": "Allerta vocale",
        "pt": "Alerta por voz",
        "zh": "语音警报",
        "ar": "تنبيه صوتي بالكلام",
        "uk": "Голосове попередження",
    },
    "carAlertVoiceSubtitle": {
        "en": "Spoken warning via TTS",
        "ru": "Звуковое оповещение через TTS",
        "ro": "Avertisment vorbit prin TTS",
        "fr": "Avertissement vocal via TTS",
        "de": "Gesprochene Warnung über TTS",
        "es": "Advertencia hablada vía TTS",
        "it": "Avviso parlato via TTS",
        "pt": "Aviso falado via TTS",
        "zh": "通过 TTS 朗读警告",
        "ar": "تحذير منطوق عبر TTS",
        "uk": "Мовлене попередження через TTS",
    },
    "carDetectionPrivacyNote": {
        "en": "Audio is analyzed on-device only — nothing is recorded or sent anywhere.",
        "ru": "Звук анализируется только на устройстве — ничего не записывается и не отправляется.",
        "ro": "Sunetul este analizat doar pe dispozitiv — nimic nu este înregistrat sau trimis.",
        "fr": "L'audio est analysé sur l'appareil uniquement — rien n'est enregistré ni envoyé.",
        "de": "Audio wird nur auf dem Gerät analysiert — nichts wird aufgezeichnet oder gesendet.",
        "es": "El audio se analiza solo en el dispositivo — nada se graba ni se envía.",
        "it": "L'audio è analizzato solo sul dispositivo — nulla viene registrato o inviato.",
        "pt": "O áudio é analisado apenas no dispositivo — nada é gravado ou enviado.",
        "zh": "音频仅在设备上分析 — 不记录、不发送任何内容。",
        "ar": "يتم تحليل الصوت على الجهاز فقط — لا يتم تسجيل أو إرسال أي شيء.",
        "uk": "Звук аналізується лише на пристрої — нічого не записується та не надсилається.",
    },
    "carDetectionTooltip": {
        "en": "Car detection via microphone",
        "ru": "Детекция машин через микрофон",
        "ro": "Detecție mașini prin microfon",
        "fr": "Détection de voitures via le micro",
        "de": "Autoerkennung über das Mikrofon",
        "es": "Detección de coches mediante micrófono",
        "it": "Rilevamento auto tramite microfono",
        "pt": "Detecção de carros via microfone",
        "zh": "通过麦克风检测汽车",
        "ar": "كشف السيارات عبر الميكروفون",
        "uk": "Детекція машин через мікрофон",
    },
    "carDetectionStarted": {
        "en": "Car detection started — listening for vehicles",
        "ru": "Детекция машин запущена — слушаю транспорт",
        "ro": "Detecție mașini pornită — ascult vehicule",
        "fr": "Détection de voitures démarrée — à l'écoute",
        "de": "Autoerkennung gestartet — lausche auf Fahrzeuge",
        "es": "Detección de coches iniciada — escuchando",
        "it": "Rilevamento auto avviato — in ascolto",
        "pt": "Detecção de carros iniciada — ouvindo",
        "zh": "汽车检测已启动 — 正在监听车辆",
        "ar": "بدأ كشف السيارات — أستمع للمركبات",
        "uk": "Детекцію машин запущено — слухаю транспорт",
    },
    "carDetectionMicDenied": {
        "en": "Microphone permission denied — cannot detect cars",
        "ru": "Доступ к микрофону запрещён — детекция невозможна",
        "ro": "Permisiunea microfonului a fost refuzată — detecție imposibilă",
        "fr": "Autorisation du micro refusée — détection impossible",
        "de": "Mikrofon-Berechtigung verweigert — Erkennung nicht möglich",
        "es": "Permiso de micrófono denegado — detección imposible",
        "it": "Permesso microfono negato — rilevamento impossibile",
        "pt": "Permissão de microfone negada — detecção impossível",
        "zh": "麦克风权限被拒绝 — 无法检测",
        "ar": "تم رفض إذن الميكروفون — لا يمكن الكشف",
        "uk": "Доступ до мікрофона заборонено — детекція неможлива",
    },
}

LANGS = ["en", "ru", "ro", "fr", "de", "es", "it", "pt", "zh", "ar", "uk"]


def escape_json_string(s: str) -> str:
    """Экранирует строку для JSON."""
    return json.dumps(s, ensure_ascii=False)[1:-1]


def update_arb(lang: str) -> int:
    path = L10N_DIR / f"app_{lang}.arb"
    text = path.read_text(encoding="utf-8")

    # Какие ключи уже есть.
    existing = json.loads(text)
    to_add = [(k, tr[lang]) for k, tr in KEYS.items() if k not in existing]
    if not to_add:
        return 0

    # Находим последний } — туда будем вставлять.
    # ARB формат: последняя пара "key": "value"\n}
    close_idx = text.rfind("}")
    # Найти последнюю непустую строку перед }.
    head = text[:close_idx].rstrip()
    # Если head заканчивается на } или { (пустой объект) — добавим без запятой.
    # Иначе добавим запятую к последней строке.
    if head.endswith("{"):
        # пустой объект — такого не должно быть в наших arb
        new_text = head + "\n" + "".join(
            f'{INDENT}"{k}": "{escape_json_string(v)}"\n' for k, v in to_add
        ) + text[close_idx:]
    else:
        # последний элемент без запятой → добавим запятую.
        new_text = head + ",\n" + "".join(
            f'{INDENT}"{k}": "{escape_json_string(v)}",\n'.rstrip("\n") + "\n"
            if i < len(to_add) - 1
            else f'{INDENT}"{k}": "{escape_json_string(v)}"\n'
            for i, (k, v) in enumerate(to_add)
        ) + text[close_idx:]

    # Упростим: просто добавим запятую к head и все ключи через запятую.
    # Перепишем проще.
    parts = []
    for i, (k, v) in enumerate(to_add):
        suffix = "," if i < len(to_add) - 1 else ""
        parts.append(f'{INDENT}"{k}": "{escape_json_string(v)}"{suffix}')
    if head.endswith("{"):
        new_text = head + "\n" + "\n".join(parts) + "\n" + text[close_idx:]
    else:
        new_text = head + ",\n" + "\n".join(parts) + "\n" + text[close_idx:]

    path.write_text(new_text, encoding="utf-8")
    return len(to_add)


def main() -> None:
    total = 0
    for lang in LANGS:
        n = update_arb(lang)
        print(f"  {lang}: +{n} keys")
        total += n
    print(f"Total keys added: {total}")


if __name__ == "__main__":
    main()
