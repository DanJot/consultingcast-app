@echo off
echo ========================================
echo   TUNEL NGROK - MySQL
echo ========================================
echo.
echo A criar túnel para MySQL na porta 3306...
echo.
echo IMPORTANTE: Mantém esta janela aberta!
echo.
echo Quando aparecer a URL (tipo: tcp://0.tcp.ngrok.io:12345)
echo Copia essa URL e usa nas variáveis de ambiente da API cloud
echo.
echo Pressiona Ctrl+C para parar o túnel
echo.
ngrok.exe tcp 3306

