@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   ⚠️  AVISO IMPORTANTE
echo ========================================
echo.
echo Este script (INICIAR-TUDO-AUTO.bat) tem problemas.
echo.
echo Por favor, usa este script em vez disso:
echo.
echo   INICIAR-TUDO.bat
echo.
echo Ele é mais simples e funciona melhor!
echo.
echo Pressiona qualquer tecla para abrir o script correto...
pause >nul

cd /d "%~dp0"
call INICIAR-TUDO.bat
