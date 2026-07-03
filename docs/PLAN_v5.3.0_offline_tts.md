# План v5.3.0: Встроенный офлайн-нейро TTS (sherpa_onnx VITS)

**Статус:** ✅ Реализовано в v5.5.0 (коммит `1312d0a`, APK `LingoTune-v5.5.0.apk`)
**Дата составления:** 2026-07-02
**Дата реализации:** 2026-07-03
**Версия:** 5.5.0 (versionCode 217) — *вместо 5.3.0/209 в плане: проект ушёл вперёд (калибровка детекции в 5.4.0/5.5.0), версию перебазировали*
**Цель:** Сделать озвучку перевода в режиме изучения стабильной на любом устройстве (особенно realme GT8 Pro / китайские ROM), убрав зависимость от системного TTS-движка.

> **Расхождения с планом** (зафиксированы post-factum):
> - **Версия 5.3.0 → 5.5.0** — проект ушёл вперёд (5.3.2 ввёл `TtsCoordinator`, 5.4.0/5.5.0 — калибровку), версию перебазировали
> - **Архитектура A вместо дословного §3/§8** — `TtsEngine` встроен **внутрь** `TtsCoordinator` (полиморфное поле `_engine`), а не заменяет `_tts` в `StudyModeService`. Причина: в 5.3.2 появился `TtsCoordinator` (приоритетная очередь `study > alert`), которого план не учитывал. Это сохраняет приоритетную очередь и оставляет `CarAlertService` без изменений
> - **`archive` остался 3.6.1** (вместо bump до 4.0.0) — `BZip2Decoder`+`TarDecoder` уже в 3.6.1; major-bump ломает `export_import_service.dart`/`song_import_service.dart`. Решено после аудита использования
> - **8 новых файлов вместо 7** — добавлен `tts_source_tile.dart` (отдельный тайл «Источник озвучки», не объединён с `voice_packages_tile.dart`)

---

## 1. Контекст и проблема

На realme GT8 Pro (ColorOS China) системный TTS нестабилен в режиме изучения:
- озвучка «выбивает» через половину песни и глючит;
- даже после фикса 5.2.0 (`<queries>` TTS_SERVICE + перебор движков + fallback `getVoices`) системный путь остаётся хрупким.

**Корень проблемы:** study-режим делает десятки передач аудиофокуса за песню (пауза песни → системный TTS grabs focus → completion → реактивация сессии). На ColorOS это деградирует в зомби-состояния (история фиксов 4.6.x–5.1.0 это подтверждает).

**Решение:** встроенный офлайн-нейро TTS на `sherpa_onnx` (VITS/Piper). Аудио TTS проигрывается тем же `just_audio`, что и песня → нет OS-level арбитража фокуса между двумя подсистемами. Время полностью под контролем: `generate` (CPU) → play WAV → `completed` → дальше. Системный TTS-сервис не участвует вовсе.

---

## 2. Зафиксированные решения

| Развилка | Решение |
|---|---|
| Источник по умолчанию | **Офлайн** (`ttsSource = 'offline'`). Русский бандл есть сразу. Если для языка нет модели — авто-fallback на системный TTS. |
| Каталог языков | **ru (бандл в APK)** + en/de/es/fr/it/pt/ro (докачка из «Голосовых пакетов» по требованию). uk/zh/ar отсутствуют в Piper → остаются на системном TTS. |
| Качество моделей | **full** (~63 МБ/язык). |
| Проигрывание | через имеющийся `just_audio` (второй `AudioPlayer`), **без новых аудио-зависимостей**. |
| Распаковка `.tar.bz2` | пакет `archive` (BZip2Decoder + TarDecoder), уже в зависимостях. |
| Генерация | main isolate в v1 (~0.5 с блок на строку; study и так на паузе). Isolate — на потом если будет jank. |
| RAM | одна активная модель в памяти (lazy load/`free()`). |

---

## 3. Архитектура

```
TtsEngine (абстракция)
├── SystemTtsEngine   — обёртка FlutterTts (логика 5.2.0, поведение 1-в-1, fallback)
└── OfflineTtsEngine  — sherpa_onnx: generate → WAV (temp) → второй AudioPlayer → Completer
```

`StudyModeService` держит `TtsEngine _engine`; выбор по настройке `ttsSource`.

