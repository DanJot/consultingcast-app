@echo off
cd /d "%~dp0\..\app2\app2"
echo.
echo ========================================
echo   🚀 FLUTTER WEB - Nova URL do Túnel
echo ========================================
echo.
echo URL da API: https://cuisine-prescription-costs-exhibit.trycloudflare.com
echo.
echo IMPORTANTE: Mantém esta janela aberta!
echo O Chrome vai abrir automaticamente quando compilar.
echo.
echo ========================================
echo.
flutter run -d chrome --dart-define=API_BASE=https://cuisine-prescription-costs-exhibit.trycloudflare.com

