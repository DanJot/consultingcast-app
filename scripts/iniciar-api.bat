@echo off
chcp 65001 >nul
cd /d "%~dp0\..\api-server"
echo.
echo ========================================
echo   🚀 Iniciar API Node.js
echo ========================================
echo.
echo API: http://localhost:3000
echo MySQL: 10.1.55.10:3306
echo.
echo ⚠️  Pressione Ctrl+C para parar
echo.
node server.js