### Поток `OfflineTtsEngine.speak`
1. Убедиться, что модель текущего языка загружена (lazy; выгрузить предыдущую → `tts.free()`, **одна модель в RAM**).
2. `final audio = _tts.generate(text: text, sid: 0, speed: speed);` → `GeneratedAudio { Float32List samples; int sampleRate; }` (CPU, ~0.2–1 с на realme GT8 Pro).
3. `sherpa_onnx.writeWave(filename: tempWav, samples: audio.samples, sampleRate: audio.sampleRate);`
4. `_player.setFilePath(tempWav)` → `_player.play()` → ждать `processingState.completed` → `Completer.complete()`.
5. Удалить temp WAV; `notifyListeners()`.

### Маппинг скорости
`_speechRate` (0.3–1.1, дефолт 0.5) → sherpa `speed` напрямую (1.0 = норма, 0.5 = медленно). Дефолт 0.5 → sherpa 0.5 (чёткая медленная речь для study).

---

## 4. API sherpa_onnx (справка)

```dart
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

// один раз перед любым вызовом
sherpa_onnx.initBindings();

// конфиг Piper (vits). lexicon/dict НЕ нужны — только model + tokens + dataDir (espeak-ng-data)
final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
  model:   '<dir>/model.onnx',
  tokens:  '<dir>/tokens.txt',
  lexicon: '',
  dataDir: '<dir>/espeak-ng-data',
  // опционально (есть дефолты): noiseScale, noiseScaleW, lengthScale, dictDir
);
final modelConfig = sherpa_onnx.OfflineTtsModelConfig(vits: vits, numThreads: 1, debug: true, provider: 'cpu');
final config = sherpa_onnx.OfflineTtsConfig(
  model: modelConfig,
  ruleFsts: '',
  ruleFars: '',
  maxNumSenetences: 1,   // 注意: в API опечатка "Senetences"
  silenceScale: 0.2,
);

final tts = sherpa_onnx.OfflineTts(config);
final audio = tts.generate(text: 'Привет', sid: 0, speed: 1.0);   // или generateWithConfig
// audio.samples : Float32List (mono, [-1,1])   audio.sampleRate : int
tts.free();   // ОБЯЗАТЕЛЬНО — освободить нативную память

// запись WAV (есть в комплекте)
sherpa_onnx.writeWave(filename: path, samples: audio.samples, sampleRate: audio.sampleRate);
```

- Встроенного `play()` в Dart-биндингах **нет** — играем сами.
- `numSpeakers`, `sampleRate` — геттеры у `OfflineTts`.

---

## 5. Каталог моделей (Piper VITS full)

URL: `https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/<name>.tar.bz2`

| Код | Файл (voice) | Размер | Источник |
|---|---|---|---|
| **ru** | `vits-piper-ru_RU-irina-medium` | ~63 МБ | **бандл в APK** |
| en | `vits-piper-en_US-amy-medium` | ~63 МБ | докачка |
| de | `vits-piper-de_DE-thorsten-medium` | ~63 МБ | докачка |
| es | `vits-piper-es_ES-davefx-medium` | ~63 МБ | докачка |
| fr | `vits-piper-fr_FR-siwis-medium` | ~63 МБ | докачка |
| it | `vits-piper-it_IT-paola-medium` | ~63 МБ | докачка |
| pt | `vits-piper-pt_BR-faber-medium` | ~63 МБ | докачка |
| ro | `vits-piper-ro_RO-mihai-medium` | ~63 МБ | докачка |

Каждый архив = `model.onnx` + `tokens.txt` + `espeak-ng-data/`. Хранение **self-contained** per-язык (espeak-ng-data ~2–3 МБ дублируется — acceptable, зато изолированно).

> Альтернативы по размеру (если позже решим уменьшить): `-int8` (~20 МБ), `-fp16` (~34 МБ).

---

## 6. Доставка моделей

### ru (бандл)
- Положить `vits-piper-ru_RU-irina-medium.tar.bz2` в `app/assets/tts/ru_RU.tar.bz2`.
- Объявить в `pubspec.yaml`: `assets: - assets/tts/`.
- При первом включении «Офлайн» (или первом старте study в офлайн-режиме): распаковать ассет в `getApplicationDocumentsDirectory()/tts/ru_RU/` (один раз, кешируется; проверка по наличию `model.onnx`).

### остальные (докачка)
- Из «Голосовых пакетов»: `http`-запрос `.tar.bz2` со стримом и прогрессом (по `Content-Length`) → `BZip2Decoder` + `TarDecoder` → та же папка `tts/<lang>/`.
- Retry при сбое + проверка целостности (наличие `model.onnx` + `tokens.txt` + `espeak-ng-data` после распаковки).
- Хранить/показывать прогресс (0–100 %) и статус («скачивается»/«распаковывается»/«готово»/«ошибка»).

---

## 7. Файлы

