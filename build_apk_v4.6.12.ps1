# LingoTune v4.6.12 Build Script
# Run this script to build the APK

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Building LingoTune-v4.6.12 APK" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Change to app directory
Set-Location "D:\Ai-Projects\LingoTune\app"

Write-Host ""
Write-Host "Step 1: Clean..." -ForegroundColor Yellow
& "C:\flutter\bin\flutter.bat" clean

Write-Host ""
Write-Host "Step 2: Get dependencies..." -ForegroundColor Yellow
& "C:\flutter\bin\flutter.bat" pub get

Write-Host ""
Write-Host "Step 3: Generate localizations..." -ForegroundColor Yellow
& "C:\flutter\bin\flutter.bat" gen-l10n

Write-Host ""
Write-Host "Step 4: Build APK..." -ForegroundColor Yellow
& "C:\flutter\bin\flutter.bat" build apk --release

Write-Host ""
Write-Host "Step 5: Copy to builds folder..." -ForegroundColor Yellow
if (-not (Test-Path "..\builds")) {
    New-Item -ItemType Directory -Path "..\builds" | Out-Null
}
Copy-Item -Path "build\app\outputs\flutter-apk\app-release.apk" -Destination "..\builds\LingoTune-v4.6.12.apk" -Force

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "APK: D:\Ai-Projects\LingoTune\builds\LingoTune-v4.6.12.apk" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")