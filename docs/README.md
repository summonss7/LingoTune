# LingoTune - Изучение языков через музыку

**Версия:** 5.3.2
**Разработчики:** Z.AI GLM & Цимбалов Артем
**Платформа:** Android (Flutter)
**Языки интерфейса:** Русский, Английский, Румынский, Французский, Немецкий, Испанский, Итальянский, Португальский, Китайский, Арабский, Украинский

## 🎵 Описание проекта

LingoTune - инновационное приложение для изучения иностранных языков через музыку. Приложение позволяет слушать любимые песни с синхронизированным отображением текста и переводов строк в реальном времени.

### Ключевые особенности

- 🎵 **Воспроизведение музыки** - проигрывание аудиофайлов (MP3, WAV, M4A, OGG)
- 📝 **Синхронизированный текст** - отображение текста песен с точным таймингом (LRC формат)
- 🌍 **Множественные переводы** - поддержка переводов на множество языков
- 📊 **Строчные переводы** - перевод каждой строки песни
- ⏱️ **Точные временные метки** - автоматическое выделение текущей и следующей строки
- ✏️ **Редактирование переводов** - встроенный редактор переводов
- 📝 **Ручное редактирование тайминга** - настройка временных меток
- 🎯 **Настраиваемая автопрокрутка** - вертикальный ползунок фокуса прокрутки (-1000 до +1000 px)
- 🎚️ **Дефолтный фокус** - настройка начального положения фокуса (+50 по умолчанию)
- 🌐 **Мультиязычный интерфейс** - 12 языков интерфейса
- 🎤 **Поддержка транскрипции** - фонетическая транскрипция для всех языков
- ⚡ **Пакетная генерация текстов** - генерация текстов песен с помощью AI
- 🔍 **Поиск текстов** - поиск текстов песен в онлайн-базах данных
- 🤖 **AI переводы (DeepSeek)** - автоматическая генерация переводов
- 💾 **Экспорт/импорт настроек** - резервное копирование настроек
- 📦 **Библиотека песен** - управление плейлистами и песнями
- 🔄 **Фоновое воспроизведение** - воспроизведение в фоне с уведомлением
- ⏩ **Управление скоростью** - изменение скорости воспроизведения (0.5x - 2.0x)
- 🎧 **Режим изучения** - озвучка перевода (TTS) + фрагмент песни для каждой строки
- 🚗 **Детекция машин** - анализ звука с микрофона (FFT, on-device) и предупреждение бегуна о приближающемся транспорте (звук/вибрация/голос)

## 📦 Структура проекта

```
LingoTune/
├── app/                    # Flutter приложение
│   ├── lib/
│   │   ├── models/         # Модели данных (Song, Translation, LyricLine)
│   │   ├── services/       # Сервисы (AudioService, DatabaseService, TranslationService)
│   │   ├── screens/        # Экраны приложения
│   │   ├── widgets/        # Переиспользуемые компоненты
│   │   │   └── settings/  # Виджеты настроек (FocusOffset, ScrollOffset)
│   │   ├── utils/          # Утилиты
│   │   └── constants/      # Константы
│   ├── assets/             # Ресурсы (шрифты, иконки)
│   └── pubspec.yaml        # Зависимости Flutter
├── scripts/                # Python скрипты для генерации текстов
│   ├── deepseek_generator_v3.py
│   ├── generate_lrc_json.py
│   └── process_excel_songs.py
├── input/                  # Входные файлы для обработки
├── output/                 # Сгенерированные файлы текстов и переводов
├── lessons/                # Уроки по языкам
│   └── Arabic/            # Арабские уроки
├── builds/                 # Собранные APK файлы
└── docs/                   # Документация
```

## 🚀 Быстрый старт

### Требования

- Flutter SDK 3.0+
- Python 3.8+
- Android SDK
- Учетная запись DeepSeek API

### Установка

```bash
# Клонирование репозитория
cd D:\Ai-LingoTune

# Установка зависимостей Flutter
cd app
flutter pub get

# Установка зависимостей Python
cd ../scripts
pip install -r requirements.txt

# Настройка API ключей (создать .env файл)
echo "DEEPSEEK_API_KEY=ваш_ключ_здесь" > ../.env
```

### Сборка APK

```bash
# Из папки app/
flutter build apk --release

# APK будет создан в: build/app/outputs/flutter-apk/app-release.apk

# Копирование в папку builds/
cp build/app/outputs/flutter-apk/app-release.apk builds/LingoTune-v{версия}.apk
```

## 📖 Документация

- [Архитектура системы](ARCHITECTURE.md) - описание архитектуры и компонентов
- [Настройка окружения](SETUP.md) - установка и конфигурация
- [Форматы данных](DATA_FORMATS.md) - LRC, JSON и другие форматы файлов
- [Руководство по API](API_GUIDE.md) - DeepSeek API и интеграции
- [Создание уроков](LESSON_CREATION.md) - генерация текстов песен и уроков
- [Рабочий процесс](WORKFLOW.md) - рабочий процесс приложения
- [Разработка](DEVELOPMENT.md) - конвенции кода и разработка
- [Решение проблем](TROUBLESHOOTING.md) - FAQ и решение проблем
- [План: Калибровка детекции машин](PLAN_CAR_DETECTION_CALIBRATION.md) - план v5.4.0 (эталоны + Mahalanobis)

## 🎯 План следующей версии (5.4.0)

**Статус:** ⏳ Запланировано (не начато)

Полный план в [`PLAN_CAR_DETECTION_CALIBRATION.md`](PLAN_CAR_DETECTION_CALIBRATION.md).

Кратко: вместо пороговой логики детекции — **классификация по эталонам с Mahalanobis distance**.
Пользователь сможет:
- Записывать свои эталоны звуков (машина близко/далеко/грузовик, ветер, шаги, голоса, улица)
- Видеть live-спектр и ближайший класс в реальном времени
- Загружать синтетические демо-эталоны (7 звуков в `assets/calibration/`)
- Точно настраивать детектор под свои условия бега/устройства/наушников

## 🎯 Новое в версии 5.3.2

### 🐛 Фикс: детекция машин ломала озвучку перевода + ложные срабатывания на шорохи
- **Симптом 1:** после включения кнопки 🚗 TTS-озвучка перевода в study mode полностью замолкала до конца сессии
- **Симптом 2:** детектор срабатывал от любого шороха/шага/ветра; слайдер «чувствительность» в Настройках не влиял на поведение
- **Корень 1 (TTS-конфликт):** `flutter_tts` использует единый `MethodChannel('flutter_tts')` на всё приложение — два экземпляра `FlutterTts` (`StudyModeService._tts` и `CarAlertService._tts`) перетирали друг другу `setCompletionHandler`. Когда детекция вызывала `CarAlert._tts.speak("Внимание, машина")`, completion-handler study mode терялся → watchdog (12с) срабатывал → `setSpeakDisabled(true)` → TTS перевод отключался до конца песни
- **Корень 2 (CPU-конфликт):** FFT-анализ в main isolate каждые 16 мс (60 Гц) мешал study-таймерам (`segmentTimer` 150мс, `positionTimer` 50мс) и TTS handlers вовремя срабатывать
- **Корень 3 (sensitivity):** параметр `sensitivity` принимался в `start()`, но не использовался в decision-логике — пороги были `static const`
- **Решение (Phase A):**
  - **A1 — Единый `TtsCoordinator` (новый файл `tts_coordinator.dart`):** один `FlutterTts` на всё приложение, единая пара `setCompletionHandler/setErrorHandler`. Запросы `speak()` упорядочены по приоритету (`study > alert`): если study mode озвучивает перевод, голосовой alert **автоматически пропускается** координатором, не прерывая речь. `StudyModeService` и `CarAlertService` инжектят координатор вместо своих `FlutterTts()`
  - **A2 — Снижение частоты FFT:** `_hopSize 256 → 512` (анализ каждые 32 мс вместо 16 мс, **−50% CPU в main isolate**), окно подтверждения 6→4 кадра. Таймеры study mode снова успевают нормально срабатывать
  - **A3 — Реальная чувствительность:** пороги переведены из `static const` в instance fields, метод `_applySensitivity(sensitivity)` линейно интерполирует пороги (sens=0 → строгие 0.60 score / 2.8× lowDom / 0.020 rms; sens=1 → мягкие 0.30 / 1.4× / 0.008; sens=0.5 → средние 0.45 / 2.1× / 0.014). Дефолт поднят с 0.5 до **0.4** (чуть строже, чтобы убрать ложные на шорохи)
  - **A4 — Фильтр ветра/шагов:** в `_analyzeFrame` добавлены 2 пред-фильтра перед основным decision:
    - **Ветер/шорох:** если `flatness > 0.35` и `low/mid < 2.0` → равномерный шум с лёгким НЧ-уклоном → score=0
    - **Шаг/удар:** если `rms > 0.08` (очень громко) и `centroid > 600 Hz` → широкополосный всплеск (телефон трясётся в кармане) → score=0
    - Настоящая машина = узкий НЧ-пик: lowDom сильный + peaked (flat<порог) + низкий центроид + длительность
  - **A5 — Адаптивный throttle:** при активном TTS study mode интервал между alert'ами растёт с 2 сек до **5 сек** (через callback `isStudySpeaking`, который PlayerScreen подключает к `StudyModeService.isSpeaking`). Beep и вибрация остаются (не перебивают TTS так грубо, как голосовой alert)

