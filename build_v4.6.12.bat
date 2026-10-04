@echo off
chcp 65001 >nul
title LingoTune v4.6.12 Build

echo ====================================
echo Building LingoTune-v4.6.12 APK
echo ====================================
echo.

cd /d "D:\LingoTune\app"

echo [1/5] Clean...
C:\flutter\bin\flutter.bat clean
if errorlevel 1 (
    echo ERROR: flutter clean failed
    pause
    exit /b 1
)

echo.
echo [2/5] Get dependencies...
C:\flutter\bin\flutter.bat pub get
if errorlevel 1 (
    echo ERROR: flutter pub get failed
    pause
    exit /b 1
)

echo.
echo [3/5] Generate localizations...
C:\flutter\bin\flutter.bat gen-l10n
if errorlevel 1 (
    echo ERROR: flutter gen-l10n failed
    pause
    exit /b 1
)

echo.
echo [4/5] Build APK...
C:\flutter\bin\flutter.bat build apk --release
if errorlevel 1 (
    echo ERROR: flutter build apk failed
    pause
    exit /b 1
)

echo.
echo [5/5] Copy to builds folder...
if not exist "..\builds" mkdir "..\builds"
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "..\builds\LingoTune-v4.6.12.apk"

echo.
echo ====================================
echo BUILD SUCCESSFUL!
echo APK: D:\LingoTune\builds\LingoTune-v4.6.12.apk
echo ====================================
echo.
pause