@echo off
call "%~dp0adb_config.bat"

echo Pairing with %DEVICE_IP%:%PAIR_PORT%...
adb.exe pair %DEVICE_IP%:%PAIR_PORT%

if %ERRORLEVEL% EQU 0 (
    echo Paired successfully!
) else (
    echo Pairing failed!
)
