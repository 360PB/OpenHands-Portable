# OpenHands 整合包源码更新 Skill

> 指导 AI 如何安全地更新整合包中的 OpenHands 源码，同时保留运行时环境和用户数据。

## 适用场景

- OpenHands 官方发布了新版本，需要同步到整合包
- 需要应用补丁或 hotfix
- 用户自定义修改了源码，需要合并上游更新

## 更新前检查清单

| # | 检查项 | 说明 |
|---|--------|------|
| 1 | **备份 `workspace/` 目录** | 用户数据、会话、配置不可丢失 |
| 2 | **备份 `configs/config.toml`** | API Key 等敏感配置 |
| 3 | **记录当前 SDK 版本** | `pip show openhands-sdk` |
| 4 | **停止所有服务** | `stop.bat` 关闭后端和前端 |

## 目录结构理解

```
OpenHands-Portable/
├── app/                    ← 源码层（可替换更新）
│   ├── openhands/          ← 后端源码
│   ├── frontend/           ← 前端源码
│   └── third_party/        ← 第三方扩展
├── runtime/                ← 运行时层（尽量不动）
│   ├── python/             ← Python 嵌入式环境 + pip 依赖
│   └── nodejs/             ← Node.js 运行时
├── workspace/              ← 用户数据（必须保留）
├── configs/                ← 配置文件（保留）
├── scripts/                ← 启动脚本（按需更新）
└── images/                 ← Docker 镜像 tar（保留）
```

> **原则**：只更新 `app/`，不动 `runtime/`、`workspace/`、`configs/`。

## 更新方式

### 方式 A：Git 拉取更新（推荐，保留修改历史）

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable\app

# 1. 查看当前分支和提交
git status
git log --oneline -5

# 2. 保存本地修改（如有）
git stash

# 3. 拉取最新代码
git pull origin main

# 4. 恢复本地修改
git stash pop

# 5. 解决冲突（如有）
```

### 方式 B：覆盖式更新（全新替换）

```powershell
# 1. 备份旧源码
Move-Item "E:\OpenHands-Portable\OpenHands-Portable\app" "E:\OpenHands-Portable\OpenHands-Portable\app-backup-$(Get-Date -Format 'yyyyMMdd')"

# 2. 复制新源码
Copy-Item -Recurse "<新源码路径>" "E:\OpenHands-Portable\OpenHands-Portable\app"

# 3. 恢复用户配置
Copy-Item "E:\OpenHands-Portable\OpenHands-Portable\app-backup-xxx\config.toml" "E:\OpenHands-Portable\OpenHands-Portable\app\config.toml" -ErrorAction SilentlyContinue
```

## 依赖同步

### 检查 SDK 版本兼容性

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable\runtime\python

# 查看当前 SDK 版本
.\python.exe -m pip show openhands-sdk

# 查看新版本需要的 SDK 版本（查看 app/pyproject.toml 或 app/frontend/package.json）
Get-Content "E:\OpenHands-Portable\OpenHands-Portable\app\pyproject.toml" | Select-String "openhands-sdk"
```

### 更新 Python 依赖

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable\runtime\python

# 方案 1：按 requirements 安装（如有）
# .\python.exe -m pip install -r ..\..\app\requirements.txt --target=Lib\site-packages --upgrade

# 方案 2：只更新 openhands-sdk
.\python.exe -m pip install --upgrade openhands-sdk --target=Lib\site-packages

# 方案 3：根据 pyproject.toml 安装（需要 poetry/pip）
# 不推荐，因为嵌入式 Python 环境有限制
```

### 更新前端依赖

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable\app\frontend
$env:PATH = "E:\OpenHands-Portable\OpenHands-Portable\runtime\nodejs;$env:PATH"

# 安装/更新依赖
npm install

# 或强制重新安装
npm ci
```

## 更新后验证

### 1. 配置兼容性检查

```powershell
# 检查 config.toml 中是否有新增/废弃字段
# 对比 app/config.template.toml 和 configs/config.toml
```

### 2. 启动测试

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable
.\stop.bat     # 确保无残留
.\start.bat     # 观察启动日志
```

### 3. 关键功能验证清单

| 检查项 | 预期结果 |
|--------|----------|
| 后端启动 | Uvicorn 监听 `:3000`，无异常 |
| 前端启动 | `npm run dev` 监听 `:3001` |
| Docker 沙箱 | 能正常创建容器，agent 可运行 |
| 文件导出 | `docker cp` 能复制文件到宿主机 |
| 用户数据 | `workspace/` 中历史会话可读 |

## 常见问题

### Q: 更新后 `ModuleNotFoundError`

**原因**：新源码依赖了新的 Python 包

**解决**：
```powershell
cd E:\OpenHands-Portable\OpenHands-Portable\runtime\python
.\python.exe -m pip install <缺失包名> --target=Lib\site-packages
```

### Q: 更新后 SDK 版本不匹配

**原因**：`openhands-sdk` 版本太旧

**解决**：
```powershell
cd E:\OpenHands-Portable\OpenHands-Portable\runtime\python
.\python.exe -m pip install --upgrade openhands-sdk --target=Lib\site-packages
```

### Q: 前端编译失败

**原因**：Node 依赖版本冲突

**解决**：
```powershell
cd E:\OpenHands-Portable\OpenHands-Portable\app\frontend
Remove-Item -Recurse node_modules
npm install
```

### Q: 更新后配置失效

**原因**：新版本的配置字段变更

**解决**：对比 `app/config.template.toml`，将新增字段合并到 `configs/config.toml`

## 回滚策略

如果更新失败，快速回滚：

```powershell
# 停止服务
.\stop.bat

# 恢复旧源码
Remove-Item -Recurse "E:\OpenHands-Portable\OpenHands-Portable\app"
Move-Item "E:\OpenHands-Portable\OpenHands-Portable\app-backup-xxx" "E:\OpenHands-Portable\OpenHands-Portable\app"

# 重启
.\start.bat
```

## 自动化脚本模板

### `scripts/update-app.bat`（一键更新）

```batch
@echo off
set "ROOT=%~dp0.."
set "PYTHON=%ROOT%\runtime\python\python.exe"

echo [OpenHands] Updating app source...
echo.

:: Stop services
if exist "%ROOT%\stop.bat" (
    call "%ROOT%\stop.bat" >nul 2>&1
)

:: Backup
echo [INFO] Creating backup...
set "BACKUP=%ROOT%\app-backup-%date:~0,4%%date:~5,2%%date:~8,2%"
if exist "%BACKUP%" rmdir /s /q "%BACKUP%"
move "%ROOT%\app" "%BACKUP%"

:: TODO: Insert your update logic here (git pull / copy / etc.)
echo [WARN] Please manually update app/ directory, then press any key...
pause

:: Sync SDK
echo [INFO] Syncing SDK...
"%PYTHON%" -m pip install --upgrade openhands-sdk --target="%ROOT%\runtime\python\Lib\site-packages"

:: Verify
echo [INFO] Starting test run...
call "%ROOT%\start.bat"
```
