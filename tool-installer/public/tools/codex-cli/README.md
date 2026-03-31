# Codex CLI

OpenAI 的轻量级编码代理，运行在终端中。

## 安装

### Windows (PowerShell)

以管理员身份运行 PowerShell，执行：

```powershell
irm https://yoursite.com/tools/codex-cli/install.ps1 | iex
```

### Linux / macOS

```bash
sudo bash -c "$(curl -fsSL https://yoursite.com/tools/codex-cli/install.sh)"
```

## 配置说明

安装脚本会自动创建以下配置文件：

### ~/.codex/config.toml

```toml
model_provider = "model_hub"
model = "gpt-5.4"
model_reasoning_effort = "high"
disable_response_storage = true
preferred_auth_method = "apikey"

[model_providers.model_hub]
name = "model_hub"
base_url = "https://api.model-hub.cn/v1"
wire_api = "responses"
```

### ~/.codex/auth.json

```json
{"OPENAI_API_KEY": "sk-xxx"}
```

## 获取 API Key

1. 访问 https://api.model-hub.cn
2. 进入 **控制台 → API令牌**
3. 点击 **添加令牌**
4. 令牌分组选择：**codex专属**（必须选择此分组）
5. 额度建议设置为 **无限额度**

## 使用

```bash
# 进入项目目录
cd your-project

# 启动 Codex
codex
```

## 相关链接

- [GitHub 仓库](https://github.com/openai/codex)
- [官方文档](https://developers.openai.com/codex)
- [Model Hub](https://api.model-hub.cn)
