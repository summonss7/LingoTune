# Настройка окружения LingoTune

## Системные требования

### Минимальные требования
- Windows 10/11
- 4 GB RAM
- 10 GB свободного места на диске

### Рекомендуемые требования
- Windows 11
- 8 GB RAM
- 20 GB свободного места на диске
- SSD диск

## Установка Flutter

### 1. Скачивание Flutter SDK

```bash
# Клонируйте Flutter из GitHub
git clone https://github.com/flutter/flutter.git -b stable C:\flutter

# Или скачайте с официального сайта
# https://docs.flutter.dev/get-started/install/windows
```

### 2. Добавление в PATH

Добавьте `C:\flutter\bin` в системную переменную PATH.

### 3. Проверка установки

```bash
# Откройте новую командную строку и выполните
flutter doctor

# Результат должен показать установленные компоненты
```

### 4. Установка зависимостей Flutter

Flutter Doctor покажет, что нужно установить:

```
Android Studio/IDE с Flutter плагином
Android SDK
Java JDK
```

**Настройка Android SDK:**

```bash
# Установите Android Studio и Android SDK
# Добавьте ANDROID_HOME в PATH:
setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"
setx PATH "%PATH%;%ANDROID_HOME%\platform-tools"
```

### 5. Установка лицензий

```bash
flutter doctor --android-licenses
```

## Установка Python

### 1. Скачивание Python

Скачайте Python 3.8+ с официального сайта: https://www.python.org/downloads/

**Важно:** При установке отметьте "Add Python to PATH"

### 2. Проверка установки

```bash
python --version
# Python 3.8.x или выше
pip --version
```

### 3. Обновление pip

```bash
python -m pip install --upgrade pip
```

## Настройка проекта

### 1. Клонирование/распаковка проекта

```bash
cd D:\Ai-LingoTune
```

### 2. Установка зависимостей Flutter

```bash
cd app
flutter pub get
```

### 3. Установка зависимостей Python

```bash
cd ..
cd scripts
pip install -r requirements.txt
```

Если файл requirements.txt отсутствует, установите зависимости вручную:

```bash
pip install requests
pip install python-dotenv
pip install langdetect
pip install pandas
pip install openpyxl
pip install pyyaml
```

## Конфигурация API ключей

### Получение DeepSeek API ключа

1. Перейдите на https://platform.deepseek.com/
2. Зарегистрируйтесь или войдите
3. Создайте новый API ключ
4. Сохраните ключ

### Настройка .env файла

Создайте файл `.env` в корневой директории проекта:

```bash
# В D:\Ai-LingoTune\
echo "DEEPSEEK_API_KEY=ваш_ключ_здесь" > .env
```

Или создайте файл вручную:

```env
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**ВАЖНО:** Добавьте `.env` в `.gitignore`, чтобы не коммитить API ключи!

## Настройка директорий проекта

Создайте необходимые директории:

```bash
cd D:\Ai-LingoTune

# Создание директорий для уроков
mkdir lessons
mkdir lessons\Arabic
mkdir lessons\English
mkdir lessons\Romanian

# Создание директории для сборки APK
mkdir builds

# Создание директории для входных файлов
mkdir input

# Директория output уже существует
```

## Подключение устройства или эмулятора

### Вариант 1: Реальное устройство Android

1. Включите "Режим разработчика" на телефоне
2. Включите "USB отладку"
3. Подключите телефон по USB
4. Проверьте подключение:

```bash
flutter devices
```

### Вариант 2: Эмулятор Android

1. Откройте Android Studio
2. Создайте виртуальное устройство (AVD)
3. Запустите эмулятор
4. Проверьте подключение:

```bash
flutter devices
```

## Запуск приложения в режиме разработки

```bash
cd D:\Ai-LingoTune\app
flutter run
```

Приложение автоматически соберется и запустится на подключенном устройстве.

## Сборка APK для распространения

### Подготовка к сборке

1. Создайте файл `android/key.properties` в директории `app/android/`:

```properties
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=D:/path/to/your/upload-keystore.jks
```

2. Создайте keystore (если его нет):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

3. Настройте файл `app/android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Сборка release APK

