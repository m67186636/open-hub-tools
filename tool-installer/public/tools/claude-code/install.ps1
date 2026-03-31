# Claude Code Installer for Windows
# Usage: irm https://yoursite.com/tools/claude-code/install.ps1 | iex

Clear-Host
$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Claude Code 安装程序" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "错误: 请以管理员身份运行此脚本！" -ForegroundColor Red
    Write-Host "右键点击 PowerShell，选择「以管理员身份运行」后重试。" -ForegroundColor Yellow
    exit 1
}

# 步骤 1: 通过 winget 安装 Claude Code
Write-Host "[1/3] 检查 Claude Code 安装状态..." -ForegroundColor Cyan

$installed = winget list --id Anthropic.ClaudeCode 2>$null | Select-String "Anthropic.ClaudeCode"
if ($installed) {
    Write-Host "Claude Code 已安装，跳过安装步骤。" -ForegroundColor Green
} else {
    Write-Host "正在通过 winget 安装 Claude Code..." -ForegroundColor Cyan
    try {
        winget install Anthropic.ClaudeCode --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
            throw "winget 安装失败，退出码: $LASTEXITCODE"
        }
        Write-Host "Claude Code 安装成功！" -ForegroundColor Green
    } catch {
        Write-Host "错误: 安装 Claude Code 失败，请确保 winget 可用。" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}

# 步骤 2: 配置 API 端点
Write-Host "`n[2/3] 正在配置 API 端点..." -ForegroundColor Cyan
$baseUrl = "__API_BASE_URL__"
[Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $baseUrl, "Machine")
$env:ANTHROPIC_BASE_URL = $baseUrl
Write-Host "ANTHROPIC_BASE_URL 已设置为: $baseUrl" -ForegroundColor Green

# 步骤 3: 输入 API Key
Write-Host "`n[3/3] 配置 API Key..." -ForegroundColor Cyan
Write-Host "请输入您的 Anthropic API Key（以 sk- 开头）:" -ForegroundColor Yellow
$apiKey = Read-Host -Prompt "API Key"

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host "警告: 未提供 API Key，您可以稍后手动设置。" -ForegroundColor Yellow
    Write-Host "  [Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'your-api-key', 'Machine')" -ForegroundColor Gray
} else {
    [Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $apiKey, "Machine")
    $env:ANTHROPIC_AUTH_TOKEN = $apiKey
    Write-Host "ANTHROPIC_AUTH_TOKEN 配置成功！" -ForegroundColor Green
}

# 完成
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n运行 claude 命令即可开始使用。" -ForegroundColor White
Write-Host "注意: 可能需要重启终端才能使环境变量生效。" -ForegroundColor Yellow
