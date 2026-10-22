# LingoTune Release Publish Script (карточка lingotune-006)
# Публикация релиза ОДНОЙ командой в оба канала обновлений:
#   1) Центр обновлений Aila (основной) — node D:\Scheduler\tools\publish-update.cjs
#      lingotune: манифест v2 с sha256, история релизов, «📦 Обновление …» в «Хабе ИИ».
#   2) GitHub Releases (резерв) — REST API: тег v<версия> + APK-asset.
#
# Использование (из корня проекта):
#   powershell -NoProfile -ExecutionPolicy Bypass -File publish_release.ps1
#   powershell ... -File publish_release.ps1 -Version 5.11.0 -Notes "Что нового"
#   powershell ... -File publish_release.ps1 -SkipGitHub     # только Aila
#   powershell ... -File publish_release.ps1 -DryRun         # показать план
#
# Параметры:
#   -Version  версия релиза (по умолчанию — из app/pubspec.yaml)
#   -Code     versionCode (по умолчанию — из app/android/app/build.gradle;
#             клиенты Android сверяют обновления именно по нему)
#   -Notes    «что нового» (по умолчанию — последняя запись «## …» из
#             CHANGELOG.md, см. --notes-file у publish-update.cjs)
#   -Apk      точный путь к APK (по умолчанию — builds\LingoTune-v<версия>.apk)
#   -SkipAila / -SkipGitHub   пропустить канал
#   -DryRun   показать план, ничего не отправлять
#
# Токен GitHub (для резервного канала): переменная окружения GITHUB_TOKEN или
# файл .github_release_token в корне проекта (в .gitignore!) — PAT с правом
# contents:write репозитория summonss7/LingoTune. Токена нет — GitHub-канал
# пропускается с предупреждением, релиз всё равно считается опубликованным
# (Aila — источник правды, GitHub — резерв; UPDATES-SYSTEM.md §3).
#
# Выход: 0 — основной канал опубликован; 1 — ошибка основного канала.
# Идемпотентность: повторный запуск обновляет манифест Aila и перезаливает
# asset GitHub-релиза того же тега (старый asset удаляется).

