$env:Path = "C:\flutter\bin;$env:Path"
cd "D:\ProjectAI\LingoTune\app"
flutter clean
flutter pub get
flutter build apk --release
