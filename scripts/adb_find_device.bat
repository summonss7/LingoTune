@echo off
echo ============================================
echo ADB Network Device Scanner
echo ============================================
echo.
echo Scanning network for potential ADB devices...
echo Note: This checks common port ranges used by wireless debugging
echo.

REM Check common ADB port ranges (usually 5555 for standard, 37xxx-41xxx for wireless debugging)
echo Scanning port range 37000-42000 on your local network...
echo.

REM Get local IP range
ipconfig | findstr /i "IPv4" > temp_ip.txt
for /f "tokens=2 delims=:" %%a in (temp_ip.txt) do (
    for /f "tokens=1,2,3 delims=." %%i in ("%%a") do (
        set IP_PREFIX=%%i.%%j.%%k
    )
)
del temp_ip.txt

if defined IP_PREFIX (
    echo Local IP range: %IP_PREFIX%.x
    echo.
    echo Scanning for devices (this may take a while)...
    echo Press Ctrl+C to cancel
    echo.

    REM Scan for open ports that might be ADB
    set FOUND_DEVICES=0

    for /l %%i in (1,1,254) do (
        for %%p in (5555 37000 37100 37200 37300 37400 37500 37600 37700 37800 37900 38000 38100 38200 38300 38400 38500 38600 38700 38800 38900 39000 39100 39200 39300 39400 39500 39600 39700 39800 39900 40000 40100 40200 40300 40400 40500 40600 40700 40800 40900 41000 41100 41200 41300 41400 41500 41600 41700 41800 41900 42000) do (
            (echo > NUL 2>&1) | PowerShell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('%IP_PREFIX%.%%i', %%p); $tcp.Close(); Write-Host 'Found: %IP_PREFIX%.%%i:%%p' } catch { }"
        )
    )

    echo.
    echo Scan complete!
    echo.
    echo If you found any devices above, update adb_config.bat with:
    echo DEVICE_IP=[found IP]
    echo DEVICE_PORT=[found port]
) else (
    echo Could not determine local IP range.
    echo Please manually check your device for its IP address.
)

echo.
pause
