@echo off
cd /d "%~dp0"
echo.
echo ========================================
echo   🌐 Quick Tunnel TCP Cloudflare
echo ========================================
echo.
echo Criando túnel TCP para: tcp://localhost:3307
echo.
echo IMPORTANTE: Este é um Quick Tunnel TEMPORÁRIO
echo - A URL muda cada vez que reinicias
echo - Funciona enquanto o processo estiver a correr
echo.
echo Aguarde... A URL aparecerá abaixo:
echo ========================================
echo.
.\cloudflared.exe tunnel --url tcp://localhost:3307
pause

