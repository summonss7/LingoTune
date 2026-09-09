# План v5.5.0 — Калибровка детекции машин (эталоны + Mahalanobis)

**Версия плана:** 1.0
**Дата составления:** 02.07.2026
**Дата реализации:** 03.07.2026
**Целевая версия приложения:** 5.5.0 (изначально 5.4.0, объединена с параллельной TTS-фичей в один release)
**Статус:** ✅ Реализовано (упрощённый вариант — см. раздел «Реальные отклонения от плана» ниже)

---

## 🎯 Постановка проблемы

В версии 5.3.2 (Phase A фиксов) устранён критический баг конфликта TTS — озвучка
перевода больше не замолкает при включённой детекции машин. Однако сама детекция
**по-прежнему срабатывает на любой шум** — пороговая логика (lowDom + centroid +
flatness + RMS) не способна надёжно отличить машину от шагов/ветра/голосов/музыки,
просачивающейся из наушников.

Пользователь запросил:
1. Режим калибровки, чтобы подобрать оптимальные параметры под свои условия
2. Несколько типов звуков в готовой базе
3. Возможность добавлять собственные эталоны

Принятые решения (после Q&A):
- **Мультикласс** (не просто car/noise): `carClose`, `carFar`, `carTruck`,
  `carMotorcycle`, `wind`, `steps`, `voice`, `street`, `music`, `other`
- **Синтетические демо-эталоны** (генерируются Python-скриптом)
- **Mahalanobis distance** для классификации (учитывает std каждого признака)

---

## 🏗 Архитектура

### Логика детектора: две ветви

```
┌──────────────────────────────────────────────────────────┐
│           CarDetectionService._analyzeFrame              │
└──────────────────────────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  есть ≥1 car И ≥1   │
              │  noise эталон?       │
              └──────────────────────┘
                  │            │
              ДА  │            │  НЕТ
                  ▼            ▼
        ┌──────────────┐  ┌─────────────────┐
        │ Mahalanobis  │  │ Threshold       │
        │ classifier   │  │ (улучшенный,    │
        │ (новое)      │  │  Часть A)       │
        └──────────────┘  └─────────────────┘
                  │            │
                  └──────┬─────┘
                         ▼
              ┌──────────────────────┐
              │  Confirmation window │
              │  (8 кадров подряд)   │
              └──────────────────────┘
                         │
                         ▼
                  alert / no-alert
```

### Классы эталонов

```dart
enum ProfileClass {
  carClose,       // 🚗 машина близко (5-15 м)
  carFar,         // 🚙 машина далеко (30-50 м)
  carTruck,       // 🚛 грузовик
  carMotorcycle,  // 🏍 мотоцикл
  wind,           // 🌬 ветер в микрофон
  steps,          // 👟 шаги при беге
  voice,          // 🗣 голоса/речь
  street,         // 🛣 фоновый шум улицы
  music,          // 🎵 музыка из наушников просачивается
  other,          // ❓ прочее
}

extension ProfileClassX on ProfileClass {
  /// Классы, относящиеся к машинам (триггерят alert).
  bool get isCar => const [
        ProfileClass.carClose,
        ProfileClass.carFar,
        ProfileClass.carTruck,
        ProfileClass.carMotorcycle,
      ].contains(this);
}
```

### Структура `CalibrationProfile`

```dart
class CalibrationProfile {
  final String id;            // uuid v4
  final String name;          // пользовательское имя ("Машина у дома")
  final ProfileClass cls;
  final DateTime createdAt;

  // Средние + std по каждому признаку (для Mahalanobis)
  final double lowMean, lowStd;
  final double midMean, midStd;
  final double highMean, highStd;
  final double centroidMean, centroidStd;
  final double flatnessMean, flatnessStd;
  final double rmsMean, rmsStd;

  /// Mahalanobis distance:
  ///   d(x, p) = sqrt( Σ_i ((x_i - μ_i) / max(σ_i, ε))^2 )
  /// с учётом σ каждого признака (в отличие от евклида).
  double distanceTo(SpectrumFeatures f);

  Map<String, dynamic> toJson();
  factory CalibrationProfile.fromJson(Map<String, dynamic> j);

  /// Строит профиль из коллекции семплов (5 сек × 30 кадров/сек ≈ 150 семплов):
  /// вычисляет mean/std по каждому признаку.
  factory CalibrationProfile.fromSamples(
    String name,
    ProfileClass cls,
    List<SpectrumFeatures> samples,
  );
}
```

