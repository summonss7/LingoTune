@echo off
cd /d "D:\Ai-Projects\LingoTune\app"
C:\flutter\bin\flutter.bat clean
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat build apk --release
echo Build completed!
