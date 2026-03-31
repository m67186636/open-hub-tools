# 工具目录规范

本目录用于存放所有可安装工具的配置和脚本。

## 目录结构

```
tools/
├── index.json              # 工具ID列表
├── README.md               # 本文档
├── {tool-id}/              # 每个工具一个目录
│   ├── info.json           # 工具元信息（必需）
│   ├── install.ps1         # Windows 安装脚本（必需）
│   ├── install.sh          # Linux/macOS 安装脚本（必需）
│   └── logo.svg            # 本地图标（可选，有 icon 字段时不需要）
```

## 添加新工具步骤

1. 在 `index.json` 中添加工具 ID
2. 创建 `{tool-id}/` 目录
3. 编写 `info.json`、`install.ps1`、`install.sh`

---

## info.json 规范

```json
{
  "id": "tool-id",
  "name": "工具显示名称",
  "vendor": "厂商名称",
  "icon": "lobehub-icon-name",
  "description": "工具描述",
  "stars": 12345,
  "downloads": 67890,
  "links": [
    { "type": "website", "label": "官网", "url": "https://..." },
    { "type": "repo", "label": "GitHub", "url": "https://github.com/..." },
    { "type": "docs", "label": "文档", "url": "https://..." }
  ],
  "tags": ["AI", "CLI", "Development"]
}
```

### 字段说明

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | string | ✅ | 工具唯一标识，与目录名一致，使用 kebab-case |
| `name` | string | ✅ | 工具显示名称 |
| `vendor` | string | ✅ | 厂商/公司名称 |
| `icon` | string | ❌ | [lobehub/lobe-icons](https://lobehub.com/icons) 图标名称 |
| `description` | string | ✅ | 工具简介 |
| `stars` | number | ❌ | GitHub Star 数（可手动填写） |
| `downloads` | number | ❌ | 下载量 |
| `links` | array | ✅ | 相关链接列表 |
| `tags` | array | ✅ | 标签，用于搜索过滤 |

### links.type 可选值

- `website` - 官方网站
- `repo` - 代码仓库
- `docs` - 文档
- `other` - 其他

### icon 字段

使用 [lobehub/lobe-icons](https://lobehub.com/icons) CDN 图标。

常用图标名称：
- `openai` - OpenAI
- `anthropic` - Anthropic
- `gemini-color` - Google Gemini
- `github` - GitHub
- `microsoft` - Microsoft

如不指定 `icon`，系统会回退到 `{tool-id}/logo.svg`。

---

## install.ps1 规范（Windows）

### 模板

```powershell
# {Tool Name} Installer for Windows
# Usage: irm https://yoursite.com/tools/{tool-id}/install.ps1 | iex

Clear-Host
$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   {Tool Name} 安装程序" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "错误: 请以管理员身份运行此脚本！" -ForegroundColor Red
    Write-Host "右键点击 PowerShell，选择「以管理员身份运行」后重试。" -ForegroundColor Yellow
    exit 1
}

# 检查是否已安装
Write-Host "[1/N] 检查安装状态..." -ForegroundColor Cyan
$installed = winget list --id {Package.Id} 2>$null | Select-String "{Package.Id}"
if ($installed) {
    Write-Host "已安装，跳过。" -ForegroundColor Green
} else {
    Write-Host "正在安装..." -ForegroundColor Cyan
    winget install {Package.Id} --accept-source-agreements --accept-package-agreements
}

# 配置环境变量（如需要）
Write-Host "`n[2/N] 配置环境变量..." -ForegroundColor Cyan
[Environment]::SetEnvironmentVariable("VAR_NAME", "value", "Machine")

# 交互输入（如需要）
Write-Host "请输入 API Key:" -ForegroundColor Yellow
$apiKey = Read-Host -Prompt "API Key"
if (-not [string]::IsNullOrWhiteSpace($apiKey)) {
    [Environment]::SetEnvironmentVariable("API_KEY", $apiKey, "Machine")
}

# 完成
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
```

### 要求

1. **清屏**: 脚本开头使用 `Clear-Host`
2. **管理员权限**: 必须检查，非管理员直接退出
3. **检查依赖项**: 判断前置条件，比如NPM依赖于NodeJS,那就要判断NodeJS是否安装,没有的话优先从winget安装,
4. **跳过已安装**: 检查是否已安装，已安装则跳过
5. **中文提示**: 所有用户可见文本使用简体中文
6. **错误处理**: 使用 `$ErrorActionPreference = "Stop"` 和 try-catch
7. **环境变量**: 使用 `[Environment]::SetEnvironmentVariable(..., "Machine")`

---

## install.sh 规范（Linux/macOS）

### 模板

```bash
#!/bin/bash
# {Tool Name} Installer for Linux/macOS
# Usage: curl -fsSL https://yoursite.com/tools/{tool-id}/install.sh | bash

clear

echo ""
echo "========================================"
echo "   {Tool Name} 安装程序"
echo "========================================"
echo ""

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "错误: 请以 root 权限运行此脚本！"
    exit 1
fi

# 检查是否已安装
echo "[1/N] 检查安装状态..."
if command -v {tool-command} &> /dev/null; then
    echo "已安装，跳过。"
else
    # 检查依赖（如 npm）
    if ! command -v npm &> /dev/null; then
        echo "正在安装 Node.js..."
        # 根据系统安装...
    fi
    
    echo "正在安装..."
    npm install -g {package-name}
fi

# 配置环境变量
echo "[2/N] 配置环境变量..."
SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

echo 'export VAR_NAME="value"' >> "$SHELL_RC"

# 交互输入（如需要）
echo "请输入 API Key:"
read -p "API Key: " API_KEY
if [ -n "$API_KEY" ]; then
    echo "export API_KEY=\"$API_KEY\"" >> "$SHELL_RC"
fi

# 完成
echo ""
echo "========================================"
echo "   安装完成！"
echo "========================================"
```

### 要求

1. **清屏**: 脚本开头使用 `clear`
2. **root 权限**: 必须检查，非 root 直接退出
3. **检查依赖项**: 判断前置条件，比如NPM依赖于NodeJS,那就要判断NodeJS是否安装,没有的话优先从apt-get安装,
4. **跳过已安装**: 使用 `command -v` 检查
5. **自动安装依赖**: 如依赖 npm，自动安装 Node.js
6. **中文提示**: 所有用户可见文本使用简体中文
7. **换行符**: 必须使用 LF（Unix 格式），不能用 CRLF

### 换行符转换

Windows 上编辑后需转换换行符：

```powershell
$content = Get-Content "install.sh" -Raw
$content = $content -replace "`r`n", "`n"
[System.IO.File]::WriteAllText("install.sh", $content, [System.Text.UTF8Encoding]::new($false))
```

---

## 注意事项

1. **ID 命名**: 使用小写 kebab-case，如 `claude-code`、`codex-cli`
2. **测试**: 新脚本必须在目标平台测试后再提交
3. **幂等性**: 脚本应可重复执行，已安装时跳过而非报错
4. **安全性**: 不要在脚本中硬编码敏感信息
5. **离线场景**: 考虑网络不通时的错误提示