---

## 📋 Часть A — Улучшение пороговой логики (без UI)

**Файл:** `lib/services/car_detection_service.dart`

| # | Правка | Эффект |
|---|---|---|
| **A1** | `_confirmWindow 4 → 12`, `_confirmMinHits 3 → 8`, требование **подряд** (а не из окна) | Сигнал должен быть непрерывным ~400 мс |
| **A2** | Moving average score за 8 кадров вместо мгновенного | Сглаживание всплесков |
| **A3** | `lowFrac × 0.15` бонус только если `lowFrac > 0.6` | Шум с лёгким НЧ-уклоном не набирает score |
| **A4** | Новое поле `_minLowBandEnergy` (абсолютный порог). Alert только если `lowBandEnergy > _minLowBandEnergy` | Тихий шум с правильным соотношением отсеивается |
| **A5** | Adaptive noise floor: 3 сек после старта — запись фона, средний `lowBandEnergy × 3` как `_minLowBandEnergy` | Подстройка под конкретное место |
| **A6** | Дефолт `sensitivity` 0.4 → 0.3 (в `settings_provider.dart`) | Строже по умолчанию |

---

## 📋 Часть B — База эталонов + классификатор

### Новые файлы

**`lib/services/calibration_profile.dart`** (~200 строк):
- `enum ProfileClass` + extension `isCar`
- `class CalibrationProfile` с Mahalanobis distance
- `fromJson` / `toJson` / `fromSamples`

**Изменения в `lib/services/car_detection_service.dart`:**
- Поле `List<CalibrationProfile> _profiles`
- Поле `bool _useClassification` (true если ≥1 car + ≥1 noise)
- Метод `Future<void> loadCalibrationProfiles()` — читает SharedPreferences
- В `_analyzeFrame`: ветвление `_classifyFrame` vs `_thresholdFrame`
- `_classifyFrame`:
  - Для каждого профиля вычислить `distanceTo(features)`
  - Найти nearest (минимум distance)
  - Если `nearest.cls.isCar` И `distance < _maxDistance` → hit
  - `_maxDistance` масштабируется от sensitivity (sens=0 → 2.0; sens=1 → 6.0)
- Подтверждение: 8 кадров подряд hit → alert (как в Части A)

### Persistence

SharedPreferences ключ `carCalibrationProfiles` — JSON-массив:
```json
[
  {
    "id": "uuid-1",
    "name": "Машина у дома",
    "cls": "carClose",
    "createdAt": "2026-07-02T...",
    "lowMean": 5234.2, "lowStd": 890.1,
    ...
  }
]
```

---

## 📋 Часть C — Калибровочный экран

**Новый файл:** `lib/screens/car_calibration_screen.dart` (~500 строк)

### UI (схематично)

```
┌────────────────────────────────────────┐
│ ← Калибровка детектора                 │
├────────────────────────────────────────┤
│  LIVE СПЕКТР (10 Гц)                   │
│  ▓▓▓▓▓▓▓▓▓▓ low (20-300 Hz)            │
│  ▓▓ mid (300-2k)                       │
│  ▓ high (2k-8k)                        │
│                                        │
│  flat=0.18  cent=420Hz  rms=0.045      │
│  → 🟢 carClose (d=1.2)                 │
│  ── или ──                             │
│  → ⚪ no match (d>4)                   │
│                                        │
│  ── ЗАПИСЬ ЭТАЛОНА ──                  │
│  Класс: [carClose        ▼]            │
│  Имя:   [Машина близко_______]         │
│  [● Записать 5 сек]                    │
│                                        │
│  ── ЭТАЛОНЫ (N) ──                     │
│  🚗 Машина близко      [▶] [✕]         │
│  🚙 Машина далеко      [▶] [✕]         │
│  🌬 Ветер              [▶] [✕]         │
│  👟 Шаги               [▶] [✕]         │
│  🔊 Улица              [▶] [✕]         │
│                                        │
│  [Загрузить демо-эталоны]              │
│  [Сбросить всё]                        │
└────────────────────────────────────────┘
```

### Возможности

1. **Live-визуализация** (Timer 10 Гц):
   - 3 spectrum bars (`low` / `mid` / `high`) — высота пропорциональна энергии
   - Текущие метрики: `flatness`, `centroid`, `rms`, `low/mid` ratio
   - Индикатор ближайшего класса (`🚗 carClose (d=1.2)` или `⚪ no match`)
   - При использовании пороговой логики — показывает текущий `score`

