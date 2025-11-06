@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
cls
echo.
echo ========================================
echo   🚀 INICIAR TUDO - SOLUÇÃO SIMPLES
echo ========================================
echo.
echo Como o Cloudflare não mostra URL, usa localtunnel!
echo.
echo 📖 GUIA COMPLETO:
echo    - Para voltar a abrir: Executa este script
echo    - Para colocar online: Ver GUIA-RAPIDO.txt
echo.
echo PRIMEIRA VEZ:
echo   1. Executa este script
echo   2. Aguarda localtunnel criar a URL
echo   3. Copia a URL quando aparecer
echo   4. Cola o IP público quando pedir
echo.
echo PRÓXIMAS VEZES:
echo   - O script pergunta se queres usar a URL guardada
echo   - Mas lembra-te: URLs mudam quando reinicias o PC!
echo.
echo ⚠️  IMPORTANTE: Este método só funciona enquanto o PC está ligado.
echo    Para colocar online permanentemente, vê GUIA-RAPIDO.txt
echo.

REM Limpar processos antigos
echo.
echo [1/4] 🧹 Limpando processos antigos...
taskkill /F /IM node.exe /T >nul 2>&1
taskkill /F /IM cloudflared.exe /T >nul 2>&1
taskkill /F /IM dart.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul
echo ✅ Processos limpos
echo.

REM Verificar se já temos URL guardada
set TUNEL_URL=
set USAR_GUARDADA=N
if exist "%~dp0\tunnel_url.txt" (
    set /p TUNEL_URL=<"%~dp0\tunnel_url.txt"
    echo.
    echo ✅ URL guardada encontrada: !TUNEL_URL!
    echo.
    echo Queres usar esta URL? (S = Sim / N = Criar novo túnel)
    set /p USAR_URL="Resposta: "
    
    if /i "!USAR_URL!"=="S" (
        set USAR_GUARDADA=S
        echo Usando URL guardada...
        goto :url_pronta
    )
)

REM Iniciar API
echo.
echo [2/4] 🚀 Iniciando API Node.js...
start "API Node.js" cmd /k "cd /d %~dp0\..\api-server && echo ======================================== && echo   API Node.js && echo ======================================== && echo. && echo API: http://localhost:3000 && echo MySQL: 10.1.55.10:3306 && echo. && echo ⚠️  Mantém esta janela aberta! && echo. && node server.js"
timeout /t 5 /nobreak >nul

REM Verificar API
echo [3/4] 🔍 Verificando API...
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
if "!USAR_GUARDADA!"=="N" (
    echo [4/4] 🌐 Criando túnel com localtunnel...
    echo.
    echo ⚠️  localtunnel SEMPRE mostra a URL!
    echo    Aguarda aparecer: "your url is: https://..."
    echo.
    
    cd /d "%~dp0\..\api-server"
    
    REM Verificar se npx está disponível
    where npx >nul 2>&1
    if errorlevel 1 (
        echo.
        echo ❌ npm/npx não encontrado!
        echo.
        echo Instala Node.js primeiro: https://nodejs.org
        echo Ou usa o script: INICIAR-TUDO.bat (que funciona sem localtunnel)
        echo.
        pause
        exit /b 1
    )
    
    REM Criar túnel numa janela separada
    start "Localtunnel" cmd /k "cd /d %~dp0\..\api-server && echo ======================================== && echo   Localtunnel && echo ======================================== && echo. && echo Criando túnel para: http://localhost:3000 && echo. && echo ⚠️  IMPORTANTE: Aguarda aparecer a URL abaixo! && echo    Procura por: 'your url is: https://...' && echo. && echo ⚠️  LOCALTUNNEL PEDE IP PÚBLICO: && echo    O script vai obter automaticamente e mostrar-te! && echo. && echo ======================================== && echo. && npx localtunnel --port 3000"
    
    timeout /t 15 /nobreak >nul
    
    echo.
    echo ========================================
    echo   📋 COPIAR URL DO TÚNEL
    echo ========================================
    echo.
    echo 1. Vai para a janela do Localtunnel (acima)
    echo 2. Procura por: "your url is: https://..."
    echo 3. Copia a URL completa (ex: https://xxxxx.loca.lt)
    echo 4. Volta aqui e cola a URL abaixo
    echo.
    echo ⚠️  IMPORTANTE: LOCALTUNNEL PEDE IP PÚBLICO!
    echo    - Quando colares a URL aqui, vou obter o teu IP automaticamente
    echo    - No browser, vai pedir o IP público como senha
    echo    - Eu vou mostrar-te o IP para colares!
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
    
    echo.
    echo ⏳ Obtendo IP público...
    for /f "tokens=*" %%i in ('powershell -Command "(Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing).Content.Trim()"') do set PUBLIC_IP=%%i
    
    echo.
    echo ✅ IP PÚBLICO ENCONTRADO: !PUBLIC_IP!
    echo.
    echo ⚠️  IMPORTANTE: Localtunnel pede o IP público como senha!
    echo.
    echo Abrindo URL no browser...
    start "" "!TUNEL_URL!"
    timeout /t 3 /nobreak >nul
    
    echo.
    echo ========================================
    echo   🔓 DESBLOQUEAR TÚNEL
    echo ========================================
    echo.
    echo 1. No browser, vai aparecer uma página pedindo SENHA
    echo 2. COLA ESTE IP: !PUBLIC_IP!
    echo 3. Clica em "Continue" ou "Submit"
    echo.
    echo ⚠️  COPIA ESTE IP: !PUBLIC_IP!
    echo.
    echo Depois de desbloquear no browser, pressiona qualquer tecla aqui para continuar...
    pause >nul
    
    REM Guardar URL e IP
    echo !TUNEL_URL! > "%~dp0\tunnel_url.txt"
    echo !PUBLIC_IP! > "%~dp0\tunnel_ip.txt"
    echo.
    echo ✅ URL guardada: !TUNEL_URL!
    echo ✅ IP guardado: !PUBLIC_IP!
    echo.
    echo 📝 NOTA: Quando reiniciares o PC, vais precisar de criar um novo túnel
    echo    porque o localtunnel gera URLs diferentes cada vez.
    echo.
) else (
    echo [4/4] 🌐 URL já configurada...
    echo.
)

:url_pronta
echo ✅ Usando URL: !TUNEL_URL!
echo.

REM Atualizar index.html
echo [5/5] 📝 Atualizando index.html...
powershell -Command "$file = '%~dp0\..\app2\app2\web\index.html'; $content = Get-Content $file -Raw; $content = $content -replace 'window\.API_BASE = ''[^'']*''', ('window.API_BASE = ''!TUNEL_URL!'''); Set-Content $file -Value $content -NoNewline"
echo ✅ index.html atualizado
echo.

REM Iniciar Flutter
echo [6/6] 🎨 Executando Flutter Web...
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
