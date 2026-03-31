#!/bin/bash
# Claude Code Installer for Linux/macOS (Custom API URL)
# Usage: curl -fsSL https://yoursite.com/tools/claude-code/install-custom.sh | bash

clear

echo ""
echo "========================================"
echo "   Claude Code 安装程序 (自定义配置)"
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

# 步骤 1: 检查并安装 Claude Code
echo "[1/4] 检查 Claude Code 安装状态..."

if command -v claude &> /dev/null; then
    echo "Claude Code 已安装，跳过安装步骤。"
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
    
    echo "正在通过 npm 安装 Claude Code..."
    npm install -g @anthropic-ai/claude-code
    
    if [ $? -ne 0 ]; then
        echo "错误: 安装 Claude Code 失败。"
        exit 1
    fi
    echo "Claude Code 安装成功！"
fi

# 步骤 2: 询问 API Base URL
echo ""
echo "[2/4] 配置 API 端点..."
echo "请输入 API Base URL（留空则使用 Anthropic 官方）:"
echo "示例: https://api.anthropic.com 或 https://your-proxy.com"
read -p "API Base URL: " BASE_URL

# 检测 shell 配置文件
SHELL_RC=""
if [ -f "$REAL_HOME/.zshrc" ]; then
    SHELL_RC="$REAL_HOME/.zshrc"
elif [ -f "$REAL_HOME/.bashrc" ]; then
    SHELL_RC="$REAL_HOME/.bashrc"
elif [ -f "$REAL_HOME/.bash_profile" ]; then
    SHELL_RC="$REAL_HOME/.bash_profile"
fi

if [ -z "$SHELL_RC" ]; then
    echo "警告: 未找到 shell 配置文件，请手动设置环境变量。"
fi

# 步骤 3: 写入环境变量
echo ""
echo "[3/4] 正在配置环境变量..."

if [ -n "$SHELL_RC" ]; then
    # 移除旧的配置
    sed -i.bak '/ANTHROPIC_BASE_URL/d' "$SHELL_RC" 2>/dev/null || sed -i '' '/ANTHROPIC_BASE_URL/d' "$SHELL_RC"
    sed -i.bak '/ANTHROPIC_AUTH_TOKEN/d' "$SHELL_RC" 2>/dev/null || sed -i '' '/ANTHROPIC_AUTH_TOKEN/d' "$SHELL_RC"
    
    if [ -n "$BASE_URL" ]; then
        echo "export ANTHROPIC_BASE_URL=\"$BASE_URL\"" >> "$SHELL_RC"
        echo "ANTHROPIC_BASE_URL 已设置为: $BASE_URL"
    else
        echo "不设置 ANTHROPIC_BASE_URL，将使用官方默认地址。"
    fi
fi

# 步骤 4: 输入 API Key
echo ""
echo "[4/4] 配置 API Key..."
echo "请输入您的 Anthropic API Key:"
read -p "API Key: " API_KEY

if [ -z "$API_KEY" ]; then
    echo "警告: 未提供 API Key，您可以稍后手动设置。"
    echo "  export ANTHROPIC_AUTH_TOKEN='your-api-key'"
else
    if [ -n "$SHELL_RC" ]; then
        echo "export ANTHROPIC_AUTH_TOKEN=\"$API_KEY\"" >> "$SHELL_RC"
        echo "ANTHROPIC_AUTH_TOKEN 配置成功！"
    fi
fi

# 完成
echo ""
echo "========================================"
echo "   安装完成！"
echo "========================================"
echo ""
echo "运行 claude 命令即可开始使用。"
if [ -n "$SHELL_RC" ]; then
    echo "注意: 请运行 'source $SHELL_RC' 或重启终端使环境变量生效。"
fi
