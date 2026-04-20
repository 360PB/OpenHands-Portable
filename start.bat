@echo off
set "ROOT=%~dp0"
set "PYTHON=%ROOT%\runtime\python\python.exe"
set "PYTHONPATH=%ROOT%\runtime\python\Lib\site-packages"
set "PATH=%ROOT%\runtime\nodejs;%PATH%"

echo [OpenHands] Initializing portable environment...
echo.

:: Verify runtime exists
if not exist "%PYTHON%" (
    echo [ERROR] Python runtime not found: %PYTHON%
    pause
    exit /b 1
)

if not exist "%ROOT%\runtime\nodejs\node.exe" (
    echo [ERROR] Node.js runtime not found
    pause
    exit /b 1
)

:: Check Docker Desktop
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Desktop is not running or not installed
    echo Please install Docker Desktop and ensure it is started:
    echo https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

:: Docker image handling: prefer local tar, fallback to pull
echo [INFO] Checking Docker images...
set "AGENT_IMAGE=ghcr.io/openhands/agent-server:1.17.0-python"
set "LOCAL_TAR=%ROOT%\images\agent-server-1.17.0-python.tar"

:: Priority 1: Load from local tar if available
if exist "%LOCAL_TAR%" (
    echo [INFO] Found local tar: images\agent-server-1.17.0-python.tar
    echo [INFO] Loading image from tar...
    docker load -i "%LOCAL_TAR%"
    if errorlevel 1 (
        echo [WARN] Failed to load from tar, will check existing image or try pull...
    ) else (
        echo [INFO] Image loaded from tar successfully
        goto :image_done
    )
)

:: Priority 2: Check if image already exists locally
docker inspect %AGENT_IMAGE% >nul 2>&1
if not errorlevel 1 (
    echo [INFO] Docker image already exists locally
    goto :image_done
)

:: Priority 3: Download from registry (requires internet)
echo [INFO] Local tar not found and image not present.
echo [INFO] Downloading from registry, please wait...
echo [TIP] If download is slow, run scripts\configure-docker-mirror.bat first
docker pull %AGENT_IMAGE%
if errorlevel 1 (
    echo [ERROR] Failed to download image. Check network and Docker settings.
    echo [TIP] For China users: run scripts\configure-docker-mirror.bat to use domestic mirrors
    echo [TIP] Or copy a pre-downloaded tar to images\agent-server-1.17.0-python.tar
    pause
    exit /b 1
)

:image_done

:: Setup workspace
set "WORKSPACE=%ROOT%\workspace"
if not exist "%WORKSPACE%\data" mkdir "%WORKSPACE%\data"

:: Add app source to Python path
set "PYTHONPATH=%PYTHONPATH%;%ROOT%\app"

:: Copy config to app directory so OpenHands can find it
if exist "%ROOT%\configs\config.toml" (
    copy /Y "%ROOT%\configs\config.toml" "%ROOT%\app\config.toml" >nul
    echo [INFO] config.toml loaded from configs\
)

:: Backend settings
set "BACKEND_HOST=127.0.0.1"
set "BACKEND_PORT=3000"
set "VITE_BACKEND_HOST=%BACKEND_HOST%:%BACKEND_PORT%"
set "SERVE_FRONTEND=false"

:: Start backend
echo [1/2] Starting backend service (port %BACKEND_PORT%)...
start "OpenHands Backend" cmd /k "cd /d %ROOT%\app && set PYTHONPATH=%PYTHONPATH% && set WORKSPACE_BASE=%WORKSPACE% && set SERVE_FRONTEND=false && ""%PYTHON%"" -m uvicorn openhands.server.listen:app --host %BACKEND_HOST% --port %BACKEND_PORT%"

:: Wait for backend
timeout /t 5 /nobreak >nul

:: Start frontend
echo [2/2] Starting frontend service (port 3001)...
start "OpenHands Frontend" cmd /k "cd /d %ROOT%\app\frontend && npm run dev -- --port 3001"

echo.
echo ================================================
echo   OpenHands Portable started
echo   Backend: http://%BACKEND_HOST%:%BACKEND_PORT%
echo   Frontend: http://localhost:3001
echo ================================================
echo.
echo Note: Closing this window will NOT stop services
echo.
pause