@echo off
chcp 65001 >nul
cd /d "%~dp0\..\cloudflared"
echo.
echo ========================================
echo   🌐 Cloudflare Quick Tunnel HTTP
echo ========================================
echo.
echo ⚠️  IMPORTANTE: A API deve estar a correr em localhost:3000 primeiro!
echo.
echo Criando túnel HTTP para: http://localhost:3000
echo.
echo Aguarde 5-10 segundos... A URL aparecerá abaixo:
echo ========================================
echo.
.\cloudflared.exe tunnel --url http://localhost:3000
pause
