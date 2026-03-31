# Gemini CLI

Google 的开源 AI 代理，将 Gemini 的强大功能直接带入终端。

## 安装

### Windows (PowerShell)

以管理员身份运行 PowerShell，执行：

```powershell
irm https://yoursite.com/tools/gemini-cli/install.ps1 | iex
```

### Linux / macOS

```bash
sudo bash -c "$(curl -fsSL https://yoursite.com/tools/gemini-cli/install.sh)"
```

## 配置说明

安装脚本会自动配置以下环境变量：

```bash
export GOOGLE_GEMINI_BASE_URL="https://api.model-hub.cn"
export GEMINI_API_KEY="sk-xxx"
```

## 获取 API Key

1. 访问 https://api.model-hub.cn
2. 进入 **控制台 → API令牌**
3. 点击 **添加令牌**
4. 创建令牌并复制

## 使用

```bash
# 进入项目目录
cd your-project

# 启动 Gemini CLI
gemini

# 非交互模式
gemini -p "summarize README.md"

# 使用特定模型
gemini -m pro
```

## 主要功能

- 🧠 **强大的 Gemini 模型**：100 万 token 上下文窗口
- 🔧 **内置工具**：Google 搜索、文件操作、Shell 命令、网页抓取
- 🔌 **可扩展**：支持 MCP（模型上下文协议）
- 💻 **终端优先**：专为命令行开发者设计

## 相关链接

- [GitHub 仓库](https://github.com/google-gemini/gemini-cli)
- [官方文档](https://geminicli.com/docs/)
- [Model Hub](https://api.model-hub.cn)
