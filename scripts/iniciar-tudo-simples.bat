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
echo ⚠️  IMPORTANTE: Mantém TODAS as janelas abertas!
echo.
pause

REM Limpar processos antigos
echo.
echo [1/4] Limpando processos antigos...
taskkill /F /IM node.exe /T >nul 2>&1
taskkill /F /IM cloudflared.exe /T >nul 2>&1
taskkill /F /IM dart.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul

REM Iniciar API em nova janela
echo [2/4] Iniciando API Node.js...
start "API Node.js" cmd /c "cd /d %~dp0\..\api-server && echo API Node.js iniciada em http://localhost:3000 && echo. && node server.js"
timeout /t 5 /nobreak >nul

REM Iniciar Tunnel em nova janela
echo [3/4] Iniciando Cloudflare Tunnel...
start "Cloudflare Tunnel" cmd /c "cd /d %~dp0\..\cloudflared && echo Criando túnel Cloudflare... && echo. && .\cloudflared.exe tunnel --url http://localhost:3000"
timeout /t 8 /nobreak >nul

REM Aguardar um pouco para o túnel gerar URL
echo Aguardando túnel gerar URL...
timeout /t 5 /nobreak >nul

REM Executar Flutter
echo.
echo [4/4] Executando Flutter Web...
echo O Chrome vai abrir automaticamente quando compilar!
echo.
echo ⚠️  IMPORTANTE: 
echo    - Verifica a janela do túnel e copia a URL (ex: https://xxxxx.trycloudflare.com)
echo    - Se a URL mudar, reinicia o Flutter com a nova URL
echo.
cd /d "%~dp0\..\app2\app2"
flutter run -d chrome --dart-define=API_BASE=https://katie-learn-forum-nuke.trycloudflare.com

