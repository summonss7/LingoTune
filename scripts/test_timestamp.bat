@echo off
setlocal enabledelayedexpansion

REM Generate timestamp for Windows
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
echo datetime: %datetime%
echo datetime length: 
set TIMESTAMP=!datetime:~0,4!-!datetime:~4,2!-!datetime:~6,2!_!datetime:~8,2!-!datetime:~10,2!-!datetime:~12,2!
echo TIMESTAMP: !TIMESTAMP!
echo.

REM Test file with this timestamp
powershell -Command "Set-Content -Path 'debug\log_!TIMESTAMP!.txt' -Value 'test'"

if exist "debug\log_!TIMESTAMP!.txt" (
    echo File created successfully!
    dir "debug\log_!TIMESTAMP!.txt"
) else (
    echo File NOT created!
)

pause
