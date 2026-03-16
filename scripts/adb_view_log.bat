@echo off
call "%~dp0adb_config.bat"

REM Check if log directory exists
if not exist "%LOG_DIR%" (
    echo No log files found!
    pause
    exit /b
)

REM List recent log files
echo ============================================
echo Select log file to monitor:
echo ============================================
echo.

dir /b /o-d "%LOG_DIR%\*.txt" > temp_logs.txt

set /a count=0
for /f "delims=" %%f in (temp_logs.txt) do (
    set /a count+=1
    set logfile!count!=%%f
    echo !count!. %%f
)

if %count% EQU 0 (
    echo No log files found!
    del temp_logs.txt
    pause
    exit /b
)

echo 0. Exit
echo.
set /p choice="Enter your choice (0-%count%): "

if "%choice%"=="0" (
    del temp_logs.txt
    exit /b
)

if %choice% GTR %count% (
    echo Invalid choice!
    del temp_logs.txt
    pause
    exit /b
)

call set logfilename=%%logfile%choice%%%
del temp_logs.txt

echo.
echo Monitoring: %LOG_DIR%\%logfilename%
echo Press Ctrl+C to stop
echo ============================================
echo.

REM Monitor with error highlighting
type "%LOG_DIR%\%logfilename%" | findstr /n /i "E\/ FATAL W\/ D\/ I\/ V\/" | findstr /i "E\/ FATAL W\/" > temp_errors.txt 2>nul

if exist temp_errors.txt (
    echo Errors and Warnings found:
    echo ----------------------------------------
    type temp_errors.txt
    echo ----------------------------------------
    echo.
    del temp_errors.txt
)

echo Showing full log:
type "%LOG_DIR%\%logfilename%"

pause
