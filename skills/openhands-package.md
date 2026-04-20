# OpenHands 整合包打包 Skill

> 指导 AI 如何将 OpenHands 整合包打包为可发布的压缩文件。

## 适用场景

- 制作 Release 分发包
- 备份整合包分享给他人
- 发布新版本到 GitHub Releases

## 打包前检查清单

| # | 检查项 | 说明 |
|---|--------|------|
| 1 | **敏感文件已排除** | `configs/config.toml` 含 API Key |
| 2 | **用户数据已排除** | `workspace/` 含个人文件 |
| 3 | **大文件已排除** | `images/*.tar` 通常 >1GB |
| 4 | **Git 历史已排除** | `.git/` 目录 |
| 5 | **IDE 配置已排除** | `.claude/`、`.vscode/` 等 |

## 排除规则速查

必须排除的文件/目录：

```
images/agent-server-1.17.0-python.tar   # Docker 镜像 (~1.2GB)
.git/                                    # Git 历史
configs/config.toml                      # 敏感配置（含 API Key）
.claude/                                 # IDE 配置
workspace/*                              # 用户数据
**/.env*                                 # 环境变量文件
```

必须保留的文件：

```
configs/config.template.toml             # 脱敏模板（供用户复制）
start.bat / stop.bat                     # 启动脚本
README.md                                # 文档
app/ / runtime/ / scripts/ / skills/    # 核心内容
```

## 打包命令

### Windows (PowerShell + tar)

```powershell
cd E:\OpenHands-Portable

# 清理旧的打包文件
if (Test-Path "OpenHands-Portable-Clean.zip") {
    Remove-Item "OpenHands-Portable-Clean.zip"
}

# 打包（排除敏感/大文件）
tar -caf "OpenHands-Portable-Clean.zip" `
    --exclude="OpenHands-Portable/images/agent-server-1.17.0-python.tar" `
    --exclude="OpenHands-Portable/.git" `
    --exclude="OpenHands-Portable/configs/config.toml" `
    --exclude="OpenHands-Portable/.claude" `
    --exclude="OpenHands-Portable/workspace/*" `
    --exclude="OpenHands-Portable/**/*.env" `
    --exclude="OpenHands-Portable/**/*.env.*" `
    "OpenHands-Portable"
```

### 验证打包结果

```powershell
cd E:\OpenHands-Portable

# 查看大小
$zip = Get-Item "OpenHands-Portable-Clean.zip"
"Size: {0:N2} MB" -f ($zip.Length / 1MB)

# 列出内容
tar -tf "OpenHands-Portable-Clean.zip" | Select-Object -First 20

# 验证排除项（应该无输出）
tar -tf "OpenHands-Portable-Clean.zip" | Select-String "config\.toml$"
tar -tf "OpenHands-Portable-Clean.zip" | Select-String "agent-server.*\.tar"
tar -tf "OpenHands-Portable-Clean.zip" | Select-String "\.git/"

# 验证保留项（应该有输出）
tar -tf "OpenHands-Portable-Clean.zip" | Select-String "config\.template\.toml$"
tar -tf "OpenHands-Portable-Clean.zip" | Select-String "start\.bat$"
```

## 完整版 vs 精简版

| 版本 | 包含 | 排除 | 大小 |
|------|------|------|------|
| **完整版** | runtime/ + images/*.tar | 无 | ~2.5 GB |
| **源码版** | app/ + configs/ + scripts/ | runtime/ + images/ | ~500 MB |
| **运行时版** | 全部 | images/*.tar | ~1.6 GB |

## 发布流程

### 1. 推送到 GitHub

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable
git add .
git commit -m "release: v1.x.x"
git push origin main
```

### 2. 创建 GitHub Release

- 到 https://github.com/360PB/OpenHands-Portable/releases
- 点击 "Draft a new release"
- 填写版本号（如 `v1.0.0`）
- 上传 `OpenHands-Portable-Clean.zip`

### 3. 用户下载后首次使用

```batch
:: 1. 解压
:: 2. 复制配置模板
copy configs\config.template.toml configs\config.toml
:: 3. 编辑 configs\config.toml 填入 API Key
:: 4. 双击 start.bat 启动
```

## 常见问题

### Q: 打包后文件还是很大

**原因**：`runtime/` 目录包含 Python + Node.js 嵌入式环境（约 1.2GB）

**解决**：
- 如果只需要源码，排除 `runtime/`
- 如果用户已有 Python/Node.js，可以提供 "源码版"

### Q: 用户反馈缺少 config.toml

**原因**：打包时排除了 `configs/config.toml`，用户没有手动创建

**解决**：确保 README 中有明确说明：
```batch
copy configs\config.template.toml configs\config.toml
```

### Q: 打包时 Permission Denied

**原因**：某些文件被进程占用（如正在运行的 OpenHands）

**解决**：
```batch
stop.bat
:: 等待几秒后重新打包
```

### Q: 如何制作包含运行时但不包含镜像的包

```powershell
tar -caf "OpenHands-Portable-NoImage.zip" `
    --exclude="OpenHands-Portable/images/agent-server-1.17.0-python.tar" `
    --exclude="OpenHands-Portable/.git" `
    --exclude="OpenHands-Portable/configs/config.toml" `
    --exclude="OpenHands-Portable/.claude" `
    --exclude="OpenHands-Portable/workspace/*" `
    "OpenHands-Portable"
```
