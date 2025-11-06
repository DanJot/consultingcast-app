@echo off
echo.
echo ========================================
echo   🔍 VERIFICAR STATUS
echo ========================================
echo.

echo Verificando processos...
echo.

REM Verificar Node.js
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ API Node.js: A CORRER
) else (
    echo ❌ API Node.js: NÃO ESTÁ A CORRER
)

REM Verificar Cloudflared
tasklist /FI "IMAGENAME eq cloudflared.exe" 2>NUL | find /I /N "cloudflared.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ Cloudflare Tunnel: A CORRER
) else (
    echo ❌ Cloudflare Tunnel: NÃO ESTÁ A CORRER
)

REM Verificar Dart/Flutter
tasklist /FI "IMAGENAME eq dart.exe" 2>NUL | find /I /N "dart.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ✅ Flutter: A CORRER (compilando...)
) else (
    echo ❌ Flutter: NÃO ESTÁ A CORRER
)

echo.
echo ========================================
echo   💡 SOLUÇÃO
echo ========================================
echo.
echo Se o Chrome está em branco:
echo   1. Aguarda mais alguns minutos (compilação pode demorar)
echo   2. Ou fecha tudo e executa: .\scripts\iniciar-tudo-simples.bat
echo.
pause
