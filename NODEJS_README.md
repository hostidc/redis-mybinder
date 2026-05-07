# Node.js & NVM 使用指南

## 📋 概述

本项目已配置 NVM (Node Version Manager)、Node.js、npm 和 pnpm，可在 MyBinder 环境中使用。

## 🚀 快速开始

### 1. 验证安装

```bash
# 运行测试脚本
bash test_nodejs.sh
```

### 2. 检查版本

```bash
# 加载 NVM（首次使用）
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 查看版本
nvm --version      # NVM 版本
node --version     # Node.js 版本
npm --version      # npm 版本
pnpm --version     # pnpm 版本
```

## 📦 NVM 常用命令

### 版本管理

```bash
# 查看已安装的版本
nvm ls

# 查看可安装的版本
nvm ls-remote

# 安装特定版本
nvm install 18
nvm install 20
nvm install 22

# 切换版本
nvm use 20
nvm use 18

# 设置默认版本
nvm alias default 20

# 卸载版本
nvm uninstall 18
```

### 项目管理

```bash
# 为项目指定 Node.js 版本
echo "20" > .nvmrc
nvm use  # 自动切换到 .nvmrc 指定的版本
```

## 📦 npm 使用

### 基本操作

```bash
# 初始化项目
npm init -y

# 安装依赖
npm install express
npm install lodash --save

# 安装开发依赖
npm install jest --save-dev

# 全局安装
npm install -g typescript

# 更新依赖
npm update
npm outdated  # 检查过时的包

# 运行脚本
npm run start
npm run build
```

### package.json 示例

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "build": "tsc",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.0",
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "typescript": "^5.0.0"
  }
}
```

## ⚡ pnpm 使用（推荐）

pnpm 比 npm 更快且更节省磁盘空间。

### 基本操作

```bash
# 初始化项目
pnpm init

# 安装依赖
pnpm add express
pnpm add lodash

# 安装开发依赖
pnpm add -D jest typescript

# 全局安装
pnpm add -g typescript

# 更新依赖
pnpm update
pnpm outdated

# 运行脚本
pnpm start
pnpm build
```

### 工作区支持

```bash
# 创建 monorepo
mkdir packages
cd packages
mkdir pkg-a pkg-b

# 在根目录创建 pnpm-workspace.yaml
cat > pnpm-workspace.yaml << EOF
packages:
  - 'packages/*'
EOF

# 安装所有工作区依赖
pnpm install
```

## 💻 代码示例

### Express 服务器

```javascript
// server.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.json({ message: 'Hello from MyBinder!' });
});

app.get('/api/data', (req, res) => {
  res.json({
    timestamp: new Date().toISOString(),
    nodeVersion: process.version,
    platform: process.platform
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
```

运行：
```bash
npm install express
node server.js
```

### 异步操作示例

```javascript
// async-example.js
const fs = require('fs').promises;
const path = require('path');

async function main() {
  try {
    // 读取文件
    const data = await fs.readFile('package.json', 'utf8');
    const pkg = JSON.parse(data);
    console.log('Package name:', pkg.name);
    
    // 写入文件
    await fs.writeFile('output.txt', 'Hello World!');
    console.log('File written successfully');
    
    // 列出目录
    const files = await fs.readdir('.');
    console.log('Files:', files.slice(0, 5));
  } catch (error) {
    console.error('Error:', error.message);
  }
}

main();
```

### TypeScript 示例

```typescript
// app.ts
interface User {
  id: number;
  name: string;
  email: string;
}

class UserService {
  private users: User[] = [];

  addUser(user: User): void {
    this.users.push(user);
  }

  getUsers(): User[] {
    return this.users;
  }

  findUser(id: number): User | undefined {
    return this.users.find(u => u.id === id);
  }
}

const service = new UserService();
service.addUser({ id: 1, name: 'Alice', email: 'alice@example.com' });
console.log(service.getUsers());
```

编译和运行：
```bash
pnpm add -D typescript @types/node
npx tsc --init
npx tsc app.ts
node app.js
```

## 🔧 高级配置

### 配置 npm/pnpm 镜像（加速下载）

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com
pnpm config set registry https://registry.npmmirror.com

# 恢复默认镜像
npm config set registry https://registry.npmjs.org
pnpm config set registry https://registry.npmjs.org
```

### 配置缓存目录

```bash
# 查看缓存位置
npm config get cache
pnpm store path

# 清理缓存
npm cache clean --force
pnpm store prune
```

### 环境变量

```bash
# 设置 Node.js 环境变量
export NODE_ENV=production
export NODE_OPTIONS=--max-old-space-size=4096

# 在 package.json 中使用
{
  "scripts": {
    "start": "NODE_ENV=production node server.js"
  }
}
```

## 🐛 故障排查

### NVM 未找到

```bash
# 手动加载 NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 检查是否添加到 ~/.bashrc
cat ~/.bashrc | grep NVM
```

### Node.js 版本冲突

```bash
# 查看当前使用的版本
node --version
which node

# 切换到正确版本
nvm use 20

# 检查 .nvmrc 文件
cat .nvmrc
```

### npm/pnpm 安装失败

```bash
# 清理缓存
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# 或使用 pnpm
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

### 权限问题

```bash
# 不要使用 sudo 安装全局包
# 而是配置 npm 使用用户目录
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### 内存不足

```bash
# 增加 Node.js 内存限制
export NODE_OPTIONS="--max-old-space-size=4096"

# 或在运行时指定
node --max-old-space-size=4096 app.js
```

## 📊 性能优化

### 使用 pnpm 代替 npm

```bash
# pnpm 优势：
# - 更快的安装速度
# - 更少的磁盘空间占用（硬链接）
# - 严格的依赖管理

# 迁移现有项目
rm -rf node_modules package-lock.json
pnpm install
```

### 并行安装

```bash
# npm 并行安装
npm install --prefer-offline --no-audit

# pnpm 默认就是并行的
pnpm install
```

### 生产环境优化

```bash
# 只安装生产依赖
npm install --production
pnpm install --prod

# 忽略可选依赖
npm install --no-optional
```

## 📚 参考资料

- [NVM 官方文档](https://github.com/nvm-sh/nvm)
- [Node.js 官方文档](https://nodejs.org/docs/)
- [npm 官方文档](https://docs.npmjs.com/)
- [pnpm 官方文档](https://pnpm.io/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置！
