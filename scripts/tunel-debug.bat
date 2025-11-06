@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo.
echo ========================================
echo   🔧 SOLUÇÃO RÁPIDA - TÚNEL NÃO FUNCIONA
echo ========================================
echo.
echo O túnel não funciona porque a API não está a responder!
echo.
echo Vamos verificar:
echo.

REM Verificar se Node.js está a correr
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if errorlevel 1 (
    echo ❌ A API Node.js NÃO está a correr!
    echo.
    echo SOLUÇÃO:
    echo   1. Abre uma NOVA janela de terminal
    echo   2. Executa: iniciar-api.bat
    echo   3. Aguarda aparecer "API a correr em http://localhost:3000"
    echo   4. Depois volta aqui e executa este script novamente
    echo.
    pause
    exit /b 1
)

echo ✅ Node.js está a correr
echo.

REM Verificar se responde na porta 3000
echo Testando conexão com http://localhost:3000...
curl -s -m 5 http://localhost:3000/health >nul 2>&1
if errorlevel 1 (
    echo ❌ A API não está a responder em http://localhost:3000
    echo.
    echo Possíveis causas:
    echo   - A API ainda está a iniciar (aguarda mais 10 segundos)
    echo   - A API está a correr noutra porta
    echo   - Há um erro na API (verifica a janela da API)
    echo.
    echo Tenta:
    echo   1. Verifica a janela da API para ver se há erros
    echo   2. Aguarda mais 10 segundos e tenta novamente
    echo.
    pause
    exit /b 1
)

echo ✅ API está a responder corretamente!
echo.
echo Agora podemos criar o túnel...
echo.
timeout /t 2 /nobreak >nul

cd /d "%~dp0\..\cloudflared"
echo Criando túnel para: http://localhost:3000
echo.
echo ⚠️  IMPORTANTE: Aguarda 5-10 segundos até aparecer a URL
echo.
.\cloudflared.exe tunnel --url http://localhost:3000
pause

