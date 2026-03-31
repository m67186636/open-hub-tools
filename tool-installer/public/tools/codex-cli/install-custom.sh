#!/bin/bash
# Codex CLI Installer for Linux/macOS (Custom API URL)
# Usage: curl -fsSL https://yoursite.com/tools/codex-cli/install-custom.sh | bash

clear

echo ""
echo "========================================"
echo "   Codex CLI 安装程序 (自定义配置)"
echo "========================================"
echo ""

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "错误: 请以 root 权限运行此脚本！"
    echo "使用: sudo bash -c \"\$(curl -fsSL <script-url>)\""
    exit 1
fi

# 获取实际用户（非 root）
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")

# 步骤 1: 检查并安装 Codex CLI
echo "[1/4] 检查 Codex CLI 安装状态..."

if command -v codex &> /dev/null; then
    echo "Codex CLI 已安装，跳过安装步骤。"
else
    # 检查 npm，没有则自动安装 Node.js
    if ! command -v npm &> /dev/null; then
        echo "npm 未安装，正在自动安装 Node.js..."
        
        # 检测系统和包管理器
        if [ -f /etc/debian_version ]; then
            # Debian/Ubuntu
            curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
            apt-get install -y nodejs
        elif [ -f /etc/redhat-release ]; then
            # RHEL/CentOS/Fedora
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -
            yum install -y nodejs || dnf install -y nodejs
        elif [ "$(uname)" == "Darwin" ]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install node
            else
                echo "错误: 请先安装 Homebrew，然后重试。"
                echo "访问: https://brew.sh/"
                exit 1
            fi
        else
            echo "错误: 无法自动安装 Node.js，请手动安装。"
            echo "访问: https://nodejs.org/"
            exit 1
        fi
        
        # 验证安装
        if ! command -v npm &> /dev/null; then
            echo "错误: Node.js 安装失败。"
            exit 1
        fi
        echo "Node.js 安装成功！"
    fi
    
    echo "正在通过 npm 安装 Codex CLI..."
    npm install -g @openai/codex
    
    if [ $? -ne 0 ]; then
        echo "错误: 安装 Codex CLI 失败。"
        exit 1
    fi
    echo "Codex CLI 安装成功！"
fi

# 步骤 2: 询问 API Base URL
echo ""
echo "[2/4] 配置 API 端点..."
echo "请输入 API Base URL（留空则使用 OpenAI 官方）:"
echo "示例: https://api.openai.com 或 https://your-proxy.com"
read -p "API Base URL: " BASE_URL

if [ -z "$BASE_URL" ]; then
    BASE_URL="https://api.openai.com"
    echo "使用默认地址: $BASE_URL"
fi

# 步骤 3: 配置 config.toml
echo ""
echo "[3/4] 正在写入配置文件..."

CODEX_HOME="$REAL_HOME/.codex"
CONFIG_FILE="$CODEX_HOME/config.toml"

# 创建配置目录
mkdir -p "$CODEX_HOME"
chown "$REAL_USER" "$CODEX_HOME"

# 写入 config.toml
cat > "$CONFIG_FILE" << EOF
model_provider = "custom"
model = "gpt-4o"
model_reasoning_effort = "high"
disable_response_storage = true
preferred_auth_method = "apikey"

[model_providers.custom]
name = "custom"
base_url = "$BASE_URL/v1"
wire_api = "responses"
EOF

chown "$REAL_USER" "$CONFIG_FILE"
echo "配置文件已写入: $CONFIG_FILE"

# 步骤 4: 输入 API Key
echo ""
echo "[4/4] 配置 API Key..."
echo "请输入您的 API Key:"
read -p "API Key: " API_KEY

if [ -z "$API_KEY" ]; then
    echo "警告: 未提供 API Key，您可以稍后手动配置。"
else
    # 写入 auth.json
    AUTH_FILE="$CODEX_HOME/auth.json"
    cat > "$AUTH_FILE" << EOF
{"OPENAI_API_KEY": "$API_KEY"}
EOF
    chown "$REAL_USER" "$AUTH_FILE"
    chmod 600 "$AUTH_FILE"
    echo "API Key 已写入: $AUTH_FILE"
fi

# 完成
echo ""
echo "========================================"
echo "   安装完成！"
echo "========================================"
echo ""
echo "运行 codex 命令即可开始使用。"
