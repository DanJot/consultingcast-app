@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo   🌐 TESTAR TÚNEL - VER URL
echo ========================================
echo.
echo Este script vai criar o túnel e mostrar a URL
echo.
echo ⚠️  IMPORTANTE: A API deve estar a correr primeiro!
echo.
pause

cd /d "%~dp0\..\cloudflared"

REM Verificar se API está a responder
echo Verificando se API está a responder...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:3000/health' -Method GET -TimeoutSec 2 -UseBasicParsing; Write-Host '✅ API está a responder!' } catch { Write-Host '❌ ERRO: API não está a responder! Inicia a API primeiro.'; pause; exit 1 }"

if errorlevel 1 (
    echo.
    echo A API não está a responder. Inicia primeiro: iniciar-api.bat
    pause
    exit /b 1
)

echo.
echo Criando túnel...
echo.
echo ========================================
echo   AGUARDA 10-15 SEGUNDOS
echo   A URL aparecerá abaixo
echo ========================================
echo.

.\cloudflared.exe tunnel --url http://localhost:3000

pause

