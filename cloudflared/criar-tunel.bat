@echo off
cd /d "%~dp0"
echo ========================================
echo   CRIAR TUNEL CLOUDFLARE
echo ========================================
echo.
echo A criar tunel MySQL...
.\cloudflared.exe tunnel create consultingcast-mysql
echo.
if %ERRORLEVEL% EQU 0 (
    echo ✅ Tunel criado!
    echo.
    echo Proximo passo: Executa iniciar-tunel.bat
) else (
    echo ❌ Erro ao criar tunel
    echo Verifica se ja esta autenticado (executa login-cloudflare.bat primeiro)
)
echo.
pause

