@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo.
echo ========================================
echo   🚀 INICIAR API + VERIFICAR
echo ========================================
echo.
echo Isto vai:
echo   1. Iniciar a API Node.js
echo   2. Aguardar que responda
echo   3. Mostrar o status
echo.
pause

cd /d "%~dp0\..\api-server"

REM Iniciar API em background e capturar output
echo Iniciando API...
start /B node server.js >api_output.txt 2>&1

REM Aguardar API iniciar
echo Aguardando API iniciar...
timeout /t 3 /nobreak >nul

REM Verificar se API está a responder (tentativas múltiplas)
set API_OK=0
for /L %%i in (1,1,15) do (
    powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:3000/health' -Method GET -TimeoutSec 2 -UseBasicParsing; exit 0 } catch { exit 1 }" >nul 2>&1
    if not errorlevel 1 (
        set API_OK=1
        goto :api_ready
    )
    echo Aguardando API... (tentativa %%i/15)
    timeout /t 1 /nobreak >nul
)

:api_ready
if !API_OK!==0 (
    echo.
    echo ❌ ERRO: A API não está a responder após 15 segundos
    echo.
    echo Verifica o ficheiro api_output.txt para ver os erros
    echo.
    type api_output.txt
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ API está a responder!
echo.
echo Testando endpoint /health...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:3000/health' -Method GET -TimeoutSec 2 -UseBasicParsing; Write-Host $r.Content } catch { Write-Host 'Erro:' $_.Exception.Message }"
echo.
echo ✅ API está pronta para receber pedidos!
echo.
echo Mantém esta janela aberta e usa outra janela para criar o túnel.
echo.
pause

