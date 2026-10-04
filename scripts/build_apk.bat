@echo off
echo ====================================
echo Building LingoTune-v4.6.12 APK
echo ====================================

cd /d "D:\LingoTune\app"
if errorlevel 1 (
    echo ERROR: cannot cd to D:\LingoTune\app
    pause
    exit /b 1
)
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
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "..\builds\LingoTune-v4.6.12.apk"

echo.
echo ====================================
echo BUILD SUCCESSFUL!
echo APK: D:\LingoTune\builds\LingoTune-v4.6.12.apk
echo ====================================
pause
