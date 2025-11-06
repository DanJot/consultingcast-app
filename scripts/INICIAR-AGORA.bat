@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   🚀 INICIAR TUDO - SCRIPT PRINCIPAL
echo ========================================
echo.
echo Este é o script que deves usar sempre!
echo.
echo Funciona assim:
echo   1. Primeira vez: Guarda a URL que colares
echo   2. Próximas vezes: Usa a URL guardada
echo.
pause

cd /d "%~dp0"
call INICIAR-TUDO.bat

