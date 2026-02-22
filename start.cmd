@echo off
REM ===================================
REM Docker Startup Script (Windows)
REM ===================================

setlocal enabledelayedexpansion

REM Cores simples
echo.
echo ======================================
echo    WhatsApp API - Docker Startup
echo ======================================
echo.

REM Verificar se está na pasta certa
if not exist "docker-compose.yml" (
    echo Erro: docker-compose.yml nao encontrado!
    echo Execute este script de dentro da pasta 'docker\'
    pause
    exit /b 1
)

REM Menu
echo Escolha uma opcao:
echo.
echo 1 - Producao (docker-compose.yml)
echo 2 - Desenvolvimento (docker-compose.dev.yml)
echo 3 - Parar containers
echo 4 - Ver logs
echo 5 - Sair
echo.

set /p choice="Digite sua escolha (1-5): "

if "%choice%"=="1" (
    echo.
    echo [*] Iniciando producao...
    docker-compose -f docker-compose.yml up -d
    echo.
    echo [+] API rodando em http://localhost:5000
    echo [+] Health check: http://localhost:5000/health
    timeout /t 3
    goto menu
)

if "%choice%"=="2" (
    echo.
    echo [*] Iniciando desenvolvimento (hot reload)...
    docker-compose -f docker-compose.dev.yml up -d
    echo.
    echo [+] API rodando em http://localhost:5000
    echo [+] As mudancas no codigo vao ser recarregadas automaticamente
    timeout /t 3
    goto menu
)

if "%choice%"=="3" (
    echo.
    echo [*] Parando containers...
    docker-compose down
    echo [+] Containers parados
    timeout /t 2
    goto menu
)

if "%choice%"=="4" (
    echo.
    echo [*] Mostrando logs (Ctrl+C para sair)...
    docker-compose logs -f whatsapp-api
    goto menu
)

if "%choice%"=="5" (
    exit /b 0
)

echo Opcao invalida!
timeout /t 2
goto menu
