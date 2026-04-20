# OpenHands Portable (Windows 离线整合包)

> 基于 [OpenHands](https://github.com/All-Hands-AI/OpenHands) 制作的 Windows 离线便携式部署包，无需安装 Python/Node.js，开箱即用。
>
> 下载链接：https://pan.quark.cn/s/bc84a34d1a33

## 特性

- **完全离线** — 内置 Python 3.12 + Node.js 22.x 嵌入式运行时
- **零配置启动** — 双击 `start.bat` 即可运行
- **Docker 集成** — 自动检测 Docker Desktop，自动拉取/加载 agent-server 镜像
- **镜像加速** — 内置国内 Docker 镜像源配置脚本
- **进程管理** — 一键停止所有服务 (`stop.bat`)
- **数据隔离** — 用户数据、配置、源码分层管理

## 目录结构

```
OpenHands-Portable/
├── app/                      # OpenHands 源码（可更新替换）
│   ├── openhands/            # Python 后端
│   ├── frontend/             # React 前端
│   └── config.template.toml  # 配置模板
├── runtime/                  # 嵌入式运行时（首次解压后存在）
│   ├── python/               # Python 3.12 + pip 依赖
│   └── nodejs/               # Node.js 22.x
├── workspace/                # 用户数据 / 工作区
├── configs/                  # 用户配置
│   └── config.toml           # LLM API Key 等（首次手动创建）
├── scripts/                  # 工具脚本
│   ├── configure-docker-mirror.bat  # Docker 镜像加速
│   ├── export-images.bat            # 导出 Docker 镜像
│   ├── install-deps.bat             # 安装缺失依赖
│   └── stop.ps1                     # 进程清理
├── skills/                   # 使用指南文档
│   ├── openhands-docker-export.md
│   ├── openhands-push.md
│   └── openhands-update.md
├── start.bat                 # 一键启动
├── stop.bat                  # 一键停止
└── README.md
```

> **注意**：`runtime/` 和 `images/` 体积较大（约 2.5GB），不包含在 Git 源码中。首次使用需从 Release 下载完整包。

## 快速开始

### 1. 获取完整包

从 [Releases](https://github.com/360PB/OpenHands-Portable/releases) 下载最新完整压缩包并解压。

### 2. 配置 LLM

复制配置模板：

```batch
copy configs\config.template.toml configs\config.toml
```

编辑 `configs/config.toml`，填入你的 API Key：

```toml
[llm]
api_key = "sk-your-key-here"
model = "gpt-4o"
base_url = "https://api.openai.com/v1"
```

> 支持 OpenAI、Anthropic、MiniMax、本地 LLM（LM Studio / Ollama）等任何兼容 OpenAI API 格式的服务商。

### 3. 启动

双击 `start.bat`，脚本会：

1. 检查 Docker Desktop 是否运行
2. **优先**从 `images/*.tar` 加载镜像（离线场景）
3. 如无 tar，检查本地是否已有镜像
4. 如无镜像且联网，自动 `docker pull`
5. 启动后端 (port 3000) 和前端 (port 3001)

访问 http://localhost:3001 即可使用。

### 4. 停止

双击 `stop.bat` 或运行：

```batch
stop.bat
```

## Docker 配置（国内用户）

如果 `docker pull` 速度慢，配置国内镜像源：

```batch
scripts\configure-docker-mirror.bat
```

然后重启 Docker Desktop，再次运行 `start.bat`。

## 离线使用

### 导出镜像（联网机器）

在一台已下载好镜像的机器上：

```batch
scripts\export-images.bat
```

导出的 `images/agent-server-1.17.0-python.tar` 可拷贝到离线机器。

### 加载镜像（离线机器）

把 `images/` 目录复制到离线机器的整合包根目录，`start.bat` 会自动加载。

## 常见问题

### 端口被占用 (WinError 10048)

```batch
stop.bat
```

然后重新启动。

### ModuleNotFoundError

```batch
scripts\install-deps.bat <缺失的包名>
```

或手动：

```batch
runtime\python\python.exe -m pip install <包名> --target=runtime\python\Lib\site-packages
```

### 浏览器自动化 (Playwright)

如需浏览器自动化功能：

```batch
runtime\python\python.exe -m playwright install chromium
```

## 更新源码

参考 `skills/openhands-update.md` 或使用以下快速命令：

```batch
# 停止服务
stop.bat

# 备份当前源码
move app app-backup

# 替换为新版本源码（手动复制或 git clone）
# ...

# 重启
start.bat
```

## 技术栈

| 组件 | 技术 | 版本 |
|------|------|------|
| Python 后端 | Python | 3.12 |
| 前端框架 | React Router v7 | 7.12+ |
| Node.js | Node.js | 22.x |
| API 框架 | FastAPI + Uvicorn | - |
| Docker 镜像 | agent-server | 1.17.0-python |

## 相关链接

- OpenHands 官方文档：https://docs.openhands.dev
- OpenHands GitHub：https://github.com/All-Hands-AI/OpenHands
- 本仓库 Issues：https://github.com/360PB/OpenHands-Portable/issues

## 许可证

OpenHands 采用 MIT 许可证。
