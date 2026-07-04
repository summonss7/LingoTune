$env:Path = "C:\flutter\bin;$env:Path"
cd "$PSScriptRoot\..\app"
flutter clean
flutter pub get
flutter build apk --release