param(
    [string]$Version = "",
    [string]$Code = "",
    [string]$Notes = "",
    [string]$Apk = "",
    [switch]$SkipAila,
    [switch]$SkipGitHub,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot
$appDir      = Join-Path $projectRoot "app"
$buildsDir   = Join-Path $projectRoot "builds"
$repo        = "summonss7/LingoTune"
$publishTool = "D:\Scheduler\tools\publish-update.cjs"

# --- Версия из pubspec.yaml ---
if (-not $Version) {
    $pubspec = Join-Path $appDir "pubspec.yaml"
    $versionLine = Get-Content $pubspec | Where-Object { $_ -match '^\s*version:\s*' } | Select-Object -First 1
    if ($versionLine -notmatch 'version:\s*([0-9]+\.[0-9]+\.[0-9]+)') {
        throw "Не удалось прочитать версию из $pubspec — укажите -Version."
    }
    $Version = $Matches[1]
}

# --- versionCode из build.gradle ---
if (-not $Code) {
    $gradle = Join-Path $appDir "android\app\build.gradle"
    $codeLine = Get-Content $gradle | Where-Object { $_ -match '^\s*versionCode\s+' } | Select-Object -First 1
    if ($codeLine -notmatch 'versionCode\s+(\d+)') {
        throw "Не удалось прочитать versionCode из $gradle — укажите -Code."
    }
    $Code = $Matches[1]
}

# --- APK из builds/ ---
if (-not $Apk) {
    $Apk = Join-Path $buildsDir "LingoTune-v$Version.apk"
}
if (-not (Test-Path $Apk)) {
    throw "APK не найден: $Apk — соберите сначала (build_apk_v5.7.4.ps1) или укажите -Apk."
}

$apkSize = (Get-Item $Apk).Length

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Publish LingoTune v$Version (code $Code)" -ForegroundColor Cyan
Write-Host "  APK: $Apk ($([math]::Round($apkSize / 1MB, 1)) MB)" -ForegroundColor DarkGray
Write-Host "====================================" -ForegroundColor Cyan

$ailaOk = $SkipAila
$githubOk = $SkipGitHub

# ============================ Канал 1: Aila ============================
if (-not $SkipAila) {
    if (-not (Test-Path $publishTool)) {
        Write-Host "[!] publish-update.cjs не найден ($publishTool) — канал Aila пропущен." -ForegroundColor Yellow
    } else {
        $node = Get-Command node -ErrorAction SilentlyContinue
        if (-not $node) {
            Write-Host "[!] node не найден в PATH — канал Aila пропущен." -ForegroundColor Yellow
        } else {
            Write-Host ""
            Write-Host "Channel 1: Aila update center (primary)" -ForegroundColor Yellow
            $cliArgs = @($publishTool, "lingotune", "--version", $Version, "--code", $Code)
            if ($Notes) {
                $cliArgs += @("--notes", $Notes)
            } else {
                # «Что нового» — последняя запись CHANGELOG.md (дописывается в конец)
                $cliArgs += @("--notes-file", (Join-Path $projectRoot "CHANGELOG.md"))
            }
            if ($DryRun) { $cliArgs += "--dry-run" }
            & node $cliArgs
            if ($LASTEXITCODE -eq 0) { $ailaOk = $true } else {
                Write-Host "[✗] Канал Aila завершился с кодом $LASTEXITCODE" -ForegroundColor Red
            }
        }
    }
}

# ========================== Канал 2: GitHub ============================
if (-not $SkipGitHub) {
    $token = $env:GITHUB_TOKEN
    $tokenFile = Join-Path $projectRoot ".github_release_token"
    if (-not $token -and (Test-Path $tokenFile)) { $token = (Get-Content $tokenFile -Raw).Trim() }
    if (-not $token) {
        Write-Host ""
        Write-Host "[!] Токен GitHub не задан (GITHUB_TOKEN или $tokenFile) —" -ForegroundColor Yellow
        Write-Host "    резервный канал пропущен. Aila — источник правды, релиз опубликован." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "Channel 2: GitHub Releases (backup)" -ForegroundColor Yellow
        try {
            # PS 5.1: TLS 1.2 для api.github.com
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            $apiHeaders = @{
                "Authorization" = "token $token"
                "Accept"        = "application/vnd.github+json"
                "User-Agent"    = "LingoTune-publish-script"
            }

            # «Что нового» для GitHub-релиза — те же notes (или CHANGELOG)
            $releaseBody = $Notes
            if (-not $releaseBody) {
                $cl = Get-Content (Join-Path $projectRoot "CHANGELOG.md") -Raw -Encoding UTF8
                $at = $cl.LastIndexOf("`n## ")
                if ($at -ge 0) { $releaseBody = $cl.Substring($at + 1).Trim() } else { $releaseBody = "" }
            }

            if ($DryRun) {
                Write-Host "  dry-run: создал бы релиз v$Version + asset $(Split-Path $Apk -Leaf)" -ForegroundColor DarkGray
                $githubOk = $true
            } else {
                # 1) Найти существующий релиз тега (републикация) или создать новый
                $tag = "v$Version"
                $release = $null
                try {
                    $release = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$repo/releases/tags/$tag" -Headers $apiHeaders
                    Write-Host "  релиз $tag уже существует — перезаливаю asset" -ForegroundColor DarkGray
                } catch { $release = $null }

                if (-not $release) {
                    $payload = @{
                        tag_name         = $tag
                        target_commitish = "main"
                        name             = "LingoTune v$Version"
                        body             = $releaseBody
                    } | ConvertTo-Json
                    $payloadBytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
                    $release = Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$repo/releases" `
                        -Headers $apiHeaders -ContentType "application/json; charset=utf-8" -Body $payloadBytes
                    Write-Host "  ✓ релиз создан: $($release.html_url)" -ForegroundColor Green
                }

                # 2) Удалить asset с тем же именем (перезаливка), затем загрузить APK
                $assetName = Split-Path $Apk -Leaf
                foreach ($asset in @($release.assets)) {
                    if ($asset.name -eq $assetName) {
                        Invoke-RestMethod -Method Delete -Uri $asset.url -Headers $apiHeaders | Out-Null
                        Write-Host "  старый asset удалён" -ForegroundColor DarkGray
                    }
                }
                $uploadUri = "https://uploads.github.com/repos/$repo/releases/$($release.id)/assets?name=$assetName"
                $null = Invoke-RestMethod -Method Post -Uri $uploadUri -Headers $apiHeaders `
                    -ContentType "application/vnd.android.package-archive" -InFile $Apk
                Write-Host "  ✓ asset загружен: $assetName ($([math]::Round($apkSize / 1MB, 1)) MB)" -ForegroundColor Green
                $githubOk = $true
            }
        } catch {
            Write-Host "[!] GitHub-релиз не создан: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "    Aila — источник правды; доделайте релиз вручную при необходимости." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
if ($ailaOk)   { Write-Host "Aila:    OK" -ForegroundColor Green }   else { Write-Host "Aila:    FAILED/SKIPPED" -ForegroundColor Red }
if ($githubOk) { Write-Host "GitHub:  OK" -ForegroundColor Green }   else { Write-Host "GitHub:  FAILED/SKIPPED" -ForegroundColor Yellow }
Write-Host "====================================" -ForegroundColor Cyan

# Основной канал обязателен, резерв — по возможности.
if (-not $ailaOk) { exit 1 }
exit 0
