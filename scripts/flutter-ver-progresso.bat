@echo off
cd /d "%~dp0\..\app2\app2"
echo.
echo ========================================
echo   🚀 FLUTTER WEB - Compilando...
echo ========================================
echo.
echo URL da API: https://cuisine-prescription-costs-exhibit.trycloudflare.com
echo.
echo ⚠️  AGUARDA - A primeira compilação pode demorar 3-5 minutos!
echo.
echo Vais ver mensagens de compilação abaixo...
echo Quando terminar, o Chrome abre AUTOMATICAMENTE!
echo.
echo ========================================
echo.
flutter run -d chrome --dart-define=API_BASE=https://cuisine-prescription-costs-exhibit.trycloudflare.com

