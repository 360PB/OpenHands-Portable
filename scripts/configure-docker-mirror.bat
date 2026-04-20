@echo off
echo [OpenHands] Configuring Docker registry mirrors for China...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0configure-docker-mirror.ps1"
echo.
echo [INFO] Docker daemon.json updated.
echo Please RESTART Docker Desktop to apply changes:
echo   1. Right-click Docker tray icon -^> Quit Docker Desktop
echo   2. Start Docker Desktop again
echo.
pause