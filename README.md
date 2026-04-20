# OpenHands Portable (离线整合包)

> 基于 OpenHands 项目制作的 Windows 离线便携式部署包

## 项目概述

OpenHands 是一个 AI 驱动的软件开发代理，支持多种 LLM 提供商（OpenAI、Anthropic、Local LLM 等）。

### 技术栈

| 组件 | 技术 | 版本 |
|------|------|------|
| Python 后端 | Python | 3.12 |
| 前端框架 | React Router v7 | 7.12+ |
| Node.js | Node.js | 22.x |
| Web 服务器 | Vite | 7.x |
| API 框架 | FastAPI + Uvicorn | - |

### 目录结构

```
OpenHands-Portable/
├── app/                      # 项目源码
│   ├── openhands/            # Python 后端
│   ├── frontend/             # React 前端
│   └── openhands-ui/         # UI 组件库
├── runtime/                   # 运行时环境
│   ├── python/               # Python 3.12 嵌入式
│   └── nodejs/               # Node.js 22.x
├── workspace/                 # 用户数据/工作区
├── scripts/                   # 启动脚本
├── configs/                  # 配置文件
└── README.md
```

## 快速开始

### 1. 配置

编辑 `configs/config.toml`，填入你的 LLM API Key：

```toml
[llm]
api_key = "sk-your-key-here"
model = "gpt-4o"
```

### 2. 启动

双击 `scripts/start.bat` 或在命令行中运行：

```batch
scripts\start.bat
```

### 3. 访问

启动后访问：
- 前端：http://localhost:3001
- 后端 API：http://127.0.0.1:3000

## 配置说明

### LLM 配置

#### OpenAI
```toml
[llm]
api_key = "sk-your-openai-key"
model = "gpt-4o"
```

#### Anthropic
```toml
[llm]
api_key = "sk-ant-your-key"
model = "claude-sonnet-4-20250514"
```

#### 本地 LLM (LM Studio / Ollama / vLLM)
```toml
[llm]
api_key = "not-needed"
model = "local-model"
base_url = "http://localhost:1234/v1"
```

## 已知问题

### 依赖安装

首次启动时，如果提示缺少模块，可能需要手动安装：

```batch
runtime\python\python.exe -m pip install --target=runtime\python\Lib\site-packages <module-name>
```

### 浏览器自动化

如果使用浏览器自动化功能，需要安装 Playwright 浏览器：

```batch
runtime\python\python.exe -m playwright install chromium
```

## 技术支持

- 官方文档：https://docs.openhands.dev
- GitHub：https://github.com/OpenHands/OpenHands
- 问题反馈：https://github.com/OpenHands/OpenHands/issues

## 许可证

OpenHands 采用 MIT 许可证，详见 LICENSE 文件。