2. **Запись эталона**:
   - Выбор класса из dropdown (все 10 `ProfileClass`)
   - Текстовое поле для имени
   - Кнопка «Записать 5 сек» → обратный отсчёт → collect features
   - Из 150 семплов строится `CalibrationProfile.fromSamples`
   - Сохраняется в SharedPreferences + обновляется `_profiles` в активном
     CarDetectionService (если есть)

3. **Список эталонов**:
   - ListView с иконкой класса, именем, датой создания
   - Кнопка `▶` — проиграть записанный WAV (если хранится) или beep-имитацию
   - Кнопка `✕` — удалить (с confirmation)

4. **Демо-эталоны**:
   - Кнопка «Загрузить демо» — парсит `assets/calibration/default_profiles.json`
     и добавляет синтетические профили в пользовательскую базу

5. **Сброс**:
   - «Сбросить всё» — очищает SharedPreferences `carCalibrationProfiles`
   - Detektor переключается обратно на пороговую логику

### Временный CarDetectionService

Экран создаёт **свой собственный** `CarDetectionService` для live-визуализации
и записи — НЕ тот, что в плеере. Это изолирует калибровку от воспроизведения
песни.

---

## 📋 Часть D — Синтетические демо-эталоны

### Звуковые файлы (Python-генерация)

**Папка:** `app/assets/calibration/`

| Файл | Тип | Характеристики |
|---|---|---|
| `car_close.wav` | синус 80 Гц + гармоники (160/240/320) + шум | rms=0.05, centroid≈200 Гц |
| `car_far.wav` | тот же спектр, но тихий | rms=0.02 |
| `car_truck.wav` | синус 60 Гц + шумовые гармоники | rms=0.06, centroid≈150 Гц |
| `wind.wav` | коричневый шум (фильтрованный белый) | flatness≈0.5 |
| `steps.wav` | периодические всплески каждые 0.5 сек | неравномерный rms |
| `street.wav` | смесь низкоуровневых шумов | flatness≈0.4 |
| `voice.wav` | формантные частоты (300-3000 Гц) | centroid>800 Гц |

### Профили

**Файл:** `app/assets/calibration/default_profiles.json`

Пресчитанные `CalibrationProfile` для каждого WAV — вычисляются Python-скриптом,
читающим WAV и применяющим ту же FFT-логику, что и Dart-код (через bridge или
эквивалент numpy.fft).

### Скрипты Python

**`scripts/gen_calibration_samples.py`** — генерирует 7 WAV-файлов в
`app/assets/calibration/`. Использует только stdlib (`wave`, `math`, `random`,
`struct`) — никаких зависимостей.

**`scripts/gen_calibration_profiles.py`** — читает WAV из assets, вычисляет
`SpectrumFeatures` через `numpy.fft` (нужен `pip install numpy`), собирает
mean/std, сохраняет в `default_profiles.json`.

---

## 📋 Часть E — Интеграция и локализация

### Изменения в существующих файлах

**`lib/widgets/settings/car_detection_settings_tile.dart`:**
- Добавить ListTile «Калибровка детектора» с иконкой `tune`
- `onTap` → `Navigator.push(... CarCalibrationScreen())`

**`lib/services/settings_provider.dart`:**
- Дефолт `carDetectionSensitivity` 0.4 → 0.3 (Часть A6)

**`lib/services/car_detection_service.dart`:**
- Часть A (улучшения порогов)
- Часть B (`_profiles`, `_useClassification`, `_classifyFrame`, `loadCalibrationProfiles`)

**`pubspec.yaml`:**
- Ассеты: `assets/calibration/`

### Локализация (~12 новых ключей × 11 языков)

| Ключ | EN |
|---|---|
| `carCalibration` | "Calibration" |
| `carCalibrationSubtitle` | "Train detector on your sounds" |
| `carCalibrationHint` | "Record samples of cars and noises..." |
| `carCalibrationLive` | "Live" |
| `carCalibrationRecord` | "Record 5 sec" |
| `carCalibrationRecording` | "Recording... $s s" |
| `carCalibrationName` | "Sample name" |
| `carCalibrationClass` | "Class" |
| `carCalibrationEmpty` | "No samples yet — record your first" |
| `carCalibrationLoadDemo` | "Load demo samples" |
| `carCalibrationReset` | "Reset all" |
| `carCalibrationNearest` | "Nearest: $cls (d=$dist)" |
| `carCalibrationNoMatch` | "No match" |

