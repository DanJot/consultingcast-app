@echo off
cd /d "%~dp0"
echo ========================================
echo   CLOUDFLARE TUNNEL - CONFIGURACAO
echo ========================================
echo.
echo 1. Vai abrir browser para autenticar Cloudflare
echo 2. Faz login na Cloudflare
echo 3. Autoriza a aplicacao
echo.
pause
.\cloudflared.exe login
echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ Cloudflare autenticado!
    echo.
    echo Proximo passo: Executa criar-tunel.bat
) else (
    echo ❌ Erro na autenticacao
)
echo.
pause

