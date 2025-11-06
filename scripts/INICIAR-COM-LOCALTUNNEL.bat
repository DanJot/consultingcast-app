@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
cls
echo.
echo ========================================
echo   🚀 INICIAR TUDO - COM LOCALTUNNEL
echo ========================================
echo.
echo Usando localtunnel (sempre mostra a URL!)
echo.
pause

REM Limpar processos antigos
echo.
echo [1/5] 🧹 Limpando processos antigos...
taskkill /F /IM node.exe /T >nul 2>&1
taskkill /F /IM cloudflared.exe /T >nul 2>&1
taskkill /F /IM dart.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul
echo ✅ Processos limpos
echo.

REM Verificar se localtunnel está instalado
echo [2/5] 🔍 Verificando localtunnel...
cd /d "%~dp0\..\api-server"
where npx >nul 2>&1
if errorlevel 1 (
    echo ❌ npm/npx não encontrado!
    echo.
    echo Instala Node.js primeiro: https://nodejs.org
    pause
    exit /b 1
)
echo ✅ npm/npx encontrado
echo.

REM Iniciar API
echo [3/5] 🚀 Iniciando API Node.js...
start "API Node.js" cmd /k "cd /d %~dp0\..\api-server && echo ======================================== && echo   API Node.js && echo ======================================== && echo. && echo API: http://localhost:3000 && echo MySQL: 10.1.55.10:3306 && echo. && echo ⚠️  Mantém esta janela aberta! && echo. && node server.js"
timeout /t 5 /nobreak >nul

REM Verificar API
echo [4/5] 🔍 Verificando API...
set API_OK=0
for /L %%i in (1,1,10) do (
    powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:3000/health' -Method GET -TimeoutSec 2 -UseBasicParsing; exit 0 } catch { exit 1 }" >nul 2>&1
    if not errorlevel 1 (
        set API_OK=1
        goto :api_ok
    )
    timeout /t 1 /nobreak >nul
)

:api_ok
if !API_OK!==0 (
    echo ❌ API não está a responder
    pause
    exit /b 1
)
echo ✅ API OK!
echo.

REM Criar túnel com localtunnel
echo [5/5] 🌐 Criando túnel com localtunnel...
echo.
echo ⚠️  IMPORTANTE: localtunnel SEMPRE mostra a URL!
echo    Aguarda aparecer uma linha com "your url is: https://..."
echo.
cd /d "%~dp0\..\api-server"

REM Criar túnel numa janela separada
start "Localtunnel" cmd /k "cd /d %~dp0\..\api-server && echo ======================================== && echo   Localtunnel && echo ======================================== && echo. && echo Criando túnel para: http://localhost:3000 && echo. && echo ⚠️  Aguarda aparecer a URL abaixo! && echo    Procura por: 'your url is: https://...' && echo. && echo ======================================== && echo. && npx localtunnel --port 3000"

timeout /t 15 /nobreak >nul

echo.
echo ========================================
echo   📋 COPIAR URL DO TÚNEL
echo ========================================
echo.
echo 1. Vai para a janela do Localtunnel (acima)
echo 2. Procura por uma linha que diz: "your url is: https://..."
echo 3. Copia a URL completa (ex: https://xxxxx.loca.lt)
echo 4. Volta aqui e cola a URL abaixo
echo.
set /p TUNEL_URL="Cole a URL aqui: "

REM Limpar URL
set TUNEL_URL=!TUNEL_URL:"=!
set TUNEL_URL=!TUNEL_URL: =!
set TUNEL_URL=!TUNEL_URL:your url is: =!
set TUNEL_URL=!TUNEL_URL:your url is =!

if "!TUNEL_URL!"=="" (
    echo ❌ ERRO: Não inseriste a URL!
    pause
    exit /b 1
)

REM Guardar URL
echo !TUNEL_URL! > "%~dp0\tunnel_url.txt"
echo.
echo ✅ URL guardada: !TUNEL_URL!
echo.

REM Atualizar index.html
echo [6/6] 📝 Atualizando index.html...
powershell -Command "$file = '%~dp0\..\app2\app2\web\index.html'; $content = Get-Content $file -Raw; $content = $content -replace 'window\.API_BASE = ''[^'']*''', ('window.API_BASE = ''!TUNEL_URL!'''); Set-Content $file -Value $content -NoNewline"
echo ✅ index.html atualizado
echo.

REM Iniciar Flutter
echo [7/7] 🎨 Executando Flutter Web...
echo.
echo ⚠️  A primeira compilação pode demorar 3-5 minutos
echo ⚠️  O Chrome vai abrir automaticamente quando compilar
echo ⚠️  Mantém esta janela aberta!
echo.
echo URL da API: !TUNEL_URL!
echo.
timeout /t 2 /nobreak >nul

cd /d "%~dp0\..\app2\app2"
flutter run -d chrome --dart-define=API_BASE=!TUNEL_URL! --web-port=8080 --web-hostname=localhost

pause

