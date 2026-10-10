# 🎵 LingoTune — изучение языков через музыку

**Версия:** 5.8.12 (versionCode 240) · **Платформа:** Android (Flutter 3.0+) ·
**Разработчики:** Z.AI GLM & Цимбалов Артем

LingoTune — приложение для изучения иностранных языков через музыку: слушайте
песни с синхронизированным построчным текстом, переводами и транскрипцией,
а в режиме изучения приложение озвучивает перевод каждой строки (TTS) поверх
музыки.

## Ключевые возможности

- 🎵 Воспроизведение MP3/WAV/M4A/OGG, фоновый режим с медиа-уведомлением
- 📝 Синхронизированный текст (LRC) с точным таймингом и автопрокруткой
- 🌍 Переводы строк на 14 языков + фонетическая транскрипция, встроенный редактор
- 🎧 **Режим изучения** — озвучка перевода (TTS) и фрагмент песни для каждой строки; порядок «перевод/оригинал/наложение», скорость речи, настройки на уровень песни
- 🗣️ TTS-движки: системный (flutter_tts) или офлайн-нейронный (sherpa_onnx VITS, модель ~63 МБ загружается по требованию)
- 📞 Пауза при звонке (нативный TelephonyManager) и при отключении наушников, умное возобновление после разговора
- 🚗 Детекция приближающегося транспорта по микрофону (FFT, on-device) с калибровкой — безопасность бегуна
- ❤️ Избранное — глобальная корзина favorites, отдельная закладка
- 🎨 Настраиваемые цвета подсветки оригинала и перевода
- ⏩ Скорость воспроизведения 0.5x–2.0x, повтор/перемешивание
- 🤖 AI-генерация текстов и переводов (DeepSeek), поиск текстов онлайн
- 🌐 Интерфейс на 11 языках

## Структура проекта

```
LingoTune/
├── app/                    # Flutter-приложение (Dart)
│   ├── lib/
│   │   ├── models/         # Song, Translation, LyricLine, Playlist...
│   │   ├── services/       # AudioService, StudyModeService, DatabaseService,
│   │   │                   #   TtsCoordinator + tts/, PhoneCallService, ...
│   │   ├── screens/        # PlayerScreen, SongLibraryScreen, SettingsScreen...
│   │   ├── widgets/        # Переиспользуемые компоненты
│   │   ├── utils/          # FFT, LrcFormatter, LyricColors...
│   │   ├── constants/      # DeepSeekPrompts, GenerationConstants
│   │   └── l10n/           # 11 локалей
│   └── pubspec.yaml
├── scripts/                # Python: генерация текстов/переводов, TTS-пайплайн, Demucs
├── input/ output/ media/   # Данные пайплайна контента
├── lessons/                # Уроки по языкам
├── builds/                 # Собранные APK
└── docs/                   # Документация
```

## Быстрый старт

```bash
# Требуется: Flutter SDK 3.0+, Python 3.8+, Android SDK, ключ DeepSeek API

cd app
flutter pub get
flutter run                    # запуск на устройстве/эмуляторе

flutter test                   # тесты
flutter analyze                # линтер
flutter build apk --release    # APK → app/build/app/outputs/flutter-apk/
```

API-ключ: создайте `.env` в корне — `DEEPSEEK_API_KEY=sk-...`.
Подробности: [docs/SETUP.md](docs/SETUP.md).

## 📖 Документация

| Документ | Назначение |
|---|---|
| [AGENTS.md](AGENTS.md) | **Основной документ для разработки**: команды, конвенции, архитектура сервисов, известные подводные камни (актуализируется каждым релизом) |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Архитектура системы и компонентов |
| [docs/CONTENT_PIPELINE.md](docs/CONTENT_PIPELINE.md) | Полный цикл создания контента: текст → DeepSeek → LRC/JSON/ZIP → SUNO → импорт; локальный TTS-пайплайн перевода песен |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | История версий v4.6.15 → 5.8.2 |
| [docs/SETUP.md](docs/SETUP.md) | Настройка окружения (Windows) |
| [docs/DATA_FORMATS.md](docs/DATA_FORMATS.md) | Форматы LRC / JSON / ZIP / аудио |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Решение проблем, известные причуды Android OEM-прошивок |
| [docs/plans/](docs/plans/) | Активные планы разработки |
| [docs/archive/](docs/archive/) | Архив: завершённые планы, устаревшие документы |

Детальные листы изменений каждого релиза — в `CHANGELOG_v*.dart` в корне
(релизный ритуал, см. AGENTS.md).

Накопительный журнал всех правок (включая записи из `promt.txt`, перенесённые
целиком карточкой scheduler-033) — в [CHANGELOG.md](CHANGELOG.md) в корне
репозитория: новые записи дописываются в конец при каждой правке.

## Поддерживаемые языки

**Интерфейс (11):** English, Русский, Română, Français, Deutsch, Español,
Italiano, Português, 中文, العربية, Українська.

**Переводы песен:** все языки интерфейса + 日本語, 한국어, дословный русский
(`ru_literal`), фонетическая транскрипция (`trans`).
