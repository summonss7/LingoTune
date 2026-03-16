@echo off
call "%~dp0adb_config.bat"

echo Connecting to %DEVICE_IP%:%DEVICE_PORT%...
adb.exe connect %DEVICE_IP%:%DEVICE_PORT%

if %ERRORLEVEL% EQU 0 (
    echo Connected successfully!
) else (
    echo Connection failed!
)