### 🔧 Технические изменения
- `lib/services/tts_coordinator.dart` (новый, ~210 строк): синглтон `TtsCoordinator.instance`, один `FlutterTts`, enum `TtsPriority { study, alert }`, `_TtsRequest` с completer, методы `speak(text, {priority, locale, rate, pitch, volume})` и `stop()`, `_applyConfiguredEngine()` (Google TTS приоритет, делегировано из StudyModeService), единые handlers `_handleCompletion/_handleError`
- `lib/services/study_mode_service.dart`: `_tts` теперь геттер к `TtsCoordinator.instance.tts` для конфигурации; речь — через `_ttsCoordinator.speak(text, priority: study)`; `_speak` переписан — watchdog через `.timeout()` на future координатора; убраны `_speakCompleter`/`_resolveSpeak`; `_applyConfiguredEngine` делегирует в координатор; `_initTts` теперь просто прогревает координатор
- `lib/services/car_alert_service.dart`: `_tts` теперь `TtsCoordinator.instance`; `_speak` вызывает `_tts.speak(text, priority: alert, ...)` — координатор сам пропустит запрос если study mode говорит; убран собственный `FlutterTts()`/`setSpeechRate`/`setLanguage`; dispose больше не вызывает `_tts.stop()` (координатор общий, нельзя останавливать чужую речь)
- `lib/services/car_detection_service.dart`:
  - `_hopSize 256 → 512`; `_confirmWindow 6 → 4`
  - пороги `_minRms`/`_lowDominanceRatio`/`_scoreThresholdLow/Medium/High`/`_maxFlatnessForCar`/`_maxCentroidHz` переведены в instance fields (не const)
  - новый метод `_applySensitivity(double)` с линейной интерполяцией порогов; вызывается в `start()`
  - 2 новых фильтра в `_analyzeFrame`: wind-noise (`flatness>0.35 + low/mid<2.0`) и step-impact (`rms>0.08 + centroid>600`)
  - `_maybeFireAlert` использует адаптивный throttle: 5 сек если `isStudySpeaking()==true`, иначе 2 сек
  - новое public поле `bool Function()? isStudySpeaking`
