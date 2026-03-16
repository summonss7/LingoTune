@echo off
echo ====================================
echo Building LingoTune-v3.84.0 APK
echo ====================================

cd app
echo Running flutter pub get...
C:\flutter\bin\flutter.bat pub get
if errorlevel 1 (
    echo ERROR: flutter pub get failed
    pause
    exit /b 1
)

echo.
echo Generating localizations...
C:\flutter\bin\flutter.bat gen-l10n
if errorlevel 1 (
    echo ERROR: flutter gen-l10n failed
    pause
    exit /b 1
)

echo.
echo Building APK...
C:\flutter\bin\flutter.bat build apk --release
if errorlevel 1 (
    echo ERROR: flutter build apk failed
    pause
    exit /b 1
)

echo.
echo ====================================
echo Copying APK to builds folder
echo ====================================
if not exist "..\builds" mkdir "..\builds"
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "..\builds\LingoTune-v3.84.0.apk"

echo.
echo ====================================
echo BUILD SUCCESSFUL!
echo APK: D:\ProjectAI\LingoTune\builds\LingoTune-v3.84.0.apk
echo ====================================
pause
