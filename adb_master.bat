@echo off
call "%~dp0scripts\adb_config.bat"

:menu
cls
echo ============================================
echo ADB Master Control
echo ============================================
echo.
echo Current Configuration:
echo   Device IP: %DEVICE_IP%
echo   Connect Port: %DEVICE_PORT%
echo   Pair Port: %PAIR_PORT%
echo   Log Directory: %LOG_DIR%
echo.
echo ============================================
echo Available Actions:
echo 1. Quick connect (Pair + Connect)
echo 2. Pair device
echo 3. Connect to device
echo 4. Start logcat logging
echo 5. Check device status
echo 6. Disconnect device
echo 7. Edit configuration
echo 8. List recent log files
echo 9. View log file (with error highlighting)
echo 0. Clean old log files
echo F. Find device on network
echo X. Exit
echo ============================================
echo.
set /p choice="Enter your choice (0-9, F, X): "

if "%choice%"=="1" (
    echo.
    call "%~dp0scripts\adb_quick_connect.bat"
    goto menu
)

if "%choice%"=="2" (
    echo.
    call "%~dp0scripts\adb_pair.bat"
    echo.
    pause
    goto menu
)

if "%choice%"=="3" (
    echo.
    call "%~dp0scripts\adb_connect.bat"
    echo.
    pause
    goto menu
)

if "%choice%"=="4" (
    echo.
    call "%~dp0scripts\adb_logcat.bat"
    echo.
    pause
    goto menu
)

if "%choice%"=="5" (
    echo.
    echo Checking device status...
    adb -s %DEVICE_IP%:%DEVICE_PORT% devices -l
    echo.
    pause
    goto menu
)

if "%choice%"=="6" (
    echo.
    echo Disconnecting from %DEVICE_IP%:%DEVICE_PORT%...
    adb -s %DEVICE_IP%:%DEVICE_PORT% disconnect
    echo Disconnected!
    echo.
    pause
    goto menu
)

if "%choice%"=="7" (
    echo.
    echo Opening configuration file...
    notepad "%~dp0scripts\adb_config.bat"
    echo Please reload this script after editing.
    echo.
    pause
    goto menu
)

if "%choice%"=="8" (
    echo.
    echo Recent log files in %LOG_DIR%:
    if exist "%LOG_DIR%" (
        dir /b /o-d "%LOG_DIR%\*.txt" | more
    ) else (
        echo Log directory does not exist yet.
    )
    echo.
    pause
    goto menu
)

if "%choice%"=="9" (
    echo.
    call "%~dp0scripts\adb_view_log.bat"
    goto menu
)

if "%choice%"=="0" (
    echo.
    call "%~dp0scripts\adb_clean_logs.bat"
    goto menu
)

if /i "%choice%"=="F" (
    echo.
    call "%~dp0scripts\adb_find_device.bat"
    goto menu
)

if /i "%choice%"=="X" (
    echo Exiting...
    exit /b
)

echo Invalid choice! Please try again.
echo.
pause
goto menu
