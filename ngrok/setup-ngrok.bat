@echo off
echo ========================================
echo   CONFIGURACAO NGROK - CONSULTINGCAST
echo ========================================
echo.
echo 1. Criar conta em: https://dashboard.ngrok.com/signup
echo 2. Depois de registado, copia o authtoken
echo 3. Vai aparecer algo como: ngrok authtoken xxxxx...
echo.
echo Pressiona qualquer tecla depois de teres o authtoken...
pause >nul
echo.
set /p AUTHTOKEN="Cole o authtoken completo aqui: "
echo.
echo A configurar ngrok...
ngrok.exe config add-authtoken %AUTHTOKEN%
echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ ngrok configurado com sucesso!
    echo.
    echo Agora podes executar: start-tunnel.bat
) else (
    echo ❌ Erro na configuração. Verifica o authtoken.
)
echo.
pause