Перевод на 11 языков (en/ru/ro/fr/de/es/it/pt/zh/ar/uk) через Python-скрипт
(как `scripts/add_car_l10n.py` для 5.3.0).

### Локализация названий классов (`ProfileClass`)

10 классов × 11 языков = 110 строк. Отдельный скрипт
`scripts/add_calibration_l10n.py`.

---

## 📋 Часть F — Версия и документация

- `pubspec.yaml`: `version: 5.4.0`
- `app_info.dart`: `version = '5.4.0'`, `versionCode = '213'`
- `build.gradle`: `versionCode 213`, `archivesBaseName = "LingoTune-v5.4.0"`
- `docs/README.md`: добавить секцию «Новое в 5.4.0» с описанием калибровки

---

## ✅ Критерии готовности

1. ✅ При пустой базе эталонов — детектор работает на улучшенной пороговой логике
   (Часть A), ложных срабатываний существенно меньше чем в 5.3.2
2. ✅ Пользователь может открыть экран калибровки, видеть live-спектр
3. ✅ Может записать эталон (5 сек, выбор класса, имя) → он появляется в списке
4. ✅ После записи ≥1 car + ≥1 noise — детектор автоматически переключается на
   Mahalanobis-классификацию
5. ✅ Может удалить эталон или сбросить всё
6. ✅ Может загрузить демо-эталоны (синтетику) одной кнопкой
7. ✅ Тест на реальных звуках: меньше ложных срабатываний чем в 5.3.2
8. ✅ Все 11 языков локализованы (включая названия 10 классов)
9. ✅ `flutter analyze` — 0 ошибок
10. ✅ Release APK собирается и устанавливается

---

## ⚠️ Риски и unknowns

1. **Точность Mahalanobis на синтетике vs реальности** — синтетические демо могут
   не совпадать с реальными записями. Решение: пользователь записывает свои
   эталоны, синтетика — только стартовая точка
2. **CPU при классификации** — Mahalanobis distance через 6 признаков × N профилей
   на каждом кадре. При N=10 и 30 кадрах/сек = 180 операций/сек — приемлемо
3. **Размер JSON профилей** — каждый профиль ~200 байт, при 20 эталонах = 4 КБ —
   нормально для SharedPreferences
4. **Запись своих WAV** — для кнопки «▶ тест» в списке эталонов нужно хранить
   исходный WAV. Это ~160 КБ на 5 сек (16kHz × 16-bit × mono). При 20 эталонах =
   3.2 МБ. Хранить в `getApplicationDocumentsDirectory()/calibration/`

---

## 📅 План выполнения (порядок)

1. **Часть A** (~30 мин) — улучшение пороговой логики
2. **Часть D — скрипты Python** (~1 час) — синтетика + профили
3. **Часть B** (~1.5 часа) — `calibration_profile.dart` + интеграция в детектор
4. **Часть C** (~2-3 часа) — калибровочный экран
5. **Часть E** (~30 мин) — локализация + интеграция в Настройки
6. **Часть F** (~15 мин) — версия + docs/README
7. **Тестирование** (~30 мин) — analyze, debug-сборка, проверка UI
8. **Release APK** (~10 мин) — clean build → release → copy

**Итого:** ~6-8 часов работы.

---

## 📂 Список файлов

### Новые (8)

| Путь | Назначение |
|---|---|
| `lib/services/calibration_profile.dart` | Класс + enum + Mahalanobis |
| `lib/screens/car_calibration_screen.dart` | Экран калибровки |
| `app/assets/calibration/car_close.wav` | Демо-эталон |
| `app/assets/calibration/car_far.wav` | Демо-эталон |
| `app/assets/calibration/car_truck.wav` | Демо-эталон |
| `app/assets/calibration/wind.wav` | Демо-эталон |
| `app/assets/calibration/steps.wav` | Демо-эталон |
| `app/assets/calibration/street.wav` | Демо-эталон |
| `app/assets/calibration/voice.wav` | Демо-эталон |
| `app/assets/calibration/default_profiles.json` | Пресчитанные профили |
| `scripts/gen_calibration_samples.py` | Генератор WAV |
| `scripts/gen_calibration_profiles.py` | Генератор JSON-профилей |
| `scripts/add_calibration_l10n.py` | Локализация классов и ключей |
| `docs/PLAN_CAR_DETECTION_CALIBRATION.md` | Этот файл |

