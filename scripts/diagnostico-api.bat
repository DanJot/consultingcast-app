@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo.
echo ========================================
echo   🔍 DIAGNÓSTICO COMPLETO DA API
echo ========================================
echo.

REM Verificar se Node.js está a correr
echo [1/4] Verificando processos Node.js...
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if errorlevel 1 (
    echo ❌ Node.js NÃO está a correr!
    echo.
    echo SOLUÇÃO: Executa iniciar-api.bat primeiro
    pause
    exit /b 1
)
echo ✅ Node.js está a correr
echo.

REM Verificar portas abertas
echo [2/4] Verificando porta 3000...
netstat -ano | findstr ":3000" >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Porta 3000 não está em uso
    echo    (A API pode estar noutra porta ou não iniciou ainda)
) else (
    echo ✅ Porta 3000 está em uso
    echo.
    echo Processos na porta 3000:
    netstat -ano | findstr ":3000"
)
echo.

REM Testar API com PowerShell (mais confiável que curl)
echo [3/4] Testando API com PowerShell...
powershell -Command "$response = try { Invoke-WebRequest -Uri 'http://localhost:3000/health' -Method GET -TimeoutSec 5 -UseBasicParsing; $response.StatusCode } catch { $_.Exception.Message }" >temp_test.txt 2>&1
set /p TEST_RESULT=<temp_test.txt
del temp_test.txt

echo !TEST_RESULT! | findstr /C:"200" >nul
if errorlevel 1 (
    echo ❌ API não está a responder corretamente
    echo.
    echo Resultado do teste: !TEST_RESULT!
    echo.
    echo Possíveis causas:
    echo   1. A API ainda está a iniciar (aguarda mais 10 segundos)
    echo   2. A API está com erro (verifica a janela da API)
    echo   3. Firewall está a bloquear
    echo.
    echo Vamos tentar testar diretamente...
    echo.
    
    REM Tentar abrir no browser
    echo [4/4] Tentando abrir http://localhost:3000/health no browser...
    start http://localhost:3000/health
    timeout /t 3 /nobreak >nul
    
    echo.
    echo Se o browser abriu mas mostra erro, há um problema na API.
    echo Verifica a janela da API para ver os logs de erro.
    echo.
    pause
    exit /b 1
) else (
    echo ✅ API está a responder corretamente!
    echo    Status: !TEST_RESULT!
    echo.
)

REM Verificar se podemos criar o túnel
echo [4/4] Pronto para criar túnel!
echo.
echo ✅ Tudo OK! A API está a funcionar.
echo.
echo Agora podemos criar o túnel Cloudflare...
echo.
timeout /t 2 /nobreak >nul

cd /d "%~dp0\..\cloudflared"
echo Criando túnel para: http://localhost:3000
echo.
echo ⚠️  IMPORTANTE: Aguarda 5-10 segundos até aparecer a URL
echo.
.\cloudflared.exe tunnel --url http://localhost:3000
pause

