export interface ToolLink {
  type: 'website' | 'docs' | 'repo' | 'other'
  label: string
  url: string
}

export interface ToolInfo {
  id: string
  name: string
  vendor: string
  description: string
  links: ToolLink[]
  tags: string[]
  stars?: number      // GitHub stars / popularity
  downloads?: number  // Download count
  icon?: string       // lobehub icon name (e.g., 'openai', 'anthropic', 'google')
}

export interface Tool extends ToolInfo {
  logoUrl: string
  installPs1Url: string
  installShUrl: string
}
