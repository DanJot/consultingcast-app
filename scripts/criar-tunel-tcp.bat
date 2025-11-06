@echo off
cd /d "%~dp0\..\cloudflared"
echo.
echo ========================================
echo   🌐 Criar Túnel Cloudflare TCP
echo ========================================
echo.
echo IMPORTANTE: O proxy TCP deve estar a correr primeiro!
echo.
echo Criando túnel para: tcp://localhost:3307
echo.
echo Aguarde... A URL do túnel aparecerá abaixo:
echo.
.\cloudflared.exe tunnel --url tcp://localhost:3307

