@echo off
cd /d "%~dp0\..\app2\app2"
echo.
echo ========================================
echo   🚀 FLUTTER WEB - Com URL do Túnel
echo ========================================
echo.
echo URL da API: https://katie-learn-forum-nuke.trycloudflare.com
echo.
echo IMPORTANTE: Mantém esta janela aberta!
echo O Chrome vai abrir automaticamente.
echo.
echo ========================================
echo.
flutter run -d chrome --dart-define=API_BASE=https://katie-learn-forum-nuke.trycloudflare.com