### Новые
| Файл | Ответственность |
|---|---|
| `lib/services/tts/tts_engine.dart` | Интерфейс `TtsEngine` |
| `lib/services/tts/system_tts_engine.dart` | Рефакторинг текущей логики FlutterTts (поведение идентично 5.2.0) |
| `lib/services/tts/offline_tts_engine.dart` | sherpa_onnx + just_audio |
| `lib/services/tts/tts_model_manager.dart` | Каталог, наличие, распаковка бандла, докачка, удаление |
| `lib/services/tts/tts_catalog.dart` | Карта язык → (URL, voice, размер, метка, bundled?) |
| `lib/screens/voice_packages_screen.dart` | UI: список языков, статусы, «Скачать/Удалить», прогресс |
| `lib/widgets/settings/voice_packages_tile.dart` | Тайл-вход на экран «Голосовые пакеты» |

### Изменяемые
| Файл | Что |
|---|---|
| `pubspec.yaml` | `+ sherpa_onnx: ^1.13.3`, `archive: ^3.4.0 → ^4.0.0`, `assets: - assets/tts/`, версия → 5.3.0 |
| `study_mode_service.dart` | `_tts` → `TtsEngine _engine`; `_speak`/`_setTtsLanguage`/`stop`/`applyConfiguredEngine` делегируют; выбор по `ttsSource`; watchdog остаётся safety-net |
| `settings_provider.dart` | `+ ttsSource` ('offline'\|'system', дефолт **'offline'**) + persistence |
| `settings_screen.dart` | Тайлы «Источник озвучки» + «Голосовые пакеты» |
| `player_screen.dart` | Оверлей: `src=offline\|system`, `gen=...ms` (время генерации) |
| `app_info.dart` | 5.2.0 → 5.3.0, versionCode 208 → 209 |
| 11 `.arb` | Новые ключи (источник озвучки, голосовые пакеты, статусы докачки) |

---

## 8. Интерфейс `TtsEngine`

```dart
abstract class TtsEngine {
  bool get isReady;
  Future<void> setLanguage(String languageCode);              // ru/en/...
  bool get isLanguageAvailable;                                // есть ли модель/голос
  Future<void> speak(String text, {required double speed});   // resolve по завершению
  Future<void> stop();
  void dispose();
}
```

`SystemTtsEngine` — перенос текущей логики из `study_mode_service.dart` (`_initTts`, `_speak`, `_setTtsLanguage`, `_trySetVoiceByLocale`, `applyConfiguredEngine`, watchdog 5–12 с) — **1-в-1**, без изменения поведения 5.2.0.

`OfflineTtsEngine` — см. поток в §3.

---

## 9. Аудиосессия (главный риск + митигация)

- TTS играет на **втором** `AudioPlayer` (песня — на `_player` из `AudioService`, `audio_service.dart:12`).
- **translationFirst/originalFirst**: песня на паузе → TTS-плеер играет в той же сессии → **нет передачи фокуса ОС** (в отличие от системного TTS).
- **overlay**: песня ducked (`setVolume(0.3)`) + TTS-плеер одновременно → оба в `just_audio`, одна сессия.
- **Митигация при конфликте**: `AndroidAudioAttributes(usage: speech, contentType: speech)` на TTS-плеере; если пауз-плеер песни держит сессию — временный `_player.release()` на время TTS с восстановлением позиции.
- **Тест-точка на realme:** пройти песню до конца в обоих режимах (цель — без вылетов).

---

## 10. Дорожная карта реализации (порядок сборки)

**Этап 1 — Фундамент (без изменения поведения)**
1. `pubspec.yaml`: +`sherpa_onnx`, `archive→^4.0.0`, `assets/tts/`, версия 5.3.0 → `flutter pub get`.
2. Скачать `vits-piper-ru_RU-irina-medium.tar.bz2` → `app/assets/tts/ru_RU.tar.bz2`.
3. `tts_catalog.dart` — карта 8 языков.
4. `tts_model_manager.dart` — наличие / распаковка бандла / докачка+распаковка / удаление.

**Этап 2 — Движок**
5. `tts_engine.dart` (интерфейс).
6. `system_tts_engine.dart` — перенос логики FlutterTts из `study_mode_service.dart` **1-в-1**.
7. `offline_tts_engine.dart` — sherpa `OfflineTts` + второй `AudioPlayer` + `writeWave` + Completer + lazy load/`free()`.

**Этап 3 — Интеграция**
8. `study_mode_service.dart` — `_tts` → `TtsEngine _engine`; делегирование; выбор по `ttsSource`; watchdog остаётся.
9. `settings_provider.dart` — `ttsSource` (дефолт `'offline'`).
10. `player_screen.dart` — оверлей `src=offline|system`, `gen=...ms`.

