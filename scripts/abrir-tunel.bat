@echo off
setlocal enabledelayedexpansion
echo.
echo ========================================
echo   INICIAR TUNEL MANUALMENTE
echo ========================================
echo.
echo Isto vai abrir a janela do Cloudflare Tunnel.
echo Copia a URL que aparecer e usa no Flutter!
echo.
pause

cd /d "%~dp0\..\cloudflared"
echo.
echo ========================================
echo   Cloudflare Tunnel
echo ========================================
echo.
echo Criando tunel para: http://localhost:3000
echo.
echo IMPORTANTE: Copia a URL que aparecer abaixo!
echo.
.\cloudflared.exe tunnel --url http://localhost:3000

