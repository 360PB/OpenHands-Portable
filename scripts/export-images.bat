@echo off
set "ROOT=%~dp0.."
set "IMAGE_FILE=%ROOT%\images\agent-server-1.17.0-python.tar"

echo [OpenHands] Exporting Docker images to images\ folder...
echo.

:: Check Docker
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Desktop is not running
    pause
    exit /b 1
)

:: Check if image exists
docker inspect ghcr.io/openhands/agent-server:1.17.0-python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Image not found in Docker. Please run start.bat first to download it.
    pause
    exit /b 1
)

:: Export
echo [INFO] Exporting ghcr.io/openhands/agent-server:1.17.0-python...
echo [INFO] This may take a few minutes...
docker save ghcr.io/openhands/agent-server:1.17.0-python -o "%IMAGE_FILE%"

if errorlevel 1 (
    echo [ERROR] Export failed
    pause
    exit /b 1
)

for %%F in ("%IMAGE_FILE%") do set "SIZE=%%~zF"
echo.
echo [INFO] Export complete: images\agent-server-1.17.0-python.tar
echo [INFO] File size: %SIZE% bytes
echo.
pause