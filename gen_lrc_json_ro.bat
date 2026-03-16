@echo off
echo ====================================
echo DeepSeek Lyrics Generator v3
echo ====================================
echo.

echo Parameters:
if "%~1"=="" (
rem    echo Languages: de,en,ru,ru_literal,trans ^(default^)
    echo Languages: en,ru,ru_literal,trans ^(default^)
) else (
    echo Languages: %~1
)
if "%~2"=="" (
    echo Start minute: 30 ^(default^)
) else (
    echo Start minute: %~2
)
if "%~3"=="" (
    echo Transcription language: ru ^(default^)
) else (
    echo Transcription language: %~3
)
echo.
echo ====================================
echo.

python scripts\deepseek_generator_v3.py %~1 %~2 %~3

echo.
pause
