// replace-env.js
// 构建后替换脚本中的占位符

import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

const DIST_TOOLS_DIR = 'dist/tools';
const DIST_INDEX_HTML = 'dist/index.html';
const PLACEHOLDERS = {
  '__API_BASE_URL__': process.env.VITE_API_BASE_URL || 'https://api.model-hub.cn',
  '__BAIDU_ANALYTICS_ID__': process.env.VITE_BAIDU_ANALYTICS_ID || '',
};

function replaceInFile(filePath) {
  let content = readFileSync(filePath, 'utf-8');
  let modified = false;

  // 处理百度统计特殊占位符
  if (content.includes('<!-- __BAIDU_ANALYTICS__ -->')) {
    const baiduId = PLACEHOLDERS['__BAIDU_ANALYTICS_ID__'];
    if (baiduId) {
      const baiduScript = `<script>
var _hmt = _hmt || [];
(function() {
  var hm = document.createElement("script");
  hm.src = "https://hm.baidu.com/hm.js?${baiduId}";
  var s = document.getElementsByTagName("script")[0]; 
  s.parentNode.insertBefore(hm, s);
})();
</script>`;
      content = content.replace('<!-- __BAIDU_ANALYTICS__ -->', baiduScript);
    } else {
      content = content.replace('<!-- __BAIDU_ANALYTICS__ -->', '');
    }
    modified = true;
  }

  // 处理普通占位符
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
    } else if (entry.endsWith('.ps1') || entry.endsWith('.sh') || entry.endsWith('.md') || entry.endsWith('.html')) {
      replaceInFile(fullPath);
    }
  }
}

console.log('Replacing environment placeholders...');
console.log(`  API_BASE_URL: ${PLACEHOLDERS['__API_BASE_URL__']}`);
console.log(`  BAIDU_ANALYTICS_ID: ${PLACEHOLDERS['__BAIDU_ANALYTICS_ID__'] || '(not set)'}`);
console.log('');

try {
  // Replace in tools directory
  processDirectory(DIST_TOOLS_DIR);
  
  // Replace in index.html
  replaceInFile(DIST_INDEX_HTML);
  
  console.log('\nDone!');
} catch (err) {
  console.error('Error:', err.message);
  process.exit(1);
}
