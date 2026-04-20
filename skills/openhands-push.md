# OpenHands 整合包 GitHub 推送 Skill

> 指导 AI 如何安全地将 OpenHands 整合包的修改推送到 GitHub 仓库。

## 适用场景

- 修改了源码、脚本或配置，需要同步到 GitHub
- 更新了 README 或文档
- 修复了 bug 需要发布新版本

## 推送前检查清单

| # | 检查项 | 说明 |
|---|--------|------|
| 1 | **是否有敏感信息泄露** | config.toml、.env 等是否被意外提交 |
| 2 | **大文件是否被排除** | runtime/、images/ 是否在 .gitignore 中 |
| 3 | **node_modules 是否被排除** | 前端依赖不应提交 |
| 4 | **__pycache__ 是否已清理** | Python 缓存不应提交 |

## 快速推送

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable

# 1. 查看变更
git status

# 2. 添加所有变更
git add .

# 3. 提交
git commit -m "描述本次修改"

# 4. 推送
git push origin main
```

## 清洁推送（推荐）

如果长时间未推送，或不确定是否有脏文件：

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable

# 1. 检查是否有 config.toml 被追踪（敏感信息）
git ls-files | Select-String "config\.toml"
# 如果输出包含 configs/config.toml 或 app/config.toml → 危险！

# 2. 清理 Python 缓存
Get-ChildItem -Recurse -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force

# 3. 确保 app/config.toml 不存在（运行时生成的副本）
if (Test-Path "app\config.toml") { Remove-Item "app\config.toml" }

# 4. 查看变更统计
git diff --stat

# 5. 提交并推送
git add .
git commit -m "fix: 修复xxx问题`n`n- 修改了xxx`n- 更新了xxx"
git push origin main
```

## 首次推送（新仓库）

```powershell
cd E:\OpenHands-Portable\OpenHands-Portable

# 初始化（如未初始化）
git init
git config user.email "you@example.com"
git config user.name "Your Name"

# 添加远程仓库
git remote add origin https://github.com/360PB/OpenHands-Portable.git

# 创建 .gitignore（如不存在）
# 内容参考已有的 .gitignore

# 提交并推送
git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main
```

## 强制推送（谨慎使用）

如果本地历史与远程冲突，且确定本地正确：

```powershell
git push origin main --force
```

> ⚠️ 强制推送会覆盖远程历史，仅在你独自维护仓库时使用。

## 排除规则速查

`.gitignore` 必须包含以下条目：

```gitignore
# 用户数据 & 密钥
workspace/
configs/config.toml
*.env

# 大体积运行时（Release 包单独分发）
runtime/
images/

# 前端依赖
node_modules/

# Python 缓存
__pycache__/
*.pyc

# IDE
.claude/
.vscode/
.idea/

# 运行时生成
app/config.toml
```

## 常见问题

### Q: 推送被拒绝 "Updates were rejected"

**原因**：远程仓库有新的提交，本地落后

**解决**：
```powershell
git pull origin main --rebase
git push origin main
```

### Q: 推送时提示 "file too large" (100MB+)

**原因**：某个文件超过 GitHub 单文件限制

**解决**：
```powershell
# 查找大文件
git ls-files | ForEach-Object { 
    $size = (Get-Item $_ -ErrorAction SilentlyContinue).Length 
    if ($size -gt 50MB) { "{0:N2} MB  $_" -f ($size/1MB) }
}

# 将该文件路径加入 .gitignore，然后撤销追踪
git rm --cached <大文件路径>
git commit -m "移除大文件"
git push origin main
```

### Q: 不小心提交了 config.toml（含 API Key）

**解决**：
```powershell
# 从 Git 历史中移除（但保留本地文件）
git rm --cached configs/config.toml
# 或 app/config.toml

# 加入 .gitignore
echo "configs/config.toml" >> .gitignore
echo "app/config.toml" >> .gitignore

# 提交修正
git add .gitignore
git commit -m "移除敏感配置文件"
git push origin main

# 如果已推送到远程，需要修改历史（更复杂）
# 建议直接修改 API Key（在服务商后台撤销旧 Key）
```

### Q: 推送成功但 GitHub 不显示最新代码

**原因**：可能推送到了错误的分支

**解决**：
```powershell
git branch              # 查看当前分支
git log --oneline -3    # 查看最新提交
git push origin main    # 确保推送到 main 分支
```
