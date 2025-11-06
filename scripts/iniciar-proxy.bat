@echo off
cd /d "%~dp0\..\tcp-proxy"
echo.
echo ========================================
echo   🚀 Iniciar Proxy TCP MySQL
echo ========================================
echo.
echo Proxy TCP: localhost:3307
echo Destino: 10.1.55.10:3306
echo.
echo Pressione Ctrl+C para parar
echo.
node server.js

