@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo.
echo ========================================
echo   🎨 Iniciar Flutter Web com Túnel
echo ========================================
echo.
echo Cole a URL do Cloudflare Tunnel abaixo
echo (ex: https://xxxxx.trycloudflare.com)
echo.
set /p TUNEL_URL="URL do túnel: "

if "!TUNEL_URL!"=="" (
    echo.
    echo ❌ ERRO: Não inseriste a URL!
    pause
    exit /b 1
)

REM Limpar caracteres especiais
set TUNEL_URL=!TUNEL_URL:"=!
set TUNEL_URL=!TUNEL_URL: =!
set TUNEL_URL=!TUNEL_URL:'=!

echo.
echo ✅ Usando URL: !TUNEL_URL!
echo.
echo Compilando Flutter Web...
echo ⚠️  A primeira compilação pode demorar 3-5 minutos
echo.

cd /d "%~dp0\..\app2\app2"
flutter run -d chrome --dart-define=API_BASE=!TUNEL_URL! --web-port=8080 --web-hostname=localhost

pause
