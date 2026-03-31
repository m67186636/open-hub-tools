import type { Tool, ToolInfo } from './types'

const BASE_URL = import.meta.env.BASE_URL || '/'
const LOBEHUB_ICON_CDN = 'https://raw.githubusercontent.com/lobehub/lobe-icons/refs/heads/master/packages/static-png/light'

export async function loadTools(): Promise<Tool[]> {
  // Load the index of tool IDs
  const indexRes = await fetch(`${BASE_URL}tools/index.json`)
  const toolIds: string[] = await indexRes.json()

  // Load each tool's info
  const tools: Tool[] = await Promise.all(
    toolIds.map(async (id) => {
      const infoRes = await fetch(`${BASE_URL}tools/${id}/info.json`)
      const info: ToolInfo = await infoRes.json()
      
      // Use lobehub icon if specified, otherwise fallback to local logo
      const logoUrl = info.icon 
        ? `${LOBEHUB_ICON_CDN}/${info.icon}.png`
        : `${BASE_URL}tools/${id}/logo.svg`
      
      return {
        ...info,
        logoUrl,
        installPs1Url: `${BASE_URL}tools/${id}/install.ps1`,
        installShUrl: `${BASE_URL}tools/${id}/install.sh`,
      }
    })
  )

  return tools
}

export function getInstallCommand(tool: Tool, platform: 'windows' | 'unix', useModelHub: boolean = true): string {
  const baseUrl = window.location.origin + import.meta.env.BASE_URL
  
  if (useModelHub) {
    // 固定 model-hub 中转站，直接运行脚本
    if (platform === 'windows') {
      return `irm ${baseUrl}tools/${tool.id}/install.ps1 | iex`
    } else {
      return `curl -fsSL ${baseUrl}tools/${tool.id}/install.sh | sudo bash`
    }
  } else {
    // 交互询问模式：先下载脚本，手动运行时会询问 BASE_URL
    if (platform === 'windows') {
      return `irm ${baseUrl}tools/${tool.id}/install-custom.ps1 | iex`
    } else {
      return `curl -fsSL ${baseUrl}tools/${tool.id}/install-custom.sh | sudo bash`
    }
  }
}
