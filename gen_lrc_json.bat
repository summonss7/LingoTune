@echo off
echo ====================================
echo DeepSeek Lyrics Generator v3
echo ====================================
echo.
echo Usage: gen_lrc_json [languages] [start_minute] [transcription_lang]
echo   Example: gen_lrc_json en,ru,ru_literal,trans 30 ru
echo   Example: gen_lrc_json ro,ru,ru_literal,trans
echo.

python scripts\deepseek_generator_v3.py %1 %2 %3

echo.
pause
