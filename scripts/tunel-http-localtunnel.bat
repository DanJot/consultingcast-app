@echo off
echo.
echo ========================================
echo   🌐 LocalTunnel HTTP (Alternativa)
echo ========================================
echo.
echo IMPORTANTE: A API deve estar a correr em localhost:3000 primeiro!
echo.
echo Criando túnel HTTP para: http://localhost:3000
echo.
echo Aguarde... A URL aparecerá abaixo:
echo ========================================
echo.
npx --yes localtunnel --port 3000
pause

