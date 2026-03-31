// replace-env.js
// 构建后替换脚本中的占位符

import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

const DIST_TOOLS_DIR = 'dist/tools';
const PLACEHOLDERS = {
  '__API_BASE_URL__': process.env.VITE_API_BASE_URL || 'https://api.model-hub.cn',
};

function replaceInFile(filePath) {
  let content = readFileSync(filePath, 'utf-8');
  let modified = false;

  for (const [placeholder, value] of Object.entries(PLACEHOLDERS)) {
    if (content.includes(placeholder)) {
      content = content.replaceAll(placeholder, value);
      modified = true;
    }
  }

  if (modified) {
    writeFileSync(filePath, content, 'utf-8');
    console.log(`  ✓ ${filePath}`);
  }
}

function processDirectory(dir) {
  const entries = readdirSync(dir);
  
  for (const entry of entries) {
    const fullPath = join(dir, entry);
    const stat = statSync(fullPath);
    
    if (stat.isDirectory()) {
      processDirectory(fullPath);
    } else if (entry.endsWith('.ps1') || entry.endsWith('.sh') || entry.endsWith('.md')) {
      replaceInFile(fullPath);
    }
  }
}

console.log('Replacing environment placeholders...');
console.log(`  API_BASE_URL: ${PLACEHOLDERS['__API_BASE_URL__']}`);
console.log('');

try {
  processDirectory(DIST_TOOLS_DIR);
  console.log('\nDone!');
} catch (err) {
  console.error('Error:', err.message);
  process.exit(1);
}
