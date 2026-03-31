<script setup lang="ts">
import { ref } from 'vue'
import type { Tool } from '../types'
import { getInstallCommand } from '../api'

const props = defineProps<{
  tool: Tool
}>()

const showModal = ref(false)
const copied = ref(false)
const platform = ref<'windows' | 'unix'>('windows')

function detectPlatform() {
  const ua = navigator.userAgent.toLowerCase()
  if (ua.includes('win')) return 'windows'
  return 'unix'
}

platform.value = detectPlatform()

async function copyCommand() {
  const cmd = getInstallCommand(props.tool, platform.value)
  await navigator.clipboard.writeText(cmd)
  copied.value = true
  setTimeout(() => (copied.value = false), 2000)
}

function formatNumber(num?: number): string {
  if (!num) return '-'
  if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M'
  if (num >= 1000) return (num / 1000).toFixed(1) + 'K'
  return num.toString()
}

const linkIcons: Record<string, string> = {
  website: '🌐',
  docs: '📖',
  repo: '📦',
  other: '🔗'
}
</script>

<template>
  <div class="tool-card" @click="showModal = true">
    <img 
      :src="tool.logoUrl" 
      :alt="tool.name" 
      class="tool-logo" 
      @error="($event.target as HTMLImageElement).src = '/default-logo.svg'" 
    />
    <div class="card-content">
      <div class="card-top">
        <span class="vendor">{{ tool.vendor }}</span>
        <span class="separator">/</span>
        <span class="name">{{ tool.name }}</span>
      </div>
      <div class="card-bottom">
        <span class="stat">⭐ {{ formatNumber(tool.stars) }}</span>
        <span class="stat">📥 {{ formatNumber(tool.downloads) }}</span>
      </div>
    </div>
    <span class="arrow">›</span>
  </div>

  <!-- Modal -->
  <Teleport to="body">
    <div class="modal-overlay" v-if="showModal" @click.self="showModal = false">
      <div class="modal">
        <button class="modal-close" @click="showModal = false">✕</button>
        
        <div class="modal-header">
          <img 
            :src="tool.logoUrl" 
            :alt="tool.name" 
            class="modal-logo" 
            @error="($event.target as HTMLImageElement).src = '/default-logo.svg'" 
          />
          <div>
            <div class="modal-title">
              <span class="vendor">{{ tool.vendor }}</span>
              <span class="separator">/</span>
              <span class="name">{{ tool.name }}</span>
            </div>
            <div class="modal-stats">
              <span class="stat">⭐ {{ formatNumber(tool.stars) }}</span>
              <span class="stat">📥 {{ formatNumber(tool.downloads) }}</span>
            </div>
          </div>
        </div>

        <p class="modal-desc">{{ tool.description }}</p>

        <div class="tags">
          <span v-for="tag in tool.tags" :key="tag" class="tag">{{ tag }}</span>
        </div>

        <div class="links">
          <a 
            v-for="link in tool.links" 
            :key="link.url" 
            :href="link.url" 
            target="_blank" 
            rel="noopener" 
            class="link-btn"
            @click.stop
          >
            {{ linkIcons[link.type] || '🔗' }} {{ link.label }}
          </a>
        </div>

        <div class="install-section">
          <div class="platform-toggle">
            <button :class="{ active: platform === 'windows' }" @click="platform = 'windows'">
              Windows
            </button>
            <button :class="{ active: platform === 'unix' }" @click="platform = 'unix'">
              Linux/Mac
            </button>
          </div>
          
          <div class="install-cmd">
            <code>{{ getInstallCommand(tool, platform) }}</code>
          </div>

          <button class="copy-btn" @click="copyCommand">
            {{ copied ? '✅ Copied!' : '📋 Copy Command' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.tool-card {
  background: #fff;
  border: 1px solid #e5e7eb;
  border-radius: 10px;
  padding: 14px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: all 0.15s;
  width: 100%;
  box-sizing: border-box;
}

.tool-card:hover {
  background: #f9fafb;
  border-color: #d1d5db;
}

.tool-logo {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  object-fit: contain;
  background: #f3f4f6;
  padding: 6px;
  flex-shrink: 0;
}

.card-content {
  flex: 1;
  min-width: 0;
}

.card-top {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.95rem;
  margin-bottom: 4px;
}

.card-bottom {
  display: flex;
  gap: 12px;
}

.vendor {
  color: #6b7280;
}

.separator {
  color: #d1d5db;
}

.name {
  color: #111827;
  font-weight: 600;
}

.stat {
  font-size: 0.8rem;
  color: #6b7280;
}

.arrow {
  color: #9ca3af;
  font-size: 1.5rem;
  font-weight: 300;
}

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal {
  background: #fff;
  border-radius: 16px;
  padding: 28px;
  width: 100%;
  max-width: 640px;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
}

.modal-close {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 32px;
  height: 32px;
  border: none;
  background: #f3f4f6;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  color: #6b7280;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-close:hover {
  background: #e5e7eb;
}

.modal-header {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.modal-logo {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  object-fit: contain;
  background: #f3f4f6;
  padding: 8px;
}

.modal-title {
  font-size: 1.1rem;
  margin-bottom: 6px;
}

.modal-stats {
  display: flex;
  gap: 12px;
}

.modal-desc {
  color: #4b5563;
  font-size: 0.9rem;
  line-height: 1.6;
  margin-bottom: 16px;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 16px;
}

.tag {
  background: #e0f2fe;
  color: #0369a1;
  padding: 4px 12px;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: 500;
}

.links {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 20px;
}

.link-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 8px 14px;
  background: #f3f4f6;
  color: #374151;
  border-radius: 8px;
  font-size: 0.85rem;
  text-decoration: none;
  transition: background 0.15s;
}

.link-btn:hover {
  background: #e5e7eb;
}

.install-section {
  background: #f9fafb;
  border-radius: 12px;
  padding: 16px;
}

.platform-toggle {
  display: flex;
  background: #e5e7eb;
  border-radius: 8px;
  padding: 4px;
  margin-bottom: 12px;
}

.platform-toggle button {
  flex: 1;
  padding: 8px 16px;
  border: none;
  background: transparent;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.85rem;
  color: #6b7280;
  transition: all 0.15s;
}

.platform-toggle button.active {
  background: #fff;
  color: #111827;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.install-cmd {
  background: #1f2937;
  border-radius: 8px;
  padding: 12px 14px;
  margin-bottom: 12px;
  overflow-x: auto;
}

.install-cmd code {
  color: #10b981;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 0.85rem;
  white-space: nowrap;
}

.copy-btn {
  width: 100%;
  padding: 12px;
  border: none;
  background: #2563eb;
  color: #fff;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s;
}

.copy-btn:hover {
  background: #1d4ed8;
}
</style>
