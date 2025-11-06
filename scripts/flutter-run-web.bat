@echo off
cd /d "%~dp0\..\app2\app2"
echo.
echo ========================================
echo   🚀 FLUTTER WEB - Executar
echo ========================================
echo.
echo URL da API: https://katie-learn-forum-nuke.trycloudflare.com
echo.
echo IMPORTANTE: Usa 'flutter run' e não 'flutter build'
echo 'flutter build' só compila, não abre o browser!
echo.
echo ========================================
echo.
flutter run -d chrome --dart-define=API_BASE=https://katie-learn-forum-nuke.trycloudflare.com --web-port=8080

