@echo off
call "%~dp0adb_config.bat"

REM Create log directory if not exists
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

REM Simple timestamp
set LOGFILE=%LOG_DIR%\log_test.txt

echo ============================================
echo ADB Logcat Logging
echo ============================================
echo.
echo Device: %DEVICE_IP%:%DEVICE_PORT%
echo Log file: %LOGFILE%
echo.
echo Starting logcat...
echo Press Ctrl+C to stop
echo ============================================
echo.

adb -s %DEVICE_IP%:%DEVICE_PORT% logcat -v time > %LOGFILE%
