# LingoTune v5.7.4 Build Script
# Run this script to build the release APK.
#
# Версия и versionCode читаются из app/pubspec.yaml и app/android/app/build.gradle
# (центральный источник правды — больше не нужно править скрипт при релизе).
# Пути вычисляются относительно расположения скрипта ($PSScriptRoot) — скрипт
# переносим между машинами. Flutter определяется через PATH, с fallback на
# C:\flutter\bin\flutter.bat (как в прежних скриптах).

$ErrorActionPreference = "Stop"

# --- Корень проекта: каталог, где лежит этот скрипт ---
$projectRoot = $PSScriptRoot
$appDir      = Join-Path $projectRoot "app"
$buildsDir   = Join-Path $projectRoot "builds"

if (-not (Test-Path $appDir)) {
    throw "app/ не найден в $projectRoot — скрипт должен лежать в корне проекта."
}

# --- Версия из pubspec.yaml (строка "version: x.y.z") ---
$pubspec = Join-Path $appDir "pubspec.yaml"
$versionLine = Get-Content $pubspec | Where-Object { $_ -match '^\s*version:\s*' } | Select-Object -First 1
if ($versionLine -notmatch 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)') {
    throw "Не удалось прочитать версию из $pubspec"
}
$appVersion = $Matches[1]

# --- versionCode из app/android/app/build.gradle (строка "versionCode NNN") ---
$gradle = Join-Path $appDir "android\app\build.gradle"
$codeLine = Get-Content $gradle | Where-Object { $_ -match '^\s*versionCode\s+' } | Select-Object -First 1
if ($codeLine -notmatch 'versionCode\s+(\d+)') {
    throw "Не удалось прочитать versionCode из $gradle"
}
$versionCode = $Matches[1]

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Building LingoTune-v$appVersion (code $versionCode)" -ForegroundColor Cyan
Write-Host "  project root: $projectRoot" -ForegroundColor DarkGray
Write-Host "====================================" -ForegroundColor Cyan

# --- Определение flutter: сначала PATH, затем fallback на C:\flutter ---
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCmd) {
    $flutter = $flutterCmd.Source
} elseif (Test-Path "C:\flutter\bin\flutter.bat") {
    $flutter = "C:\flutter\bin\flutter.bat"
} else {
    throw "flutter не найден ни в PATH, ни в C:\flutter\bin\. Установите Flutter или поправьте скрипт."
}
Write-Host "Using flutter: $flutter" -ForegroundColor DarkGray

Set-Location $appDir

Write-Host ""
Write-Host "Step 1: Clean..." -ForegroundColor Yellow
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
$dstApk = Join-Path $buildsDir "LingoTune-v$appVersion.apk"
Copy-Item -Path $srcApk -Destination $dstApk -Force

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
Write-Host "APK: $dstApk" -ForegroundColor Green
$size = (Get-Item $dstApk).Length
Write-Host ("Size: {0:N0} bytes ({1:N2} MB)" -f $size, ($size / 1MB)) -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
