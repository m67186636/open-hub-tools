#!/bin/bash
# Gemini CLI Installer for Linux/macOS
# Usage: curl -fsSL https://yoursite.com/tools/gemini-cli/install.sh | bash

clear

echo ""
echo "========================================"
echo "   Gemini CLI 安装程序"
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

# 步骤 1: 检查并安装 Gemini CLI
echo "[1/2] 检查 Gemini CLI 安装状态..."

if command -v gemini &> /dev/null; then
    echo "Gemini CLI 已安装，跳过安装步骤。"
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
    
    echo "正在通过 npm 安装 Gemini CLI..."
    npm install -g @google/gemini-cli
    
    if [ $? -ne 0 ]; then
        echo "错误: 安装 Gemini CLI 失败。"
        exit 1
    fi
    echo "Gemini CLI 安装成功！"
fi

# 步骤 2: 配置环境变量
echo ""
echo "[2/2] 配置环境变量..."

BASE_URL="__API_BASE_URL__"

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
    exit 1
fi

# 移除旧配置
sed -i.bak '/GOOGLE_GEMINI_BASE_URL/d' "$SHELL_RC" 2>/dev/null || sed -i '' '/GOOGLE_GEMINI_BASE_URL/d' "$SHELL_RC"
sed -i.bak '/GEMINI_API_KEY/d' "$SHELL_RC" 2>/dev/null || sed -i '' '/GEMINI_API_KEY/d' "$SHELL_RC"

# 写入 BASE_URL
echo "export GOOGLE_GEMINI_BASE_URL=\"$BASE_URL\"" >> "$SHELL_RC"
echo "GOOGLE_GEMINI_BASE_URL 已设置为: $BASE_URL"

# 输入 API Key
echo ""
echo "请输入您的 API Key（以 sk- 开头）:"
echo "（获取地址: https://api.model-hub.cn 控制台 -> API令牌）"
read -p "API Key: " API_KEY

if [ -z "$API_KEY" ]; then
    echo "警告: 未提供 API Key，您可以稍后手动配置。"
    echo "  export GEMINI_API_KEY='your-api-key'"
else
    echo "export GEMINI_API_KEY=\"$API_KEY\"" >> "$SHELL_RC"
    echo "GEMINI_API_KEY 已写入: $SHELL_RC"
fi

# 完成
echo ""
echo "========================================"
echo "   安装完成！"
echo "========================================"
echo ""
echo "运行 gemini 命令即可开始使用。"
echo "注意: 请运行 'source $SHELL_RC' 或重启终端使环境变量生效。"
