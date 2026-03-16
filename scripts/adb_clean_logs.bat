@echo off
call "%~dp0adb_config.bat"

REM Check if log directory exists
if not exist "%LOG_DIR%" (
    echo No log files found!
    pause
    exit /b
)

echo ============================================
echo Clean Old Log Files
echo ============================================
echo.
echo Current log files in: %LOG_DIR%
echo.

dir /b "%LOG_DIR%\*.txt" 2>nul | find /c /v "" > temp_count.txt
set /p count=<temp_count.txt
del temp_count.txt

if %count% EQU 0 (
    echo No log files to clean.
    pause
    exit /b
)

echo Total log files: %count%
echo.

set /p days="Delete logs older than how many days? (default: 7): "
if "%days%"=="" set days=7

echo.
echo Deleting log files older than %days% days...
echo.

forfiles /p "%LOG_DIR%" /m *.txt /d -%days% /c "cmd /c echo Deleting: @file & del @file" 2>nul

if %ERRORLEVEL% EQU 0 (
    echo Cleanup complete!
) else (
    echo No files were deleted (or an error occurred).
)

echo.
pause
