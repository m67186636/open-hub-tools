# 部署指南

本项目推荐使用 **GitHub + Cloudflare Pages + Workers** 进行部署，适合中国大陆用户访问。

## 架构概览

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   GitHub    │────▶│ Cloudflare Pages │────▶│ 静态网站 (dist) │
│  (源码仓库)  │     │   (自动构建部署)   │     │                 │
└─────────────┘     └──────────────────┘     └─────────────────┘
                              │
                              ▼
                    ┌──────────────────┐     ┌─────────────────┐
                    │ Cloudflare Workers│────▶│   KV 存储       │
                    │   (统计 API)      │     │ (stars/downloads)│
                    └──────────────────┘     └─────────────────┘
```

## 1. Cloudflare Pages 部署

### 1.1 连接 GitHub 仓库

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 进入 **Workers & Pages** → **Create** → **Pages**
3. 选择 **Connect to Git** → 授权 GitHub → 选择本仓库

### 1.2 构建配置

| 配置项 | 值 |
|--------|-----|
| Framework preset | None |
| Build command | `pnpm build` |
| Build output directory | `dist` |
| Root directory | `tool-installer` |
| Node.js version | `20` 或更高 |

### 1.3 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `VITE_API_BASE_URL` | `https://api.model-hub.cn` | API 服务地址，构建时替换脚本中的占位符 |
| `VITE_BAIDU_ANALYTICS_ID` | _（空）_ | 百度统计站点 ID，不设置则不启用统计 |

> **注意**：
> - 如果不设置 `VITE_API_BASE_URL`，将使用默认值 `https://api.model-hub.cn`
> - 如果不设置 `VITE_BAIDU_ANALYTICS_ID`，不会插入百度统计代码

**百度统计配置**：
1. 登录 [百度统计](https://tongji.baidu.com/)
2. 创建新站点，获取统计代码中的 ID（`hm.js?` 后的字符串）
3. 在 Cloudflare Pages 环境变量中设置 `VITE_BAIDU_ANALYTICS_ID=你的统计ID`

### 1.4 自动部署

配置完成后，每次推送到 `main` 分支都会自动触发构建和部署。

---

## 2. 自定义域名（可选）

1. 在 Cloudflare Pages 项目设置中点击 **Custom domains**
2. 添加你的域名（如 `tools.example.com`）
3. 按提示添加 DNS 记录（CNAME 指向 `*.pages.dev`）

---

## 3. Cloudflare Workers + KV（统计功能）

### 3.1 创建 KV 命名空间

```bash
# 安装 wrangler CLI
npm install -g wrangler

# 登录 Cloudflare
wrangler login

# 创建 KV 命名空间
wrangler kv:namespace create "TOOL_STATS"
```

记录返回的 `id`，后面要用。

### 3.2 创建 Worker

创建 `worker/stats-api.js`：

```javascript
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS 头
    const headers = {
      'Access-Control-Allow-Origin': '*',
      'Content-Type': 'application/json',
    };

    // GET /stats/:toolId - 获取统计
    if (request.method === 'GET' && path.startsWith('/stats/')) {
      const toolId = path.split('/')[2];
      const stats = await env.TOOL_STATS.get(toolId, 'json') || { stars: 0, downloads: 0 };
      return new Response(JSON.stringify(stats), { headers });
    }

    // POST /stats/:toolId/download - 记录下载
    if (request.method === 'POST' && path.includes('/download')) {
      const toolId = path.split('/')[2];
      const stats = await env.TOOL_STATS.get(toolId, 'json') || { stars: 0, downloads: 0 };
      stats.downloads++;
      await env.TOOL_STATS.put(toolId, JSON.stringify(stats));
      return new Response(JSON.stringify(stats), { headers });
    }

    // POST /stats/:toolId/star - 记录点赞
    if (request.method === 'POST' && path.includes('/star')) {
      const toolId = path.split('/')[2];
      const stats = await env.TOOL_STATS.get(toolId, 'json') || { stars: 0, downloads: 0 };
      stats.stars++;
      await env.TOOL_STATS.put(toolId, JSON.stringify(stats));
      return new Response(JSON.stringify(stats), { headers });
    }

    return new Response('Not Found', { status: 404 });
  },
};
```

### 3.3 配置 wrangler.toml

```toml
name = "tool-stats-api"
main = "stats-api.js"
compatibility_date = "2024-01-01"

[[kv_namespaces]]
binding = "TOOL_STATS"
id = "<你的 KV 命名空间 ID>"
```

### 3.4 部署 Worker

```bash
wrangler deploy
```

部署后可通过 `https://tool-stats-api.<your-subdomain>.workers.dev` 访问 API。

---

## 4. 本地开发

```bash
cd tool-installer
pnpm install
pnpm dev
```

访问 `http://localhost:5173` 预览。

---

## 5. 构建流程说明

`pnpm build` 执行以下步骤：

1. `vue-tsc -b` - TypeScript 类型检查
2. `vite build` - 打包静态资源到 `dist/`
3. `node replace-env.js` - 环境变量替换：
   - 将脚本中的 `__API_BASE_URL__` 替换为环境变量值或默认值
   - 将 `index.html` 中的百度统计占位符替换为实际代码（如已配置）

---

## 常见问题

**Q: 为什么选择 Cloudflare Pages？**

A: 相比 GitHub Pages 和 Vercel，Cloudflare 在中国大陆的访问速度更稳定，且免费额度充足。

**Q: 如何修改 API 地址？**

A: 在 Cloudflare Pages 环境变量中设置 `VITE_API_BASE_URL` 即可，无需改代码。