- `lib/services/settings_provider.dart`: дефолт `carDetectionSensitivity` 0.5 → **0.4**
- `lib/screens/player_screen.dart`: `_carDetectionService.isStudySpeaking = () => _studyModeService.isSpeaking` (даёт детектору знать, когда не молоть alert'ами поверх перевода)
- `pubspec.yaml`/`app_info.dart`/`build.gradle` — 5.3.2 (versionCode 212)

### ⚠️ Что НЕ вошло в Phase A (запланировано в Phase B)
- **B1 — FFT в отдельный Isolate** (long-lived через `Isolate.spawn` + SendPort) — пока FFT остаётся в main, но частота снижена в 2 раза, что достаточно для нормальной работы study mode
- **B2 — Beep через SoundPool** вместо второго `just_audio` AudioPlayer — пока beep играет через отдельный AudioPlayer, может слегка «конкурировать» с основным плеером в моменты kickPlayback
- **B3 — Co-ownership AudioSession** — пока полагаемся на `audioInterruption: none` в `RecordConfig`

---

## 🎯 Новое в версии 5.3.1

### 🐛 Фикс: кнопка детекции машин останавливала музыку и TTS study mode
- **Симптом:** при включении детекции (кнопка 🚗) музыка ставилась на паузу, а TTS-озвучка перевода прерывалась
- **Причина:** в `RecordConfig` пакета `record` дефолтные настройки вмешивались в аудио-сессию Android:
  - `audioInterruption: AudioInterruptionMode.pause` (дефолт) → `record_android` вызывает `AudioManager.requestAudioFocus(AUDIOFOCUS_GAIN)` с атрибутами `USAGE_MEDIA + CONTENT_TYPE_SPEECH` → **полный захват фокуса**, остальные источники приглушаются/останавливаются
  - `BackgroundAudioHandler._initAudioSession()` подписан на `interruptionEventStream` → при потере фокуса вызывает `pause()` → музыка встаёт, TTS теряет возможность говорить
  - `androidConfig.manageBluetooth: true` (дефолт) → пытается переключиться на Bluetooth SCO, ломает A2DP routing наушников
- **Решение:** в `CarDetectionService.start()` RecordConfig явно настроен «ненавязчиво»:
  - `audioInterruption: AudioInterruptionMode.none` → НЕ запрашивать audio focus
  - `androidConfig: AndroidRecordConfig(manageBluetooth: false, audioSource: mic, audioManagerMode: modeNormal)` → не трогать bt routing и audio mode
- Микрофон пишет параллельно с музыкой и TTS без каких-либо конфликтов фокуса

### 🔧 Технические изменения
- `lib/services/car_detection_service.dart`: `RecordConfig` расширен параметрами `audioInterruption`/`androidConfig` с подробным комментарием-обоснованием; дефолт `start({sensitivity = 0.4})` (синхронизировано с дефолтом настроек)
- `pubspec.yaml`/`app_info.dart`/`build.gradle` — 5.3.1 (versionCode 211)

---

## 🎯 Новое в версии 5.3.0

### 🚗 Новая фича: Детекция машин через микрофон (безопасность бегуна)
- **Задача:** при беге с музыкой в наушниках бегун не слышит приближающийся транспорт и вынужден постоянно оборачиваться
- **Решение:** фоновый спектральный анализ звука с микрофона + предупреждение бегуна (звук/вибрация/голос)
- **Технический подход:** чистый Dart FFT (Cooley-Tukey, radix-2) на потоке PCM 16kHz моно; ML-модель НЕ используется (YAMNet .tflite недоступна для прямой загрузки, а tflite_flutter нестабилен на новых NDK). Вместо этого:
  - Скользящее окно 512 семплов (32 ms) с перекрытием 50% → анализ каждые 16 ms
  - Hann window → FFT → magnitude spectrum
  - Извлечение признаков: энергии полос (low 20-300 Гц, mid 300-2000, high 2k-8k), спектральный центроид, spectral flatness, RMS
  - Decision-логика: доминирование НЧ (`lowDom`) + низкий центроид + пиковый (не шумовой) спектр → score 0..1
  - Подтверждение: нужно N≥3 срабатываний в окне 6 кадров (~96 ms), иначе одиночные всплески отсеиваются
  - Throttle: не чаще раза в 2 сек
  - 3 уровня уверенности: low / medium / high
- **Предупреждения (настраиваются в Настройках):**
  - 🔊 **Звук** — короткий beep (880 Гц × 3) из `assets/sounds/car_alert.wav` поверх музыки
  - 📳 **Вибрация** — `HapticFeedback.heavyImpact` (1-3 раза по уровню)
  - 🗣️ **Голос** — TTS-фраза на языке интерфейса («Внимание, едет машина» / «Attention, car approaching» и т.д. — 11 языков)
- **Приватность:** звук анализируется **только on-device**, ничего не записывается и не отправляется
- **UI:**
  - Кнопка 🚗 в AppBar плеера (как «Изучение») с подсветкой активности и красным миганием при срабатывании
  - Persist-флаг: один раз включил — держится между запусками и песнями
  - Overlay-индикатор над текстом песни: статус listening + последний score/класс
  - ExpansionTile в Настройках: главный переключатель + слайдер чувствительности (0-100%, 10 шагов) + 3 переключателя типов предупреждений + privacy-нота
- **Локализация:** 15 новых ключей (`carDetection*`, `carAlert*`) во всех 11 языках (`.arb` + `app_localizations_*.dart`)

### 🔧 Технические изменения
- `AndroidManifest.xml`: 4 новых permission — `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`, `FOREGROUND_SERVICE_MICROPHONE`, `VIBRATE`
- `pubspec.yaml`: `record: ^7.1.1` (захват микрофона через `AudioRecorder.startStream(RecordConfig)`); `share_plus` 9 → 10.1.4 (требуется для совместимости `record 7.x` ↔ `web 1.x`); ассеты `assets/sounds/`
- `lib/utils/fft.dart` (новый, ~210 строк): `Fft.transform` (radix-2 Cooley-Tukey in-place), `Fft.hannWindow`, классы `SpectrumFeatures` и `SpectrumAnalyzer` (полосные энергии, centroid, flatness, RMS)
- `lib/services/car_detection_service.dart` (новый): `CarDetectionService extends ChangeNotifier` — потоковый захват PCM 16-bit LE, sliding-window FFT с hop=256, decision-логика (lowDom/centroid/flatness → score), окно подтверждения, throttle, геттеры диагностики
- `lib/services/car_alert_service.dart` (новый): `CarAlertService` — beep через отдельный `just_audio.AudioPlayer`, вибрация через `HapticFeedback`, TTS через `FlutterTts`; фразы/локали на 11 языках
- `assets/sounds/car_alert.wav` (новый, 55 КБ, 0.63 с): 3 beep 880 Гц с attack/decay envelope; генерируется `scripts/gen_car_alert.py`
- `lib/services/settings_provider.dart`: 5 новых полей (`carDetectionEnabled`, `carDetectionSensitivity`, `carAlertSound`, `carAlertVibration`, `carAlertVoice`) + геттеры/сеттеры/persistence по существующему паттерну
- `lib/widgets/settings/car_detection_settings_tile.dart` (новый): `ExpansionTile` с переключателем, слайдером чувствительности и 3 `SwitchListTile` для типов предупреждений
- `screens/settings_screen.dart`: импорт + вставка `CarDetectionSettingsTile` рядом с TTS-движком
- `screens/player_screen.dart`: импорты; поля `_carDetectionService`/`_carAlertService`; инициализация в `initState` + авто-старт по persist (`_maybeAutoStartCarDetection` через post-frame); dispose; `_onCarDetection` listener → `_carAlertService.alert`; `_toggleCarDetection`; `_buildCarDetectionButton` (AnimatedBuilder с активным/алертным состояниями); кнопка в `_buildAppBarContent` (cnt 5→6); overlay-индикатор над текстом песни
- `lib/l10n/app_*.arb` + `lib/l10n/app_localizations*.dart`: 15 × 11 = 165 новых строк (генерация `scripts/add_car_l10n.py` + `scripts/add_car_l10n_dart.py`)
- `pubspec.yaml` и `app_info.dart` — 5.3.0 (versionCode 209); features += «🚗 Car detection via microphone (safety for runners)»

### ⚠️ Известные ограничения (Фаза 1 MVP)
- **Фоновый режим при выключенном экране** пока не реализован — детекция работает пока экран включён и LingoTune на переднем плане. Полноценный foreground service с типом `microphone` — Фаза 3
- **Ducking музыки** при beep не делается (beep играет поверх) — Фаза 2
- **Wind-noise фильтр** базовый (через spectral flatness) — тюнинг под бег потребуется после полевых тестов
- Тюнинг порогов (`_lowDominanceRatio`, `_maxCentroidHz`, `_confirmMinHits`) выполнен «по теории» — реальные значения подбираются после тестов на бегу

---

## 🎯 Новое в версии 5.2.0

### 🐛 Фикс: TTS-движок не находился на Android 11+ (китайские ROM, realme GT8 Pro)
- **Симптом:** на устройствах с китайской ROM (realme GT8 Pro China, ColorOS) приложение «не видит» системный TTS — озвучка перевода в режиме изучения молчит. При этом Duolingo на том же телефоне говорит
- **Причина 1 (манифест):** в `AndroidManifest.xml` отсутствовал `<queries>` для `android.intent.action.TTS_SERVICE`. На Android 11+ (API 30+, у realme GT8 Pro — API 35) действует package visibility: без этого объявления приложение физически не может перечислить/опросить системные TTS-движки
- **Причина 2 (движок по умолчанию):** код использовал только движок по умолчанию — на ColorOS China это «Heytap Speech Engine», который часто врёт в isLanguageAvailable и/или молча не синтезирует. getEngines/setEngine/getVoices/setVoice не использовались вовсе
- **Решение:**
  - `<queries>` TTS_SERVICE — движки снова видны приложению
  - Перебор движков (getEngines + setEngine): приоритет Google TTS (`com.google.android.tts`) над кривым дефолтным; режим «Авто»
  - Fallback на getVoices/setVoice: когда isLanguageAvailable врёт (голос установлен, но движок сообщает «недоступно») — ищем голос по локали и выставляем напрямую
  - Настройка «Движок TTS» в Настройках: выпадающий список («Авто (рекомендуется)» + все движки системы с человекочитаемыми именами)
- Диагностический оверлей расширен: engine=/engines=/langAvail=/speakDisabled=
- Подтверждено на realme GT8 Pro: озвучка работает локально через Google TTS (без интернета)

### 🔧 Технические изменения
- `AndroidManifest.xml`: `<queries>` → TTS_SERVICE
- `study_mode_service.dart`: поля `_availableEngines`/`_selectedEngine`; `_applyConfiguredEngine` (чтение `ttsEngine` из prefs, приоритет Google TTS, `setEngine`); `_trySetVoiceByLocale` (fallback `getVoices`/`setVoice`); `applyConfiguredEngine` (применение при старте study)
- `settings_provider.dart`: поле `ttsEngine` (String, дефолт `''` = Авто) + getter/setter/persistence
- `utils/tts_engine_helper.dart` (новый): `enumerateTtsEngines()` + карта человекочитаемых меток движков
- `widgets/settings/tts_engine_settings_tile.dart` (новый): тайл выбора движка (DropdownButton)
- `settings_screen.dart`: тайл «Движок TTS» рядом с «Служебные данные»
- `player_screen.dart`: оверлей расширен (`engine`/`engines`/`langAvail`/`speakDisabled`)
- Локализация: 4 новых ключа (`ttsEngine`, `ttsEngineSubtitle`, `ttsEngineAuto`, `ttsEngineReloadHint`) во всех 11 языках
- `pubspec.yaml` и `app_info.dart` — 5.2.0 (versionCode 208)

---

## 🎯 Новое в версии 5.1.0

### 🐛 Фикс: на устройствах без русского TTS-голоса озвучка молчала и приложение жутко тормозило
- **Симптом:** на некоторых устройствах (особенно китайские ROM, напр. Realme GT8 Pro China) озвучка перевода не работала — в моменты TTS была тишина и приложение сильно лагало. На устройствах с установленным русским голосом (напр. Realme GT 5) всё работает
- **Причина:** `FlutterTts` использует системный TTS-движок. Если нужный язык не установлен (китайский ColorOS часто идёт без Google TTS и без русского голоса), движок принимает `speak()`, но не говорит и не шлёт completion → `_speak` висел до watchdog-таймаута **до 66 секунд на каждую строку**. В режиме «после оригинала» аудио на это время ставится на паузу → тишина + лаги строка за строкой. При этом `_ttsReady` оставался `true` независимо от наличия языка
- **Решение:**
  - **Детект доступности языка** (`checkLanguageAvailable` / `isLanguageAvailable` / `activeEngine`): проверка `isLanguageAvailable` для текущего языка перевода
  - **Диалог при ручном включении study:** если голос не установлен — диалог «Нет голоса для этого языка» с инструкцией установить TTS-движок (Google/Yandex) и кнопками «Продолжить без озвучки» (режим только фрагменты) / «Отмена». При авто-старте/рестарте — автоматический переход в режим «только фрагменты» без диалога
  - **Fail-fast watchdog:** таймаут сокращён с ~66с до **≤12с**, при срабатывании TTS авто-отключается на сессию → больше никаких долгих зависаний (раннер идёт по сегментам)
  - **Режим «только фрагменты»** (`speakDisabled`): `_speak` становится no-op, study проигрывает сегменты без озвучки — приложение не виснет
- Диагностический оверлей расширен: `TTS engine=… langAvail=… speakDisabled=…`

### 🔧 Технические изменения
- `study_mode_service.dart`: поля `_langAvailable`/`_speakDisabled`/`_activeEngine` + геттеры + `setSpeakDisabled` + `checkLanguageAvailable`; `_setTtsLanguage` записывает доступность; `_initTts` запоминает движок (`getDefaultEngine`); `_speak` — early-return при `_speakDisabled`, watchdog ≤12с + авто-disable при срабатывании
- `player_screen.dart`: `_ensureTtsReady({fromUser})` pre-flight + `_showTtsUnavailableDialog()`; вызов в `_toggleStudyMode`/`_maybeAutoStartStudy`/`_restartStudyIfNeeded`; поля в оверлее
- Локализация: 4 новых ключа (`studyModeStartedNoVoice`, `ttsLangMissingTitle`, `ttsLangMissingBody`, `ttsContinueNoVoice`) во всех 11 языках (`.arb` + сгенерированные `.dart`)
- `pubspec.yaml` и `app_info.dart` — 5.1.0 (versionCode 207)

---

## 🎯 Новое в версии 5.0.9

### 🐛 Фикс: после переключения песни первая фраза повторялась (проигрывалась без study, потом study отматывал и играл заново)
- **Симптом (появился после фикса 5.0.8):** при авто/ручном переходе на следующую/предыдущую песню аудио начинало играть (~2-3с кнопка study ещё не горела), затем study включался и **отматывал к началу строки 0 и проигрывал её заново**
- **Причина:** после таймаут-фикса 5.0.8 `handler.playSong` стал возвращать управление, но между запуском аудио и стартом study (через `ensurePlaybackAdvancing` + задержку restart) проходило ~2-3с — за это время позиция уходила на ~1-2с внутрь строки 0. Затем study стартовал и в `_playSegmentAndAwait(0)` безусловно делал `seek(lines[0].startTime = 0с)` → отматывал назад → повтор
- **Решение:**
  - **Guard на seek к началу строки** (`_playSegmentAndAwait` и `_handleTranslationFirst`): seek делается только если текущая позиция ДО начала сегмента. На нормальных переходах строка→строка позиция уже ≈ startMs (seek и так избыточен) → поведение не меняется. На старте после переключения (позиция уже внутри строки 0) → seek назад не делается, study мягко подхватывает с текущей позиции — **без повтора**
  - Сокращено «окно» без активного study: таймаут `_player.play()` в `handler.playSong` 2с → 1с; задержка `_restartStudyIfNeeded` 150мс → 50мс
- Диагностика 5.0.7 (оверлей + хлебные крошки) оставлена для подтверждения; будет почищена в следующем релизе

### 🔧 Технические изменения
- `study_mode_service.dart`: `_playSegmentAndAwait` и `_handleTranslationFirst` — seek к началу строки только при `position < startMs`
- `background_audio_handler.dart`: `_player.play().timeout(...)` 2с → 1с
- `player_screen.dart`: `_restartStudyIfNeeded` delay 150мс → 50мс
- `pubspec.yaml` и `app_info.dart` — 5.0.9 (versionCode 206)

---

## 🎯 Новое в версии 5.0.8

### 🐛 Фикс: после авто-перехода песни study-режим оставался неактивным, пока не нажмёшь play/pause (КОРНЕВАЯ причина)
- **Симптом (подтверждён диагностической 5.0.7):** после авто-перехода на следующую песню study не активен (`active=false`), новая песня реально играет (`pos` растёт), но `_playSong` «висит» (`load=true`), перевода нет. Нажатие play/pause оживляло всё
- **Корень:** `BackgroundAudioHandler.playSong()` после деактивации Android audio-сессии плитом TTS делал голые `await session.setActive(true)` / `await _player.setFilePath()` / **`await _player.play()`** без таймаутов. На Android `play()` после TTS **запускает аудио, но его Future зависает навсегда** → `await handler.playSong()` в `_playSong` не возвращается → `_playSong` не доходит до `ensurePlaybackAdvancing` и `_restartStudyIfNeeded` → study остаётся выключенным. Нажатие FAB (новый `play()/pause()`) разрешал зависший Future → `_playSong` продолжает → study стартует. Именно поэтому поведение было одинаковым в 5.0.4–5.0.7: фиксы были НИЖЕ по потоку от зависшего await и просто не выполнялись
- **Решение:** все критичные await'ы в `playSong` (и `loadSong`) обёрнуты в `.timeout()`: `setActive` — 2с, `setUrl/setFilePath` — 5с, `play()` — 2с. Future больше не может висеть → метод всегда возвращает управление → `_playSong` доходит до `ensurePlaybackAdvancing` (верифицирует реальное движение) и `_restartStudyIfNeeded` (перезапускает study)
- Диагностика 5.0.7 (оверлей + хлебные крошки) оставлена на этот релиз для подтверждения на устройстве, что `active=true` после переключения; будет почищена в следующем

### 🔧 Технические изменения
- `background_audio_handler.dart`: `loadSong` и `playSong` — `.timeout()` на `setActive`/`setUrl`/`setFilePath`/`play()` (внутри существующего try-catch, таймауты логируются)
- `pubspec.yaml` и `app_info.dart` — 5.0.8 (versionCode 205)

---

## 🎯 Новое в версии 5.0.7

### 🔍 ДИАГНОСТИЧЕСКАЯ сборка (не финальный фикс)
- **Цель:** после фиксов 5.0.5/5.0.6 (версия на устройстве подтверждена 5.0.6) симптом «после авто-перехода study не активен, оживает только кнопкой play/pause» сохраняется. Статически код выглядит корректно, поэтому добавлена инструментация для точного определения разрыва в runtime
- **Что добавлено:**
  - Отладочный оверлей («Служебные данные») теперь показывается **всегда** (не только когда study активен) — чтобы видеть состояние даже в момент сбоя, когда study не активен
  - Новые поля в оверлее: `active` (isActive), `persist` (enabledPersist), `load` (_isSongLoading), и `EVT:` (последнее событие жизненного цикла)
  - Хлебные крошки (`_studyEvt`) в ключевых точках с живым обновлением UI: `_playSong` (enter/post-stop/post-start/post-kick/post-restart/finally/skip), `_restartStudyIfNeeded` (каждая причина early-return + результат `start()`), `_onStudySongCompleted`, `onSongComplete` (guarded?), FAB onPressed
- **Как использовать:** включить «Служебные данные» → воспроизвести сбой (дойти до конца песни с study) → в момент зависания прочитать поле `EVT:` в плашке и прислать разработчику. Последнее событие точно укажет, где оборвалась цепочка перезапуска study
- Это промежуточная сборка: после получения данных будет выпущен целевой фикс

### 🔧 Технические изменения
- `player_screen.dart`: поле `_lastStudyEvent` + хелпер `_studyEvt` (с живым `setState`); оверлей всегда виден и расширен; хлебные крошки в `_playSong`/`_restartStudyIfNeeded`/`_onStudySongCompleted`/`onSongComplete`/FAB
- `pubspec.yaml` и `app_info.dart` — 5.0.7 (versionCode 204)

---

## 🎯 Новое в версии 5.0.6

### 🐛 Фикс: после авто-перехода на следующую песню не двигался текст и не озвучивался перевод
- **Проблема:** в режиме говорения после того, как песня доигрывала до конца (последняя строка озвучивалась после окончания времени песни), переключение на следующую песню «замирало» — текст не двигался, перевод не произносился. Помогало только вручную нажать play/pause (иногда дважды). Проявлялось во всех режимах порядка (перевод/оригинал/поверх)
- **Причина:** на последней строке TTS озвучивает перевод ПОСЛЕ того, как песня дошла до `ProcessingState.completed`. Во время речи Android деактивирует audio session. Переключение песни шло через `BackgroundAudioHandler.playSong()`, который делал только `session.setActive(true)` + `play()` — **без проверки реального движения позиции**. В итоге just_audio уходил в зомби-состояние (`playing == true`, а позиция стоит) → нет подсветки строк, study-раннер не детектит границы сегмента → нет перевода. Ручной play/pause оживлял, потому что второй тап → `resumeSession` → `_kickPlayback()` (с retry и seek-nudge), к которому сессия уже успевала «устаканиться»
- **Решение:** добавлен `AudioService.ensurePlaybackAdvancing()` — верифицированный запуск воспроизведения по образцу `_kickPlaybackAsync`: реактивация сессии → `play()` → проверка реального движения позиции за ~400мс → при отсутствии retry + seek-nudge (заставляет just_audio перебуферизоваться и выйти из зомби). Метод **no-op при здоровом воспроизведении** (выходит на первой проверке)
- В `_playSong` после загрузки/запуска новой песни вызывается `ensurePlaybackAdvancing()` (в зоне `enabledPersist` — единственный путь, где TTS деактивирует сессию), и сокращена задержка restart `_restartStudyIfNeeded` (500мс → 150мс, т.к. кик уже гарантирует движение)
- Теперь после авто-перехода и ручного next **песня реально играет с первой секунды** — текст бежит, перевод озвучивается, без ручных нажатий

### 🔧 Технические изменения
- `audio_service.dart`: импорт `audio_session`; новый метод `ensurePlaybackAdvancing({maxAttempts = 5})` (setActive → play → verify position → retry + seek-nudge, с досрочным выходом по `ProcessingState.completed`)
- `player_screen.dart`: в `_playSong` после `handler.playSong()`/`loadAudio()` — `ensurePlaybackAdvancing()` при `enabledPersist`; `_restartStudyIfNeeded` delay 500мс → 150мс
- `pubspec.yaml` и `app_info.dart` — 5.0.6 (versionCode 203)

---

## 🎯 Новое в версии 5.0.5

### 🐛 Фикс: режим говорения не возобновлялся после переключения песни
- **Проблема:** в режиме говорения (study mode) после переключения песни кнопка «Изучение» не подсвечивалась и перевод не озвучивался:
  - при ручном переходе «следующая песня» — помогало нажать play/pause;
  - при автоматическом переходе (loop/завершение песни) — play/pause не помогал, нужно было перемотать песню, чтобы режим оживал
- **Причина 1 (авто-переход):** в `_onStudySongCompleted()` после `_playNextSong()` проверялось `_studyModeService.isActive` для обнаружения случая «ничего не переключилось». Но к этому моменту `_playSong` уже перезапустил study mode через persist для НОВОЙ песни → `isActive` всегда `true` → `stop()` убивал только что запущенную сессию. Флаг persist оставался включённым, но никто режим больше не поднимал → play/pause (при неактивном study просто крутит аудио) не помогал, а перемотка помогала, т.к. её `onChangeEnd` вызывает `_restartStudyIfNeeded`
- **Причина 2 (ручной переход / UI):** кнопка «Изучение» в AppBar (`_buildStudyModeButton`) не была обёрнута в `AnimatedBuilder` — она обновлялась только через `setState` 50мс-таймера, который гасится на всё время `_playSong`. В окне переключения подсветка могла оставаться устаревшей, пока pause/play не «пнёт» runner
- **Решение:**
  - `_onStudySongCompleted` сравнивает `_currentSong.id` до/после `_playNextSong()` — `stop()` срабатывает только если песня реально не сменилась (LoopMode.off, последняя), а не по `isActive`
  - `_buildStudyModeButton` обёрнут в `AnimatedBuilder(animation: _studyModeService, …)` — подсветка реагирует на `notifyListeners()` напрямую (как FAB), больше не зависит от 50мс-таймера
- Теперь режим говорения **корректно перезапускается и подсвечивает кнопку** после ручного и автоматического переключения песни без необходимости жать play/pause или перематывать

### 🔧 Технические изменения
- `player_screen.dart`: `_onStudySongCompleted()` — сравнение `_currentSong.id` вместо `_studyModeService.isActive`; `_buildStudyModeButton` — обёрнут в `AnimatedBuilder`
- `pubspec.yaml` и `app_info.dart` — 5.0.5 (versionCode 202)

---

## 🎯 Новое в версии 5.0.4

### 🐛 Фикс: текст песни уезжал за зону видимости при смене песни
- **Проблема:** после переключения песни (в т.ч. по loop) текст оказывался за пределами видимой области — скролл-позиция оставалась от предыдущей (длинной) песни
- **Решение:** в `_playSong` добавлен сброс скролла в топ (`_scrollController.jumpTo(0)`) через post-frame callback после загрузки нового текста — новые Lyrics теперь сразу видны с первой строки

### 🔧 Технические изменения
- `player_screen.dart`: `_scrollController.jumpTo(0.0)` на смене песни (post-frame, с guard `hasClients`)
- `pubspec.yaml` и `app_info.dart` — 5.0.4 (versionCode 201)

---

## 🎯 Новое в версии 5.0.3

### 🔄 Фикс: повтор песен (loop) не работал в режиме изучения
- **Проблема:** в режиме изучения при окончании песни последняя фраза озвучивалась в самом конце и воспроизведение останавливалось (пауза) — loop/переход на следующую не срабатывал
- **Причина:** `onSongComplete` заблокирован пока study mode активен, а сам study mode по завершении песни вызывал `stop()` (пауза) вместо того, чтобы запустить loop/переход
- **Решение:** добавлен callback `StudyModeService.onStudyCompleted`. Когда study mode доходит до конца песни естественно — вызывает callback (НЕ паузит), а PlayerScreen в колбэке триггерит нормальный поток завершения: `_playNextSong()` (для LoopMode.all/allPlaylists/shuffle — переход/зацикливание) или `_playSong(currentSong)` (для LoopMode.one — повтор с начала). `_playSong` при этом перезапускает study mode через persist. Если следующей песни нет (LoopMode.off, последняя) — study mode корректно останавливается

### 🔧 Технические изменения
- `study_mode_service.dart`: поле `VoidCallback? onStudyCompleted`; natural completion в `_runLoop` и `_runContinuousOverlay` (poll + playerStateSub) вызывает callback вместо `stop()` (fallback на `stop()` если callback не задан)
- `player_screen.dart`: `_onStudySongCompleted()` (loop-one → `_playSong(current)`, иначе `_playNextSong`, при отсутствии перехода — `stop()`); подключение `_studyModeService.onStudyCompleted`
- `pubspec.yaml` и `app_info.dart` — 5.0.3 (versionCode 200)

---

## 🎯 Новое в версии 5.0.2

### 🎚️ Уточнённые пресеты скорости речи
- Пресеты скорости речи в настройках режима изучения: `0.3 · 0.4 · 0.5 · 0.6 · 0.7 · 0.8 · 0.9 · 1.0 · 1.1` (равномерный шаг 0.1; было `0.3/0.5/0.7/0.85/1.0/1.25`)

### 🔧 Технические изменения
- `player_screen.dart`: `_studySpeechRates` обновлён на 9 значений с шагом 0.1
- `pubspec.yaml` и `app_info.dart` — 5.0.2 (versionCode 199)

---

## 🎯 Новое в версии 5.0.1

### 🔁 Persist режима говорения — авто-возобновление на смене песни и перемотке
- **Проблема:** хотя флаг persist сохранялся, режим не перезапускался автоматически после переключения песни (кнопка не горела) и после перемотки — нужно было нажимать вручную
- **Причина:** restart в `_playSong` вызывался сразу после `handler.playSong()` — события запуска новой песни конфликтовали с seek+pause режима изучения (race), поэтому старт не «приживался». На перемотке режим просто останавливался без перезапуска
- **Решение:**
  - Новый централизованный helper `_restartStudyIfNeeded({delay})` — проверяет `enabledPersist` + наличие текста + `!isActive`, опционально ждёт, затем `start()` + `setState`
  - **Смена песни:** restart с задержкой ~500мс (даёт воспроизведению «устаканиться» — тот же эффект, что при ручном нажатии)
  - **Тап по строке:** restart сразу после seek
  - **Слайдер-перемотка:** stop на `onChanged` (на старте drag), restart на `onChangeEnd` (после отпускания)
- Теперь при включённом persist режим **корректно перезапускается** и подсвечивает кнопку после смены песни и перемотки без ручного нажатия

### 🎉 Переход на мажор 5.x
- Версия поднята до **5.0.1** (с 4.6.x) — отражает завершённость режима изучения (3 режима TTS, persist, диагностика)

### 🔧 Технические изменения
- `player_screen.dart`: `_restartStudyIfNeeded()`; вызов с задержкой в `_playSong`; restart в обработчике тапа по строке; `onChangeEnd` на слайдере
- `pubspec.yaml` и `app_info.dart` — 5.0.1 (versionCode 198)

---

## 🎯 Новое в версии 4.6.29

### 🔁 Persist режима говорения
- **Проблема:** режим говорения слетал на каждой следующей песне (нужно было включать заново)
- **Решение:** добавлен persist-флаг `studyModeEnabled` в SharedPreferences. Один раз включил — режим **держится при смене песен и после перезапуска приложения**:
  - `_playSong` после загрузки новой песни **перезапускает** study mode (`stop` → `start`), если флаг включён. Чистый stop+start сбрасывает `_isSpeaking`/громкость/фазу → нет «наложений» от предыдущей песни в overlay-режиме
  - При инициализации плеера — авто-старт study mode, если флаг включён
  - Флаг сбрасывается только когда пользователь **сам** выключает режим кнопкой (`stop(userRequested: true)`); внутренние стопы (смена песни, окончание, ошибки) флаг сохраняют

### 🐛 Фикс: перевод/подсветка/индикатор языка не появлялись после смены песни
- **Проблема:** после переключения песни нет перевода, не бежит подсветка строки, нет индикатора языка —直到 pause/play или toggle study mode
- **Решение:** в `_playSong` добавлен `setState` сразу после загрузки переводов (индикатор/перевод обновляются немедленно, без ожидания position-timer); в `_startPositionUpdates` `setState` вынесен из-под условия `isInitialized` — UI обновляется всегда

### 🔧 Технические изменения
- `study_mode_service.dart`: поле `_enabledPersist` + load/save (`studyModeEnabled`); `start()` → `_persistEnabled(true)`; `stop({bool userRequested = false})` сбрасывает флаг только при `userRequested`; `toggle()` → `stop(userRequested: true)`; геттер `enabledPersist`
- `player_screen.dart`: `_maybeAutoStartStudy()` (читает флаг из prefs, стартует study mode); вызов в обоих путях `_initSongData`; перезапуск в `_playSong`; `setState` после `_updateAllLyricsWithTranslations`; relax `isInitialized` в position-timer
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.29

---

## 🎯 Новое в версии 4.6.27 + 4.6.28

### 🐛 Фикс: режим изучения зависал после первой фразы (4.6.27)
- **Проблема:** озвучивалась только первая фраза, далее песня играла без перевода; ручной pause/play повторял ту же фразу
- **Корень (подтверждён диагностическим оверлеем):** таймер границы сегмента создавался ПОСЛЕ `await _resumePlayback()`, а тот вис на `play()` в зомби-состоянии just_audio после перехвата аудиосессии TTS (`playing=true, state=ready`, но позиция не двигалась) → граница никогда не детектилась
- **Решение:**
  - В `_playSegmentAndAwait` таймер границы теперь создаётся **первым**, а `_kickPlayback()` запущен **в фоне (non-blocking)** — детект границы больше не зависит от того, быстро ли очнётся плеер
  - `_kickPlayback`: таймауты (по 1с) на все `await` (`AudioSession`, `setActive`, `play`, `seek`) — виснущий `play()` не держит цикл вечно
  - **Seek-удар по зомби:** если после 2 попыток `play()` позиция не двигается — `_audio.seek(текущая позиция)` заставляет just_audio перебуферизоваться и выйти из зомби
  - Применено в режимах 1/2 (`_playSegmentAndAwait`), режиме 3 (`_runContinuousOverlay`) и overlay (`_speakOver`)

### 🎛️ Настройка «Служебные данные» (4.6.28)
- Диагностический оверлей режима изучения (фаза/индекс/позиция/состояние плеера) теперь **скрыт по умолчанию** и показывается только при включении тумблера «Служебные данные» в Настройках (рядом с «Служебные сообщения»)
- Локализация нового ключа (`serviceData`/`serviceDataSubtitle`) на 11 языков

### 🔧 Технические изменения
- `study_mode_service.dart`: `_kickPlayback` (non-blocking, замена `_resumePlayback`), seek-nudge, таймауты; отладочные геттеры оставлены для оверлея
- `settings_provider.dart`: `showServiceData` + `setShowServiceData` + персистентность
- `settings_screen.dart`: новый `SwitchListTile` (иконка `bug_report_outlined`)
- `player_screen.dart`: условие оверлея через `Provider.of<SettingsProvider>(context).showServiceData`
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.28

---

## 🎯 Новое в версии 4.6.24

### 🐛 Фикс: песня не возобновлялась после озвучки перевода
- **Проблема:** после первой фразы песня замолкала, позиция не двигалась; каждый pause/play стартовал с той же точки (режим 1). Режимы «Сначала оригинал» и «Поверх» не работали. Фикс 4.6.23 (опрос позиции вместо `positionStream`) ловил границу корректно, но фундамент оставался: `play()` после TTS не поднимал воспроизведение
- **Причина:** на Android FlutterTts деактивирует аудиосессию во время речи. Вызов `AudioService.play()` сразу после TTS не возобновлял песню, а старый `_ensurePlaybackResumed` проверял флаг `_audio.player.playing` (он `true` даже когда ОС держит паузу фокуса) → ретрай никогда не срабатывал. Песня молчала, `_currentIndex` не двигался
- **Решение:** новый awaited `_resumePlayback()` — реактивирует `AudioSession`, вызывает `play()` и **проверяет реальное движение позиции** (а не флаг), с ретраями до 5 раз. Применён в `_playSegmentAndAwait` (режимы 1 и 2), `_runContinuousOverlay` (режим 3) и `_speakOver` (возобновление песни после TTS в overlay — чинит «не играет поверх»). Заодно убрана гонка pause/seek на границе сегмента (fire-and-forget паузу из таймера убрали — следующая итерация сама делает `await seek + pause`)

### 🔧 Технические изменения
- `study_mode_service.dart`: импорт `audio_session`; `_resumePlayback()` (замена `_ensurePlaybackResumed`); `_playSegmentAndAwait`/`_runContinuousOverlay`/`_speakOver` используют `_resumePlayback`; убран fire-and-forget `_audio.pause()` из таймера границы
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.24

---

## 🎯 Новое в версии 4.6.23

### 🐛 Фикс: режим изучения не двигался дальше первой фразы
- **Проблема:** в режиме «Сначала перевод» озвучивалась только первая фраза, далее песня играла непрерывно (ручной pause/resume давал ещё по одной фразе); режимы «Сначала оригинал» и «Поверх» не работали вообще
- **Причина:** детект границы сегмента/смены строки был построен на динамической подписке `just_audio.positionStream.listen` — после передачи аудиосессии TTS этот колбэк не срабатывал, и цикл зависал в ожидании. Третий режим (непрерывный overlay) это подтверждал независимо — он целиком на этом потоке и не выдавал ни слова
- **Решение:** граница и смена строки теперь детектятся опросом `_audio.position` через `Timer.periodic` (150 мс) — тот же надёжный источник, что уже используется для подсветки текущей строки (`AudioService` держит постоянную подписку). Заменены `_playSegmentAndAwait` (режимы 1 и 2) и `_runContinuousOverlay` (режим 3); добавлен poll-fallback по `processingState.completed`
- Таймеры гасятся в `_cancelSegmentAwait`, `pauseSession`, `stop`, `dispose`

### 🔧 Технические изменения
- `study_mode_service.dart`: поля `_segmentTimer`/`_overlayTimer`; `_playSegmentAndAwait` и `_runContinuousOverlay` переписаны с `positionStream.listen` на `Timer.periodic` + `_audio.position`; `_cancelSegmentAwait`/`dispose` отменяют новые таймеры
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.23

---

## 🎯 Новое в версии 4.6.22

### 🎧 Режим изучения v3: три режима, исправления, новые настройки
- **3 режима порядка** (в диалоге настроек):
  1. **Сначала перевод** — TTS → фрагмент (пауза во время речи)
  2. **Сначала оригинал** — фрагмент → TTS (пауза во время речи)
  3. **Поверх** — песня играет **непрерывно без пауз**, перевод говорит поверх (ducking); sub-опция «когда говорить»: в начале строки / в конце / в начале и в конце (дефолт — в начале)
- **🐛 Фикс:** после первой фразы режим зависал (аудиосессия деактивировалась во время TTS → `play()` не возобновлялся). Добавлены: watchdog-таймаут TTS, ретрай `play()` до 3 раз, fallback по завершению песни, детальные логи фаз
- **Скорость речи:** дефолт снижен до **0.5** (раньше 1.0 было слишком быстро), пресеты `[0.3, 0.5, 0.7, 0.85, 1.0, 1.25]`
- **Громкость оригинала** в режиме «Поверх» — слайдер 0–100% (дефолт 30%)
- **Регулировка скорости песни** осталась доступной (теперь в меню «...»)

### 🎛️ Перегруппировка AppBar (больше места)
- Из AppBar убраны: autoScroll-toggle и songSpeed
- Добавлена **кнопка-шестерёнка** (`Icons.tune`) рядом с «Изучение» — открывает диалог настроек режима (видимо, не на long-press)
- В меню «...» добавлены: «Автопрокрутка» (чекбокс) + «Скорость песни» (→ диалог speed)

### 🔧 Технические изменения
- `study_mode_service.dart`: enum `OverlayTiming`, поля `_overlayTiming`/`_duckVolume` + персистентность; `_speak` watchdog; `_playSegmentAndAwait` ретрай + fallback; новый `_runContinuousOverlay()` + `_speakOver()`; `start()`/`resumeSession()` ветвятся по режиму через `_startRunner()`
- `player_screen.dart`: AppBar перегруппирован (шестерёнка, убраны autoScroll/songSpeed); popup расширен (autoScroll/songSpeed/share/editMode/...); диалог настроек с timing + слайдер громкости + новые пресеты скорости речи
- Локализация: 6 новых ключей (`studyModeOverlayTiming/AtStart/AtEnd/AtBoth`, `studyModeDuckVolume`, `studyModeOpenSettings`) на 11 языков
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.22

---

## 🎯 Новое в версии 4.6.21

### 🎛️ Перегруппировка кнопок плеера
- **Проблема:** после добавления режима изучения в нижнем ряду стало 9 кнопок — на узких экранах правая («Изучение») уходила за видимую область
- **Решение:** перенесли **«Скорость»** и **«Изучение»** из нижнего ряда в **верхний AppBar** (рядом с autoScroll, с фиксированным размером ≥20px для читаемости «1x»)
- **«Поделиться»** и **«Правка меток»** (toggle режима правки таймингов) переехали в меню **«...»** (плюс разделитель)
- Нижний ряд снова **7 кнопок**: shuffle · prev · replay10 · FAB · forward10 · next · loop — помещается на любых экранах
- Меню «...» теперь: Экспорт песни · Правка меток / Выйти из правки · — · Правка переводов · Импорт ZIP · Загрузить текст · Удалить перевод

### 🔧 Технические изменения
- `player_screen.dart`: из Row нижней панели убраны `_buildSpeedButton`/`_buildStudyModeButton`, `buttonCount` 8 → 7; `AnimatedBuilder(_studyModeService)` сохранён (FAB реагирует на study-состояние)
- `_buildAppBarContent`: убраны `btn(share)` и `btn(edit-toggle)`, добавлены `_buildStudyModeButton(hdrBtnSize)` + `_buildSpeedButton(hdrBtnSize)` после autoScroll
- `PopupMenuButton`: новые ветки `share` → `_exportCurrentSong()`, `editMode` → toggle `_isEditMode`; `PopupMenuDivider` между группами
- Локализация: новый ключ `exportCurrentSong` на 11 языков (`editTimestamps`/`exitEditMode` уже были)
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.21

---

## 🎯 Новое в версии 4.6.20

### 🎧 Настройки режима изучения: порядок и скорость речи
- **Порядок «перевод ↔ оригинал»** — долгое нажатие на кнопке «Изучение» открывает диалог с тремя режимами:
  - **Сначала перевод** (по умолчанию) — TTS озвучивает перевод → играет фрагмент оригинала
  - **Сначала оригинал** — играет фрагмент оригинала → TTS озвучивает перевод
  - **Поверх (ducking)** — перевод звучит одновременно с приглушённым оригиналом (громкость оригинала ~30%), режим ждёт окончания и TTS, и фрагмента без обрезки слов
- **Скорость речи перевода** — ChoiceChip-пресеты: `0.75x · 1.0x (дефолт) · 1.15x · 1.25x · 1.5x · 1.75x`. Применяется мгновенно (`flutter_tts.setSpeechRate`)
- Настройки сохраняются в `SharedPreferences` (`studyModeOrder`, `studyModeSpeechRate`) и применяются к новой сессии

### 🔧 Технические изменения
- `study_mode_service.dart`: enum `StudyModeOrder { translationFirst, originalFirst, overlay }`, свойства `order`/`speechRate`, `_loadSettings()`, `setOrder()`/`setSpeechRate()` с персистентностью; `_runLoop` ветвится по `order` на три обработчика (`_handleTranslationFirst`/`_handleOriginalFirst`/`_handleOverlay`); ducking через `_audio.player.setVolume()` с восстановлением в `pauseSession`/`stop`
- `player_screen.dart`: `_openStudyModeSettings()` (паузит сессию при открытии), `_showStudyModeSettingsDialog()` (StatefulBuilder с RadioListTile + ChoiceChip'ами), `onLongPress` на кнопке study, tooltip с подсказкой о долгом нажатии
- Локализация на 11 языков: ключи `studyModeSettings`, `studyModeOrder`, `studyModeOrderTranslationFirst`, `studyModeOrderOriginalFirst`, `studyModeOrderOverlay`, `studyModeSpeechRate`, `studyModeLongPressHint`
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.20

---

## 🎯 Новое в версии 4.6.19

### 🎧 Режим изучения (Study Mode) — песня с озвучкой перевода
- **Возможность:** кнопка «Изучение» в панели плеера включает режим, в котором для каждой строки песни сначала **озвучивается перевод** (TTS), а затем **проигрывается соответствующий фрагмент песни** — и так до конца трека
- **Сценарий:** русская фраза → кусочек песни с этой фразой → следующий перевод → следующий фрагмент … всю песню
- **Особенности:**
  - Язык озвучки определяется по выбранному переводу (русский → `ru-RU`, английский → `en-US` и т.д.)
  - Строки без перевода просто проигрываются (TTS пропускается)
  - Старт с текущей позиции (ближайшая строка к курсу воспроизведения)
  - Подсветка текущей строки синхронизирована и во время озвучки, и во время фрагмента
  - Главная кнопка Play/Pause в режиме изучения ставит сессию на паузу и возобновляет (FAB: 🎤 при озвучке, ⏸ при фрагменте, ▶ при паузе)
  - Ручной seek (слайдер или тап по строке), смена песни завершают режим изучения
  - Авто-переход к следующей песне при окончании suppressed, пока активен режим изучения

### 🔧 Технические изменения
- Новая зависимость `flutter_tts: ^4.2.0`
- Новый сервис `services/study_mode_service.dart` (`StudyModeService`): координатор TTS + сегментное воспроизведение, состояние `StudyPhase { idle, speaking, playingSegment }`, корректная отмена ожиданий через `Completer` (надёжно на Android, где `stop()` может не резолвить Future от `speak()`)
- `player_screen.dart`: инстанцирование `StudyModeService`, кнопка `_buildStudyModeButton`, обновлённый FAB с учётом study-состояния, остановка режима при смене песни/seek, guard в `onSongComplete`
- Локализация на 11 языков: ключи `studyMode`, `studyModeTooltip`, `studyModeStarted`, `studyModeStopped`, `studyModeNoLyrics`
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.19

---

## 🎯 Новое в версии 4.6.18

### 🎚️ Настройка задержки синхронизации текста (Position Offset)
- **Проблема:** при воспроизведении подсветка строки переходила раньше, чем реально звучал фрагмент (отчасти лечилось фиксом в 4.6.17 с offset 150мс, но фиксированного значения хватало не всем)
- **Решение:** добавлена **ручная настройка** «Задержка синхронизации текста» в Settings → Display (рядом со Scroll Offset)
  - Диапазон: 0.00–1.00с, шаг 0.05с, дефолт 0.15с
  - Значение применяется мгновенно через подписку `PlayerScreen` на `SettingsProvider` — можно прямо во время прослушивания подбирать под песню
- Локализация на 11 языков: ключи `lyricsPositionOffset`, `lyricsPositionOffsetSubtitle`

### 🎯 Автопрокрутка списка к играющей песне
- **Проблема:** при возврате из плеера в список песен (библиотека/плейлист) активная (играющая) песня оказывалась за пределами видимой зоны — приходилось искать её вручную
- **Решение:** при открытии/возврате в `SongLibraryScreen` и `PlaylistSongsScreen` список автоматически прокручивается к текущей песне
  - Песня позиционируется в верхней трети экрана (над ней остаются ~1–2 песни для контекста)
  - Прокрутка мгновенная (`jumpTo`), срабатывает один раз за открытие экрана (флаг `_didInitialScroll`), не мешает ручному скроллу
  - Источник правды — `AudioService.currentSongIdNotifier`

### 🔧 Технические изменения
- `SettingsProvider`: добавлены `_lyricsPositionOffset`, getter, `setLyricsPositionOffset()`, загрузка/сохранение в prefs
- Новый виджет `widgets/settings/lyrics_position_offset_control.dart` (+/- контрол с шагом 0.05с)
- `settings_screen.dart`: новый ListTile в Display-секции
- `player_screen.dart`: в `_loadSettings()` и через `addListener` на `SettingsProvider` вызывается `LyricsService.setPositionOffset()`
- `playlist_songs_screen.dart` / `song_library_screen.dart`: добавлены `ScrollController`, метод `_scrollToCurrentSong()`, `dispose()`
- Синхронизированы версии: `pubspec.yaml` и `app_info.dart` — обе 4.6.18

---

## 🎯 Новое в версии 4.6.17

### 🐛 Фикс: преждевременный переход на следующую строку текста
- **Проблема:** при воспроизведении подсветка текста переходила на следующую строку раньше, чем реально звучал соответствующий фрагмент
- **Причина:** `just_audio` может сообщать позицию с небольшим опережением из-за буферизации и интерполяции позиции, особенно при скорости >1x
- **Решение:** в `LyricsService.updatePosition()` добавлен offset 150мс — поиск строки теперь по `position - offset`, что гарантирует переключение подсветки только когда аудио действительно дошло до метки
- Настройка: `setPositionOffset(double)` в `LyricsService`, дефолт 0.15с, clamp 0-1с

### 🐛 Фикс: рассинхрон песни — текст одной, играет другая
- **Проблема:** текст показывал одну песню, а реально воспроизводилась другая; при переключении кнопкой "следующая песня" мог играть неправильный трек
- **Причины и решения:**
  - **Race condition при быстром переключении:** добавлен мьютекс `_isSongLoading` — если `_playSong()` уже выполняется, новый вызов игнорируется
  - **Двойная загрузка аудио:** убрана повторная загрузка через `handler.playSong()` — теперь аудио загружается ровно один раз
  - **Уведомление прерывало воспроизведение:** `handler.setPlaylist()` + `updateNotification()` вызывались после `play()` и через `mediaItem.add()` могли сбивать воспроизведение — переписано: сначала грузим тексты/переводы, затем **атомарно** `handler.playSong()` (setFilePath + mediaItem + play без async-разрыва)
  - **Skip из уведомления менял песню без ведома PlayerScreen:** добавлены коллбэки `onSkipToNextRequested`/`onSkipToPreviousRequested` в `BackgroundAudioHandler` — нажатие next/prev в уведомлении системы делегируется в `PlayerScreen._playNextSong()`/`_playPreviousSong()`

### 🐛 Фикс: не работало автовключение следующей песни (loop/shuffle)
- **Проблема:** после завершения песни следующая не начинала играть, loop и shuffle не работали
- **Причина:** между `_player.setFilePath()` (loadAudio) и `_player.play()` проходила секунда+ из-за async загрузки переводов — за это время audio session могла деактивироваться, и `play()` не срабатывал
- **Решение:** `_playSong()` переписан — тексты и переводы загружаются **до** загрузки аудио; `handler.playSong()` вызывается **последним** как атомарная операция (load + metadata + play подряд, без async-разрыва)

### 🔧 Технические изменения
- `LyricsService`: добавлен `_positionOffset`, `setPositionOffset()`, `positionOffset` getter
- `BackgroundAudioHandler`: добавлен `updateNotification()` (metadata без reload), `onSkipToNextRequested`/`onSkipToPreviousRequested` коллбэки, `skipToNext()`/`skipToPrevious()` делегируют через коллбэки
- `PlayerScreen._playSong()`: мьютекс `_isSongLoading`, остановка/перезапуск таймера позиций, сброс `_lastScrolledIndex`/`_lastProcessedIndex`/`_lastProcessedLanguageIndex` при переключении песни
- `PlayerScreen._initBackgroundAudio()`: подписка на skip-коллбэки handler'а
- `PlayerScreen.dispose()`: очистка skip-коллбэков

---

## 🎯 Новое в версии 4.6.16

### 🐛 Фикс: перевод виден только на первых строках при переключении песни
- **Проблема:** при переключении на следующую/предыдущую песню перевод отображался только на 3 первых строках, остальные подтягивались по мере воспроизведения
- **Причина:** метод обновления переводов передавал `focusIndex` (текущая строка), из-за чего обновлялись только соседние строки
- **Решение:** разделение на `_updateAllLyricsWithTranslations()` (полная загрузка всех строк) и `_updateLyricsWithTranslations()` (оптимизированное обновление в таймере)
- Полная загрузка применяется при: загрузке песни, смене языка, импорте переводов, возврате из фона

### ⏩ Управление скоростью воспроизведения
- Кнопка скорости "1x" в панели управления плеера (между Forward 10 и Skip Next)
- Диалог выбора из 9 пресетов: 0.5x, 0.75x, 0.8x, 0.9x, **1.0x** (по умолчанию), 1.1x, 1.25x, 1.5x, 2.0x
- Скорость сохраняется между сессиями (SharedPreferences)
- Поддержка фонового воспроизведения — скорость синхронизируется с BackgroundAudioHandler
- Подсветка кнопки при нестандартной скорости (как Shuffle/Loop)
- Локализация на 11 языков: ключи `playbackSpeed`, `speedNormal`

---

## 🎯 Новое в версии 4.6.15

### 🔄 Режим повтора всех плейлистов
- Новый режим `LoopMode.allPlaylists` — после последней песни плейлиста переходит к следующему
- Цикл переключения: off → all → one → allPlaylists → off
- Иконка списка в углу кнопки повтора при активном режиме

### 🎵 Подсветка текущей песни в плейлисте
- Играющая песня подсвечивается цветом `primaryContainer`
- Рамка вокруг карточки цветом `primary`
- Иконка эквалайзера на обложке
- Оптимизировано через `ValueNotifier<String?>` — rebuild только при смене песни

### 🎚️ Настройка смещения временных меток
- Settings → Display → Timestamp Offset (0-180 минут, дефолт 30)
- Сброс временных меток в Translation Editor

### 🐛 Исправления
- **Критический фикс:** серый экран в плейлистах из-за `AnimatedBuilder` внутри `itemBuilder`
- **Фикс:** Slider краш в PlayerScreen при `duration = 0`
- **Фикс:** отсутствующие ключи локализации (11 языков)
- **Фикс:** несуществующая иконка `Icons.timer_reset` → `Icons.restore`

---

## 🎯 Поддерживаемые языки

### Языки интерфейса
- 🇬🇧 English
- 🇷🇺 Русский
- 🇷🇴 Română
- 🇫🇷 Français
- 🇩🇪 Deutsch
- 🇪🇸 Español
- 🇮🇹 Italiano
- 🇵🇹 Português
- 🇨🇳 中文
- 🇸🇦 العربية
- 🇺🇦 Українська

### Языки для переводов
Все языки интерфейса плюс:
- Японский
- Корейский
- Дословный перевод на русский
- Транскрипция (фонетическая)

## 🎼 Форматы файлов

- **LRC** - текст песни с временными метками
- **JSON** - переводы и транскрипция
- **ZIP** - архив с текстом, переводами и транскрипцией
- **MP3/WAV/M4A/OGG** - аудиофайлы

## 🔧 Команды Flutter

```bash
# Запуск приложения
flutter run

# Запуск тестов
flutter test

# Анализ кода
flutter analyze

# Форматирование кода
dart format .

# Сборка APK
flutter build apk --release

# Сборка App Bundle
flutter build appbundle --release
```

## 🔧 Команды Python

```bash
# Генерация текста песен с переводами
python scripts/deepseek_generator_v3.py --text "текст песни" --languages de,en,ru,trans

# Создание LRC и JSON файлов
python scripts/generate_lrc_json.py --input input/song.txt

# Обработка Excel файла с песнями
python scripts/process_excel_songs.py --excel input/songs.xlsx
```

## 🤝 Вклад в проект

Вклад в проект приветствуется! Пожалуйста, следуйте инструкциям в [DEVELOPMENT.md](DEVELOPMENT.md).

## 📄 Лицензия

Этот проект является частным и предназначен для личного использования.

## 📞 Поддержка

**Email:** support@lingotune.com  
**Веб-сайт:** https://lingotune.app

## 🎓 Для кого это приложение?

- Учащиеся иностранным языкам
- Любители музыки
- Преподаватели языков
- Все, кто хочет учить языки через любимые песни

## 🌟 Особенности обучения

- **Естественное запоминание** - через музыку слова запоминаются легче
- **Визуальная привязка** - текст синхронизирован с аудио
- **Множественные переводы** - понимание нюансов перевода
- **Транскрипция** - помощь в произношении
- **Контекстное обучение** - слова и фразы в естественном контексте

---

**LingoTune** - учите языки через музыку! 🎵🌍