```bash
cd D:\Ai-LingoTune\app

# Сборка APK
flutter build apk --release

# APK будет создан в:
# build/app/outputs/flutter-apk/app-release.apk

# Копирование в папку builds
copy build\app\outputs\flutter-apk\app-release.apk ..\builds\LingoTune-v4.3.3.apk
```

### Сборка App Bundle (для Google Play)

```bash
flutter build appbundle --release

# AAB будет создан в:
# build/app/outputs/bundle/release/app-release.aab
```

## Настройка AndroidManifest

Проверьте файл `app/android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.lingotune.app">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>

    <application
        android:label="LingoTune"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:requestLegacyExternalStorage="true">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <service
            android:name="com.ryanheise.audioservice.AudioService"
            android:exported="true"
            android:foregroundServiceType="mediaPlayback">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>
    </application>
</manifest>
```

## Тестирование окружения

### 1. Проверка Flutter

```bash
cd app
flutter doctor -v

# Должен показать:
# Flutter version: 3.x.x
# Android toolchain - develop for Android devices
# Android Studio - version
# Connected device - ваше устройство или эмулятор
```

### 2. Проверка Python

```bash
python --version

# Проверка библиотек
python -c "import requests, dotenv, langdetect; print('OK')"
```

### 3. Проверка API ключа

```bash
python scripts/deepseek_generator_v3.py --test
```

### 4. Запуск тестов Flutter

```bash
cd app
flutter test
```

## Сборка с помощью скриптов

Проект включает batch файлы для автоматизации сборки:

### adb_master.bat

Создайте файл в корне проекта:

```batch
@echo off
cd app
flutter build apk --release
copy build\app\outputs\flutter-apk\app-release.apk ..\builds\LingoTune-v4.3.3.apk
echo APK built successfully!
pause
```

### create_lyrics.bat

```batch
@echo off
python scripts/deepseek_generator_v3.py %*
pause
```

## Настройка IDE

### Visual Studio Code

1. Установите Flutter расширение
2. Установите Dart расширение
3. Установите Python расширение
4. Откройте директорию `D:\Ai-LingoTune\app`
5. Установите кодек (codeLens) для Flutter

### Android Studio

1. Установите Flutter плагин
2. Установите Dart плагин
3. Откройте директорию `D:\Ai-LingoTune\app`
4. Выберите "Open Android Studio Project in Android Studio"

## Решение проблем

### Проблема: Flutter command not found

**Решение:** Добавьте `C:\flutter\bin` в PATH и перезагрузите командную строку

### Проблема: Android SDK not found

**Решение:**
```bash
flutter doctor --android-licenses
```

### Проблема: Device not found

**Решение:**
```bash
flutter devices
adb devices
```

Если устройство не отображается:
- Перезагрузите adb: `adb kill-server && adb start-server`
- Проверьте USB отладку на устройстве
- Переустановите драйверы устройства

### Проблема: Python module not found

**Решение:**
```bash
pip install requests python-dotenv langdetect pandas openpyxl
```

### Проблема: API ключ не работает

**Решение:**
1. Проверьте файл `.env`
2. Убедитесь, что ключ правильный
3. Проверьте баланс на DeepSeek
4. Попробуйте заново создать ключ

### Проблема: Ошибка при сборке APK

**Решение:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Проблема: Мало места на диске

**Решение:**
- Очистите кэш Flutter: `flutter clean`
- Очистите кэш Gradle: Удалите `~/.gradle/caches`
- Увеличьте место на диске

## Следующие шаги

- [ ] Установите Flutter SDK
- [ ] Установите Python 3.8+
- [ ] Получите DeepSeek API ключ
- [ ] Настройте .env файл
- [ ] Создайте директории проекта
- [ ] Подключите устройство Android
- [ ] Запустите приложение: `flutter run`
- [ ] Соберите APK: `flutter build apk --release`

## Дополнительные ресурсы

- [Flutter documentation](https://docs.flutter.dev/)
- [DeepSeek API docs](https://platform.deepseek.com/api-docs/)
- [Android development guide](https://developer.android.com/docs)

---

Дополнительная информация:
- [Архитектура](ARCHITECTURE.md)
- [Форматы данных](DATA_FORMATS.md)
- [Руководство по API](API_GUIDE.md)
