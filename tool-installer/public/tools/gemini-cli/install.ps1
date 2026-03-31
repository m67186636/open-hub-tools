# Gemini CLI Installer for Windows
# Usage: irm https://yoursite.com/tools/gemini-cli/install.ps1 | iex

Clear-Host
$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Gemini CLI 安装程序" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "错误: 请以管理员身份运行此脚本！" -ForegroundColor Red
    Write-Host "右键点击 PowerShell，选择「以管理员身份运行」后重试。" -ForegroundColor Yellow
    exit 1
}

# 步骤 1: 检查并安装 Gemini CLI
Write-Host "[1/2] 检查 Gemini CLI 安装状态..." -ForegroundColor Cyan

if (Get-Command gemini -ErrorAction SilentlyContinue) {
    Write-Host "Gemini CLI 已安装，跳过安装步骤。" -ForegroundColor Green
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
    
    Write-Host "正在通过 npm 安装 Gemini CLI..." -ForegroundColor Cyan
    npm install -g @google/gemini-cli
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "错误: 安装 Gemini CLI 失败。" -ForegroundColor Red
        exit 1
    }
    Write-Host "Gemini CLI 安装成功！" -ForegroundColor Green
}

# 步骤 2: 配置环境变量
Write-Host "`n[2/2] 配置环境变量..." -ForegroundColor Cyan

$baseUrl = "__API_BASE_URL__"

# 设置 GOOGLE_GEMINI_BASE_URL
[Environment]::SetEnvironmentVariable("GOOGLE_GEMINI_BASE_URL", $baseUrl, "Machine")
$env:GOOGLE_GEMINI_BASE_URL = $baseUrl
Write-Host "GOOGLE_GEMINI_BASE_URL 已设置为: $baseUrl" -ForegroundColor Green

# 输入 API Key
Write-Host "`n请输入您的 API Key（以 sk- 开头）:" -ForegroundColor Yellow
Write-Host "（获取地址: https://api.model-hub.cn 控制台 -> API令牌）" -ForegroundColor Gray
$apiKey = Read-Host -Prompt "API Key"

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host "警告: 未提供 API Key，您可以稍后手动配置。" -ForegroundColor Yellow
} else {
    [Environment]::SetEnvironmentVariable("GEMINI_API_KEY", $apiKey, "Machine")
    $env:GEMINI_API_KEY = $apiKey
    Write-Host "GEMINI_API_KEY 配置成功！" -ForegroundColor Green
}

# 完成
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n运行 gemini 命令即可开始使用。" -ForegroundColor White
Write-Host "注意: 可能需要重启终端使环境变量生效。" -ForegroundColor Yellow
