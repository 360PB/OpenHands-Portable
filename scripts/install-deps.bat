@echo off
chcp 65001 >/dev/null
set "ROOT=%~dp0.."
cd /d "%ROOT%"

echo [OpenHands] 正在安装 Python 依赖...
echo.

set "PYTHON=%ROOT%untime\python\python.exe"
set "PIP=%ROOT%untime\python\Scripts\pip.exe"

REM 设置 pip 镜像
"%PYTHON%" -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

REM 安装 setuptools 和 wheel
echo 安装 setuptools 和 wheel...
"%PYTHON%" -m pip install --upgrade setuptools wheel

REM 安装核心依赖
echo 安装 OpenHands 核心包...
"%PYTHON%" -m pip install --target=runtime\python\Lib\site-packages openhands-sdk openhands-agent-server openhands-tools

REM 安装额外依赖
echo 安装额外依赖...
"%PYTHON%" -m pip install --target=runtime\python\Lib\site-packages fastapi uvicorn python-socketio asyncpg pg8000 sqlalchemy playwright docker

echo.
echo [完成] 依赖安装完成
pause
