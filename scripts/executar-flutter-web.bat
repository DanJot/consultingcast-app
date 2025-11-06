@echo off
cd /d "%~dp0\..\app2\app2"
echo.
echo ========================================
echo   🚀 Executar Flutter Web
echo ========================================
echo.
echo URL da API: https://meditation-responsibilities-dryer-usr.trycloudflare.com
echo.
echo Compilando e iniciando...
echo.
flutter run -d chrome --dart-define=API_BASE=https://meditation-responsibilities-dryer-usr.trycloudflare.com
pause

