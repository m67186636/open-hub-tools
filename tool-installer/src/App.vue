<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import ToolCard from './components/ToolCard.vue'
import { loadTools } from './api'
import type { Tool } from './types'

const tools = ref<Tool[]>([])
const loading = ref(true)
const error = ref('')
const searchQuery = ref('')

const filteredTools = computed(() => {
  if (!searchQuery.value.trim()) return tools.value
  
  const query = searchQuery.value.toLowerCase()
  return tools.value.filter(tool => 
    tool.name.toLowerCase().includes(query) ||
    tool.vendor.toLowerCase().includes(query) ||
    tool.description.toLowerCase().includes(query) ||
    tool.tags.some(tag => tag.toLowerCase().includes(query))
  )
})

onMounted(async () => {
  try {
    tools.value = await loadTools()
  } catch (e) {
    error.value = 'Failed to load tools'
    console.error(e)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="app">
    <header class="header">
      <h1>🛠️ Tool Installer</h1>
      <p>One-click install scripts for developer tools</p>
      
      <div class="search-box">
        <input 
          v-model="searchQuery"
          type="text" 
          placeholder="Search tools by name, vendor, or tag..."
          class="search-input"
        />
        <span class="search-icon">🔍</span>
      </div>
    </header>

    <main class="main">
      <div v-if="loading" class="loading">Loading tools...</div>
      <div v-else-if="error" class="error">{{ error }}</div>
      <template v-else>
        <div class="results-info" v-if="searchQuery">
          Found {{ filteredTools.length }} tool(s)
        </div>
        <div v-if="filteredTools.length === 0" class="no-results">
          No tools found matching "{{ searchQuery }}"
        </div>
        <div v-else class="tools-grid">
          <ToolCard v-for="tool in filteredTools" :key="tool.id" :tool="tool" />
        </div>
      </template>
    </main>

    <footer class="footer">
      <p>
        <a href="https://github.com/m67186636/open-hub-tools" target="_blank" class="github-link">
          <svg class="github-icon" viewBox="0 0 16 16" width="16" height="16" fill="currentColor">
            <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
          </svg>
          GitHub
        </a>
        <span class="divider">|</span>
        <a href="https://github.com/m67186636/open-hub-tools/issues" target="_blank">反馈问题</a>
      </p>
    </footer>
  </div>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: #f9fafb;
  min-height: 100vh;
}

.app {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.header {
  text-align: center;
  margin-bottom: 48px;
}

.header h1 {
  font-size: 2.5rem;
  color: #1f2937;
  margin-bottom: 12px;
}

.header p {
  color: #6b7280;
  font-size: 1.1rem;
  margin-bottom: 24px;
}

.search-box {
  position: relative;
  max-width: 500px;
  margin: 0 auto;
}

.search-input {
  width: 100%;
  padding: 14px 20px 14px 48px;
  font-size: 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.search-input:focus {
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
}

.search-input::placeholder {
  color: #9ca3af;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.2rem;
}

.main {
  min-height: 400px;
}

.results-info {
  text-align: center;
  color: #6b7280;
  margin-bottom: 24px;
  font-size: 0.9rem;
}

.loading, .error, .no-results {
  text-align: center;
  padding: 60px 20px;
  color: #6b7280;
}

.error {
  color: #dc2626;
}

.no-results {
  color: #9ca3af;
}

.tools-grid {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
  max-width: 500px;
  margin: 0 auto;
}

.tools-grid .tool-card {
  width: 100%;
}

.footer {
  text-align: center;
  margin-top: 48px;
  padding-top: 24px;
  border-top: 1px solid #e5e7eb;
  color: #9ca3af;
  font-size: 0.9rem;
}

.footer a {
  color: #6b7280;
  text-decoration: none;
  transition: color 0.2s;
}

.footer a:hover {
  color: #2563eb;
}

.github-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.github-icon {
  vertical-align: middle;
}

.divider {
  margin: 0 12px;
  color: #d1d5db;
}
</style>
