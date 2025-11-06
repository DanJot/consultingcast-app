@echo off
cd /d "%~dp0"
echo ========================================
echo   INICIAR TUNEL CLOUDFLARE - MySQL
echo ========================================
echo.
echo IMPORTANTE: Mantem esta janela aberta!
echo.
echo A iniciar tunel para MySQL (10.1.55.10:3306)...
echo.
echo Quando aparecer a URL (tipo: tcp://xxxxx.trycloudflare.com:xxxxx)
echo Copia essa URL e usa no Railway!
echo.
echo Pressiona Ctrl+C para parar
echo.
.\cloudflared.exe tunnel run consultingcast-mysql --url tcp://10.1.55.10:3306