**Этап 4 — UI + i18n**
11. `voice_packages_screen.dart` + `voice_packages_tile.dart`.
12. `settings_screen.dart` — тайлы «Источник озвучки» + «Голосовые пакеты».
13. 11 `.arb` + `flutter gen-l10n` — новые ключи.

**Этап 5 — Проверка**
14. `flutter pub get` → `flutter gen-l10n` → `flutter analyze` (0 ошибок) → `flutter build apk --release`.
15. Копирование в `builds/LingoTune-v5.3.0.apk`.
16. Тест на realme: **пройти песню до конца без вылетов** в офлайн-режиме; проверить fallback на систему для языка без модели (напр. uk).

---

## 11. Производительность / RAM

- **RAM**: одна активная модель (~80–120 МБ с весами full + буферы). На realme GT8 Pro (до 16 ГБ) — нормально. Жёстко: грузим модель текущего языка перевода, предыдущую — `free()`.
- **Генерация**: full VITS тяжелее int8, но на коротких строках перевода приемлемо. v1 — main isolate (~0.5 с блок на строку; study и так паузит). Время генерации показывать в оверлее (`gen=...ms`).
- **Future optimization (если jank):** генерация в isolate (готовый паттерн `isolate_tts` от sherpa — модель грузится в изоляте, сэмплы возвращаются через SendPort).

---

## 12. Риски и контроль

1. **Рефакторинг StudyModeService под абстракцию** — объёмная часть. Чтобы не сломать систему: `SystemTtsEngine` = точная копия текущей логики. После — `flutter analyze` (0 ошибок) + сборка + проверка обоих режимов.
2. **Размер APK**: бандл ru full (~63 МБ) → APK ~63 → **~130 МБ**. Митигация размера для end-user: `flutter build apk --split-per-ABI` или `appbundle`.
3. **Докачка на слабом интернете**: прогресс + retry + проверка целостности (`model.onnx` + `tokens.txt` + `espeak-ng-data`).
4. **Большой ассет в APK**: Flutter тянет нормально; распаковка однажды (кешируется в documents dir).
5. **Конфликт двух `AudioPlayer`**: см. митигацию в §9.

---

## 13. Вне рамок (будущее)

- uk/zh/ar через MMS/matcha-модели (другая конфигурация, lexicon).
- Isolate-генерация для идеально плавного UI.
- ~~Обновление `docs/README.md` changelog для 5.3.0 (после реализации, перед коммитом).~~ ✅ Выполнено (changelog 5.5.0 в README.md).
- ~~Коммит/пуш: `Release LingoTune v5.3.0: offline neural TTS (sherpa_onnx), stable on Chinese ROMs`.~~ ✅ Выполнено в коммите `1312d0a` (объединён с калибровкой детекции).

---

## 14. Результат реализации (post-factum)

**Собранный APK:** `builds/LingoTune-v5.5.0.apk` (214 МБ — 4 ABI × sherpa native + 64 МБ ru-модель)
**`flutter analyze`:** 0 ошибок (218 warnings/info — все ранее существующие)
**Код:** 8 новых файлов (tts_engine / system_tts_engine / offline_tts_engine / tts_catalog / tts_model_manager / voice_packages_screen / tts_source_tile / voice_packages_tile) + `scripts/add_tts_l10n.py`; изменены `tts_coordinator`, `study_mode_service`, `settings_provider`, `player_screen`, `settings_screen`, `pubspec.yaml`, `app_info`, `build.gradle`, `proguard-rules.pro`, 11 `.arb`

**Тест-пойнты на realme GT8 Pro** (требуют устройства, не выполнены автором кода):
1. Оффлайн ru-перевод: пройти песню до конца без вылетов
2. Fallback uk: выбрать перевод на украинский → должен идти через систему (модели uk нет)
3. Car detection alert: включить 🚗 + study → alert должен пройти (через офлайн на ru / систему на uk)
4. Переключатель ttsSource: в Настройках сменить offline↔system → оба режима работают
5. Экран «Голосовые пакеты»: показывает ru (готов/bundled), остальные — кнопка «Скачать»

**Известные ограничения** (подробно в `docs/README.md` changelog 5.5.0):
- Размер APK 214 МБ — митигация `--split-per-ABI` или `appbundle`
- Генерация в main isolate (~0.5 с блок на строку) — isolate на потом
- `ttsSource` не в экспорте настроек
- `AndroidAudioAttributes(usage: speech)` на TTS-плеере не проставлен (план §9 mitigation)
- ProGuard keep-rules превентивны — package name не верифицирован декомпиляцией
