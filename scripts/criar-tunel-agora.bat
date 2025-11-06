@echo off
chcp 65001 >nul
echo.
echo ========================================
echo   🌐 CRIAR TÚNEL CLOUDFLARE
echo ========================================
echo.
echo ✅ API confirmada a funcionar em http://localhost:3000
echo.
echo Criando túnel público...
echo.
echo ⚠️  IMPORTANTE: 
echo    - Aguarda 5-10 segundos
echo    - Quando aparecer a URL (ex: https://xxxxx.trycloudflare.com)
echo    - COPIA essa URL!
echo.
echo ========================================
echo.
timeout /t 2 /nobreak >nul

cd /d "%~dp0\..\cloudflared"
if not exist "cloudflared.exe" (
    echo ❌ ERRO: cloudflared.exe não encontrado em:
    echo %~dp0\..\cloudflared
    echo.
    echo Verifica se o ficheiro existe!
    pause
    exit /b 1
)

.\cloudflared.exe tunnel --url http://localhost:3000
