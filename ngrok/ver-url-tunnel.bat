@echo off
echo ========================================
echo   VER URL DO TUNEL NGROK
echo ========================================
echo.
echo A verificar túnel ativo...
echo.
timeout /t 2 >nul
powershell -Command "try { $tunnels = Invoke-RestMethod -Uri 'http://localhost:4040/api/tunnels'; foreach ($tunnel in $tunnels.tunnels) { Write-Host 'URL do Túnel:' $tunnel.public_url; Write-Host 'Destino:' $tunnel.config.addr } } catch { Write-Host '❌ ngrok nao esta a correr ou ainda nao iniciou.'; Write-Host 'Executa start-tunnel.bat primeiro!' }"
echo.
echo ========================================
echo   INSTRUCOES
echo ========================================
echo.
echo 1. Copia a URL do túnel acima (tipo: tcp://0.tcp.ngrok.io:12345)
echo 2. Separa em HOST e PORT:
echo    - HOST: 0.tcp.ngrok.io
echo    - PORT: 12345
echo 3. Usa estes valores no Railway quando fizeres deploy da API
echo.
pause

