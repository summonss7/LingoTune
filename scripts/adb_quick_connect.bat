@echo off
call "%~dp0adb_config.bat"

echo ============================================
echo Quick Connect (Pair + Connect)
echo ============================================
echo.
echo Step 1: Pairing with %DEVICE_IP%:%PAIR_PORT%...
adb.exe pair %DEVICE_IP%:%PAIR_PORT%

if %ERRORLEVEL% NEQ 0 (
    echo Pairing failed! Please make sure:
    echo - Device is on the same network
    echo - Wireless debugging is enabled
    echo - Pairing code is correctly entered
    echo.
    pause
    exit /b 1
)

echo.
echo Step 2: Connecting to %DEVICE_IP%:%DEVICE_PORT%...
adb.exe connect %DEVICE_IP%:%DEVICE_PORT%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Success! Device is connected.
    echo You can now start logging or other ADB operations.
) else (
    echo.
    echo Connection failed! Please check the IP and port in adb_config.bat
)

echo.
pause
