@echo off
call "%~dp0adb_config.bat"

REM Create log directory if not exists
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Generate timestamp using PowerShell (more reliable across locales)
for /f "delims=" %%i in ('powershell -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set TIMESTAMP=%%i

set LOGFILE=%LOG_DIR%\log_%TIMESTAMP%.txt

echo ============================================
echo ADB Logcat Logging Options
echo ============================================
echo.
echo Device: %DEVICE_IP%:%DEVICE_PORT%
echo Log directory: %LOG_DIR%
echo Log file: %LOGFILE%
echo.
echo Select logging type:
echo 1. Full log (verbose)
echo 2. Errors only
echo 3. Warnings and Errors
echo 4. Debug messages
echo 5. Custom filter
echo 6. Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    set FILTER=*
    echo Starting full logcat...
) else if "%choice%"=="2" (
    set FILTER=*:E
    echo Starting errors only logcat...
) else if "%choice%"=="3" (
    set FILTER=*:W *:E
    echo Starting warnings and errors logcat...
) else if "%choice%"=="4" (
    set FILTER=*:D *:W *:E
    echo Starting debug logcat...
) else if "%choice%"=="5" (
    echo.
    set /p FILTER="Enter custom filter (e.g., 'MyTag:D *:E'): "
    echo Starting custom filter logcat...
) else if "%choice%"=="6" (
    echo Exiting...
    exit /b
) else (
    echo Invalid choice!
    exit /b 1
)

echo.
echo Writing to: %LOGFILE%
echo Press Ctrl+C to stop logging
echo ============================================
echo.

REM Check if file already exists and delete it
if exist "%LOGFILE%" (
    echo Deleting existing log file...
    del "%LOGFILE%"
)

REM Create empty file first
echo. > "%LOGFILE%"

if not exist "%LOGFILE%" (
    echo ERROR: Could not create log file!
    echo Path: %LOGFILE%
    pause
    exit /b 1
)

echo Log file created successfully.
echo Starting adb logcat...
echo.

adb -s %DEVICE_IP%:%DEVICE_PORT% logcat -v time %FILTER% >> %LOGFILE%

echo.
echo Logging stopped.
