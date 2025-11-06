@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo.
echo ========================================
echo   🔍 VERIFICAR API ANTES DO TÚNEL
echo ========================================
echo.

REM Verificar se a API está a correr
echo [1/2] Verificando se a API está a correr em localhost:3000...
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo.
    echo ❌ ERRO: A API não está a responder em http://localhost:3000
    echo.
    echo A API precisa estar a correr ANTES de criar o túnel!
    echo.
    echo O que fazer:
    echo   1. Abre outra janela de terminal
    echo   2. Executa: iniciar-api.bat
    echo   3. Aguarda aparecer "API escutando na porta 3000"
    echo   4. Depois volta aqui e executa este script novamente
    echo.
    pause
    exit /b 1
)

echo ✅ API está a responder!
echo.

REM Criar túnel
echo [2/2] Criando túnel Cloudflare...
echo.
echo ⚠️  IMPORTANTE: Aguarda 5-10 segundos até aparecer a URL
echo.
cd /d "%~dp0\..\cloudflared"
.\cloudflared.exe tunnel --url http://localhost:3000

pause

