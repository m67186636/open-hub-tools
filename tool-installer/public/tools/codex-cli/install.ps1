# Codex CLI Installer for Windows
# Usage: irm https://yoursite.com/tools/codex-cli/install.ps1 | iex

Clear-Host
$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Codex CLI 安装程序" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "错误: 请以管理员身份运行此脚本！" -ForegroundColor Red
    Write-Host "右键点击 PowerShell，选择「以管理员身份运行」后重试。" -ForegroundColor Yellow
    exit 1
}

# 步骤 1: 检查并安装 Codex CLI
Write-Host "[1/3] 检查 Codex CLI 安装状态..." -ForegroundColor Cyan

if (Get-Command codex -ErrorAction SilentlyContinue) {
    Write-Host "Codex CLI 已安装，跳过安装步骤。" -ForegroundColor Green
} else {
    # 检查 npm，没有则自动安装 Node.js
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm 未安装，正在自动安装 Node.js..." -ForegroundColor Cyan
        
        # 检查 winget
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "错误: winget 不可用，请手动安装 Node.js。" -ForegroundColor Red
            Write-Host "下载地址: https://nodejs.org/" -ForegroundColor Yellow
            exit 1
        }
        
        winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "错误: Node.js 安装失败。" -ForegroundColor Red
            exit 1
        }
        
        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        Write-Host "Node.js 安装成功！" -ForegroundColor Green
    }
    
    Write-Host "正在通过 npm 安装 Codex CLI..." -ForegroundColor Cyan
    npm install -g @openai/codex
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 安装 Codex CLI 失败。" -ForegroundColor Red
        exit 1
    }
    Write-Host "Codex CLI 安装成功！" -ForegroundColor Green
}

# 步骤 2: 配置 config.toml
Write-Host "`n[2/3] 正在写入配置文件..." -ForegroundColor Cyan

$codexHome = "$env:USERPROFILE\.codex"
$configFile = "$codexHome\config.toml"

# 创建配置目录
if (-not (Test-Path $codexHome)) {
    New-Item -ItemType Directory -Path $codexHome -Force | Out-Null
}

# 写入 config.toml
$configContent = @"
model_provider = "model_hub"
model = "gpt-5.4"
model_reasoning_effort = "high"
disable_response_storage = true
preferred_auth_method = "apikey"

[model_providers.model_hub]
name = "model_hub"
base_url = "__API_BASE_URL__/v1"
wire_api = "responses"
"@

Set-Content -Path $configFile -Value $configContent -Encoding UTF8
Write-Host "配置文件已写入: $configFile" -ForegroundColor Green

# 步骤 3: 输入 API Key
Write-Host "`n[3/3] 配置 API Key..." -ForegroundColor Cyan
Write-Host "请输入您的 API Key（以 sk- 开头）:" -ForegroundColor Yellow
Write-Host "（获取地址: https://api.model-hub.cn 控制台 -> API令牌 -> 选择 codex专属 分组）" -ForegroundColor Gray
$apiKey = Read-Host -Prompt "API Key"

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host "警告: 未提供 API Key，您可以稍后手动配置。" -ForegroundColor Yellow
} else {
    # 写入 auth.json
    $authFile = "$codexHome\auth.json"
    $authContent = "{`"OPENAI_API_KEY`": `"$apiKey`"}"
    Set-Content -Path $authFile -Value $authContent -Encoding UTF8
    Write-Host "API Key 已写入: $authFile" -ForegroundColor Green
}

# 完成
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n运行 codex 命令即可开始使用。" -ForegroundColor White
Write-Host "注意: 可能需要重启终端。" -ForegroundColor Yellow
