# OpenHands Docker 沙箱文件导出 Skill

> 在 OpenHands Docker 沙箱模式下，帮助 AI 定位容器内的文件并导出到宿主机（Windows）。

## 适用场景

- OpenHands 使用 Docker 沙箱运行（`runtime = "docker"`）
- 需要把容器内生成的文件（如代码、报告、图片）拿到宿主机
- 用户问"文件在哪"、"怎么导出"、"帮我下载"等

## 核心原理

OpenHands V1 Docker 沙箱默认**不将 `/workspace` 映射到宿主机**，文件只在容器内部：

```
宿主机              Docker 容器
  │                    │
  │  ── no mount ──→   ├─ /workspace/project/     ← 代码工作区
  │                    ├─ /workspace/conversations/ ← 会话数据
  │                    └─ /workspace/bash_events/   ← 事件日志
```

因此必须通过 `docker cp` 命令手动复制出来。

## 使用步骤

### Step 1: 确定容器名称

OpenHands Docker 容器的命名规则：`oh-agent-server-<随机后缀>`

```powershell
# 列出所有 OpenHands 容器
docker ps --format '{{.Names}}' | findstr 'oh-agent-server'
```

### Step 2: 查找容器内文件

```powershell
# 列出工作区根目录
docker exec <容器名> ls -la /workspace/project/

# 搜索特定文件
docker exec <容器名> find /workspace -name "*.html"
```

### Step 3: 导出到宿主机

```powershell
# 复制单个文件
docker cp <容器名>:/workspace/project/<文件名> <宿主机目标路径>

# 复制整个目录
docker cp <容器名>:/workspace/project/ <宿主机目标路径>
```

### Step 4: 验证

```powershell
Test-Path "<宿主机目标路径>"
```

## 完整示例

```powershell
# 1. 获取容器名
$container = docker ps --format '{{.Names}}' | findstr 'oh-agent-server' | Select-Object -First 1

# 2. 查找文件
docker exec $container find /workspace/project -name "*.html"

# 3. 导出到 OpenHands workspace 目录
$dest = "E:\OpenHands-Portable\OpenHands-Portable\workspace\"
docker cp "${container}:/workspace/project/snake-evolution.html" "$dest"

# 4. 确认
Get-Item "$dest\snake-evolution.html"
```

## 常用路径速查

| 容器内路径 | 说明 |
|------------|------|
| `/workspace/project/` | 代码工作区（agent 操作的主要目录） |
| `/workspace/conversations/` | 会话持久化数据 |
| `/workspace/bash_events/` | bash 事件日志 |

## 注意事项

1. **容器必须处于运行状态**才能 `docker exec` / `docker cp`
2. 如果容器已停止，用 `docker cp` 仍可复制文件，但 `docker exec` 不行
3. 默认配置下，文件不会自动同步到宿主机，必须手动导出
4. 导出路径建议放在整合包的 `workspace/` 目录，方便用户找到

## 批量导出脚本模板

如需一键导出整个 project 目录，可在 `scripts/` 下创建 `export-workspace.bat`：

```batch
@echo off
set "DEST=%~dp0..\workspace\exported\"
if not exist "%DEST%" mkdir "%DEST%"

for /f "tokens=*" %%c in ('docker ps --format "{{.Names}}" ^| findstr "oh-agent-server"') do (
    echo [INFO] Exporting from %%c ...
    docker cp "%%c:/workspace/project/" "%DEST%"
)

echo [INFO] Done. Files in: %DEST%
pause
```
