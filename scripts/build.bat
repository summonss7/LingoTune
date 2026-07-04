@echo off
cd /d "%~dp0..\app"
C:\flutter\bin\flutter.bat clean
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat build apk --release
echo Build completed!
