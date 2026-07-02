# LingoTune v5.3.0 Build Script (Car Detection feature)
# Run this script to build the release APK
#
# Серьёзные изменения с 5.2.0:
#   - Новая фича: детекция машин через микрофон (FFT on-device)
#   - Новый пакет: record 7.1.1 (запись PCM 16kHz)
#   - Новые permissions: RECORD_AUDIO, MODIFY_AUDIO_SETTINGS,
#     FOREGROUND_SERVICE_MICROPHONE, VIBRATE
#   - 4 новых ассета: assets/sounds/car_alert.wav
#   - versionCode 183 -> 210 (синхронизирован с app_info.dart)

$ErrorActionPreference = "Stop"

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Building LingoTune-v5.3.0 APK (Car Detection)" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

$appDir = "D:\Ai-LingoTune\app"
$buildsDir = "D:\Ai-LingoTune\builds"
$flutter = "C:\flutter\bin\flutter.bat"

Set-Location $appDir

Write-Host ""
Write-Host "Step 1: Clean (mandatory after record 5 -> 7 upgrade)..." -ForegroundColor Yellow
& $flutter clean

Write-Host ""
Write-Host "Step 2: Get dependencies..." -ForegroundColor Yellow
& $flutter pub get

Write-Host ""
Write-Host "Step 3: Build release APK..." -ForegroundColor Yellow
& $flutter build apk --release

Write-Host ""
Write-Host "Step 4: Copy to builds folder..." -ForegroundColor Yellow
if (-not (Test-Path $buildsDir)) {
    New-Item -ItemType Directory -Path $buildsDir | Out-Null
}
$srcApk = Join-Path $appDir "build\app\outputs\flutter-apk\app-release.apk"
$dstApk = Join-Path $buildsDir "LingoTune-v5.3.0.apk"
Copy-Item -Path $srcApk -Destination $dstApk -Force

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "APK: $dstApk" -ForegroundColor Green
$size = (Get-Item $dstApk).Length
Write-Host ("Size: {0:N0} bytes ({1:N2} MB)" -f $size, ($size / 1MB)) -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