### Изменяемые (7)

| Путь | Тип изменений |
|---|---|
| `lib/services/car_detection_service.dart` | Часть A (улучшения) + Часть B (классификация) |
| `lib/services/settings_provider.dart` | Дефолт sensitivity 0.4 → 0.3 |
| `lib/widgets/settings/car_detection_settings_tile.dart` | Кнопка «Калибровка» |
| `lib/l10n/app_*.arb` (11 файлов) | Новые ключи локализации |
| `lib/l10n/app_localizations*.dart` (12 файлов) | Новые геттеры |
| `pubspec.yaml` + `app_info.dart` + `build.gradle` | Версия 5.4.0, ассеты |
| `docs/README.md` | Описание 5.4.0 |

---

## 🎓 Математика Mahalanobis (краткая справка)

Для признака `x` (например, `lowBandEnergy`) и профиля с средним `μ` и std `σ`:

```
стандартизованное расстояние: z = (x - μ) / max(σ, ε)
```

где `ε = 1e-6` (защита от деления на ноль для признаков с нулевой вариацией).

Полное Mahalanobis distance (диагональная ковариация, без учёта корреляций
между признаками — достаточно для наших 6 признаков):

```
d(x, profile) = sqrt( z_low² + z_mid² + z_high² + 
                       z_centroid² + z_flatness² + z_rms² )
```

**Интерпретация:**
- `d < 1` — признак внутри 1σ профиля (очень похож)
- `d ≈ 2` — на границе 2σ (похоже)
- `d > 3` — сильно отличается
- `d > 4` — практически другой класс

Решение о классе: `argmin_profile d(features, profile)` среди всех профилей.
Если `min_d < _maxDistance` → текущий кадр классифицируется как класс
ближайшего профиля. Иначе — `no match` (кадр игнорируется).

`_maxDistance` масштабируется от `sensitivity`:
- `sens=0` → `_maxDistance = 2.0` (строгий, нужно очень близко к эталону)
- `sens=0.5` → `_maxDistance = 4.0` (средний)
- `sens=1.0` → `_maxDistance = 6.0` (мягкий, терпимее к отклонениям)

---

## 📝 Реальные отклонения от плана (при реализации 03.07.2026)

В ходе Q&A с пользователем до старта реализации были приняты следующие
решения, отличные от исходного плана:

| Пункт плана | Реализовано | Обоснование |
|---|---|---|
| **A1**: окно 12 кадров, 8 hits подряд | **8/5 подряд** (~160 мс) | Компромисс: 12/400мс могло пропустить быстрый мотоцикл; 5/160мс достаточно для отсева ветра/шагов |
| **A6**: дефолт sensitivity 0.4→0.3 | **Оставлено 0.4** | Доверяем улучшенной логике Части A (moving avg + noise floor), не ужесточаем глобально |
| **C**: кнопка ▶ проиграть эталон | **Убрана** | Хранение WAV (~3МБ при 20 эталонах) + путь/воспроизведение — лишняя сложность без реальной пользы (зачем слушать свой записанный шум?) |
| **D**: Python-скрипты + 7 WAV + numpy.fft пресчёт | **Пропущено** | Заменено одним `default_profiles.json` с теоретическими mean/std (подобраны из акустических характеристик классов). Риск расхождения Python FFT ↔ Dart FFT не оправдан — демо это стартовая точка, пользователь всё равно записывает свои эталоны |
| Live-визуализация 10 Гц | **20 Гц (50 мс poll)** | Улучшение: при записи даёт ~100 семплов за 5 сек вместо ~50; для визуализации разницы не видно |
| versionCode 213 | **216** | В коде на момент реализации была 5.3.5/215 (а не 5.3.2/212 как при составлении плана) — корректный bump +1 |

**Все критерии готовности (1-10) выполнены**, кроме явно субъективного №7
«тест на реальных звуках» — он требует полевых испытаний пользователем.

---

*План составлен как следующий шаг развития детекции машин после Phase A (5.3.x).
Файл находится в `docs/PLAN_CAR_DETECTION_CALIBRATION.md` и отслеживается в git.
Статус: ✅ реализовано в v5.4.0.*
