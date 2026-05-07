#!/bin/bash
# ============================================
# Node.js 环境测试脚本
# 验证 NVM、Node.js、npm 和 pnpm 的安装
# ============================================

set -e

echo "========================================="
echo "Node.js Environment Test"
echo "========================================="
echo ""

# -------------------------------------------
# 1. 加载 NVM
# -------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# -------------------------------------------
# 2. 检查 NVM
# -------------------------------------------
echo ">>> Checking NVM..."
if command -v nvm &> /dev/null; then
    NVM_VERSION=$(nvm --version)
    echo "✅ NVM installed: $NVM_VERSION"
else
    echo "❌ NVM not found!"
    exit 1
fi

# -------------------------------------------
# 3. 检查 Node.js
# -------------------------------------------
echo ""
echo ">>> Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    NODE_PATH=$(which node)
    echo "✅ Node.js installed: $NODE_VERSION"
    echo "   Path: $NODE_PATH"
    
    # 显示 V8 引擎版本
    V8_VERSION=$(node -p "process.versions.v8")
    echo "   V8 Engine: $V8_VERSION"
else
    echo "❌ Node.js not found!"
    exit 1
fi

# -------------------------------------------
# 4. 检查 npm
# -------------------------------------------
echo ""
echo ">>> Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    NPM_PATH=$(which npm)
    echo "✅ npm installed: $NPM_VERSION"
    echo "   Path: $NPM_PATH"
else
    echo "❌ npm not found!"
    exit 1
fi

# -------------------------------------------
# 5. 检查 pnpm
# -------------------------------------------
echo ""
echo ">>> Checking pnpm..."
if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm --version)
    PNPM_PATH=$(which pnpm)
    echo "✅ pnpm installed: $PNPM_VERSION"
    echo "   Path: $PNPM_PATH"
else
    echo "⚠️  pnpm not installed (optional)"
fi

# -------------------------------------------
# 6. 测试 Node.js 功能
# -------------------------------------------
echo ""
echo ">>> Testing Node.js functionality..."

# 创建测试文件
cat > /tmp/test_node.js << 'EOF'
// 测试基本功能
const os = require('os');
const fs = require('fs');

console.log('Platform:', os.platform());
console.log('Architecture:', os.arch());
console.log('Node Version:', process.version);
console.log('Memory Usage:', {
  rss: Math.round(os.totalmem() / 1024 / 1024) + ' MB',
  free: Math.round(os.freemem() / 1024 / 1024) + ' MB'
});

// 测试异步操作
setTimeout(() => {
  console.log('Async operation: OK');
}, 100);
EOF

# 运行测试
node /tmp/test_node.js

# 清理测试文件
rm /tmp/test_node.js

# -------------------------------------------
# 7. 测试 npm/pnpm 功能
# -------------------------------------------
echo ""
echo ">>> Testing package manager..."

# 创建临时目录进行测试
TEST_DIR=$(mktemp -d)
cd $TEST_DIR

# 初始化项目
echo '{"name":"test","version":"1.0.0"}' > package.json

# 测试 npm install
echo "Testing npm..."
npm install lodash --silent 2>&1 | head -5
if [ -d "node_modules/lodash" ]; then
    echo "✅ npm install works correctly"
    rm -rf node_modules package-lock.json
else
    echo "⚠️  npm install may have issues"
fi

# 测试 pnpm install（如果已安装）
if command -v pnpm &> /dev/null; then
    echo "Testing pnpm..."
    pnpm add lodash --silent 2>&1 | head -5
    if [ -d "node_modules/lodash" ]; then
        echo "✅ pnpm install works correctly"
    else
        echo "⚠️  pnpm install may have issues"
    fi
fi

# 清理测试目录
cd - > /dev/null
rm -rf $TEST_DIR

# -------------------------------------------
# 8. 显示 NVM 管理的 Node.js 版本
# -------------------------------------------
echo ""
echo ">>> NVM managed versions..."
nvm list

echo ""
echo "========================================="
echo "All tests completed successfully! ✅"
echo "========================================="
echo ""
echo "Quick Start:"
echo "  nvm use <version>     # Switch Node.js version"
echo "  nvm install <version> # Install new version"
echo "  nvm ls                # List installed versions"
echo "  npm install <package> # Install package with npm"
echo "  pnpm add <package>    # Install package with pnpm (faster)"
echo "========================================="
