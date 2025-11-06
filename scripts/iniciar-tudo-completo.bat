@echo off
echo.
echo ========================================
echo   🚀 INICIAR TUDO - API + Túnel + Flutter
echo ========================================
echo.
echo Isto vai iniciar:
echo   1. API Node.js (porta 3000)
echo   2. Cloudflare Tunnel (expor API)
echo   3. Flutter Web (abre Chrome automaticamente)
echo.
echo Mantém esta janela aberta!
echo.
pause

REM Iniciar API em nova janela
start "API Node.js" cmd /c "cd /d %~dp0\..\api-server && node server.js"
timeout /t 3 /nobreak >nul

REM Iniciar Tunnel em nova janela
start "Cloudflare Tunnel" cmd /c "cd /d %~dp0\..\cloudflared && .\cloudflared.exe tunnel --url http://localhost:3000"
timeout /t 5 /nobreak >nul

REM Aguardar um pouco para o túnel gerar URL
echo Aguardando túnel gerar URL...
timeout /t 8 /nobreak >nul

REM Executar Flutter (vai abrir Chrome automaticamente)
echo.
echo ========================================
echo   Executando Flutter Web...
echo   O Chrome vai abrir automaticamente!
echo ========================================
echo.
cd /d "%~dp0\..\app2\app2"
flutter run -d chrome --dart-define=API_BASE=https://katie-learn-forum-nuke.trycloudflare.com

