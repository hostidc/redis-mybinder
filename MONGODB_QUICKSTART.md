# MongoDB 使用指南 - 快速参考

## 🚀 快速开始

### 检查 MongoDB 状态

```bash
# 验证 MongoDB 是否运行
mongosh --eval "db.adminCommand('ping')"

# 查看版本
mongod --version

# 查看进程
ps aux | grep mongod
```

## 📋 连接方式对比

### 方式 1: 无认证模式（开发环境 - 默认）✅ 推荐

**适用场景**: 本地开发、测试环境、MyBinder 演示

```bash
# 命令行连接
mongosh mongodb://127.0.0.1:27017/fastgpt

# Python 连接
python3 << 'EOF'
from pymongo import MongoClient

client = MongoClient('mongodb://127.0.0.1:27017/')
db = client['fastgpt']

# 测试
print(db.command('ping'))

# 插入数据
db.users.insert_one({'name': 'Alice', 'age': 25})

# 查询数据
user = db.users.find_one({'name': 'Alice'})
print(user)
EOF
```

**优点**:
- ✅ 简单直接，无需配置
- ✅ 适合快速开发和测试
- ✅ MyBinder 环境默认模式

**缺点**:
- ❌ 无安全性，任何人都可以访问
- ❌ 不适合生产环境

---

### 方式 2: 认证模式（生产环境）🔒

**适用场景**: 生产环境、需要安全保护的场景

#### 步骤 1: 运行初始化脚本

```bash
chmod +x init_mongodb.sh
./init_mongodb.sh
```

选择选项 `2`，然后输入：
- 管理员用户名（如: `admin`）
- 管理员密码（如: `SecurePass123!`）
- 数据库名称（如: `fastgpt`）

#### 步骤 2: 使用认证连接

```bash
# 命令行连接
mongosh "mongodb://admin:SecurePass123!@127.0.0.1:27017/fastgpt?authSource=admin"

# Python 连接
python3 << 'EOF'
from pymongo import MongoClient

# 带认证的连接
client = MongoClient(
    'mongodb://admin:SecurePass123!@127.0.0.1:27017/fastgpt?authSource=admin'
)
db = client['fastgpt']

# 测试
print(db.command('ping'))
EOF
```

**优点**:
- ✅ 安全可靠
- ✅ 支持多用户权限管理
- ✅ 适合生产环境

**缺点**:
- ❌ 配置稍复杂
- ❌ 需要管理密码

---

### 方式 3: 副本集模式（高级 - 不推荐用于 MyBinder）⚠️

**注意**: MyBinder 环境**不建议**使用副本集，因为：
- 容器重启后数据丢失
- 增加启动复杂度
- MyBinder 有 30 秒启动超时限制

如果你确实需要（仅用于学习），可以手动配置：

```bash
# ⚠️ 仅在需要时执行

# 1. 停止当前 MongoDB
mongosh --eval "db.adminCommand({shutdown: 1})"
sleep 2

# 2. 修改配置文件添加副本集
cat > /tmp/mongod.conf << 'EOF'
systemLog:
  destination: file
  path: /tmp/mongodb-log/mongod.log
  logAppend: true

storage:
  dbPath: /tmp/mongodb-data

net:
  bindIp: 127.0.0.1
  port: 27017

processManagement:
  fork: true

replication:
  replSetName: "rs0"
EOF

# 3. 重新启动
mongod --config /tmp/mongod.conf
sleep 2

# 4. 初始化副本集
mongosh --eval '
rs.initiate({
  _id: "rs0",
  members: [{ _id: 0, host: "127.0.0.1:27017" }]
})
'

# 5. 等待成为 PRIMARY
sleep 5

# 6. 创建用户（如果需要认证）
mongosh --eval '
db.getSiblingDB("admin").createUser({
  user: "myusername",
  pwd: "mypassword",
  roles: ["root"]
})
'

# 7. 测试连接
mongosh "mongodb://myusername:mypassword@127.0.0.1:27017/admin?authSource=admin&replicaSet=rs0" --eval "db.adminCommand('ping')"
```

**FastGPT 连接字符串**:
```
mongodb://myusername:mypassword@127.0.0.1:27017/fastgpt?authSource=admin&replicaSet=rs0
```

---

## 🔧 常用操作

### 数据库管理

```javascript
// 在 mongosh 中执行

// 显示所有数据库
show dbs

// 切换数据库
use fastgpt

// 显示集合
show collections

// 插入文档
db.users.insertOne({
  name: "Alice",
  age: 25,
  email: "alice@example.com"
})

// 查询文档
db.users.find()
db.users.findOne({name: "Alice"})

// 更新文档
db.users.updateOne(
  {name: "Alice"},
  {$set: {age: 26}}
)

// 删除文档
db.users.deleteOne({name: "Alice"})

// 创建索引
db.users.createIndex({email: 1}, {unique: true})

// 查看统计
db.users.stats()
```

### Python 高级操作

```python
from pymongo import MongoClient, ASCENDING, DESCENDING

# 连接
client = MongoClient('mongodb://127.0.0.1:27017/')
db = client['fastgpt']

# 批量插入
users = [
    {'name': 'Alice', 'age': 25},
    {'name': 'Bob', 'age': 30},
    {'name': 'Charlie', 'age': 35}
]
db.users.insert_many(users)

# 条件查询
adults = db.users.find({'age': {'$gte': 18}})

# 排序
sorted_users = db.users.find().sort('age', DESCENDING)

# 分页
page = db.users.find().skip(0).limit(10)

# 聚合
pipeline = [
    {'$group': {'_id': None, 'avg_age': {'$avg': '$age'}}}
]
result = db.users.aggregate(pipeline)

# 关闭连接
client.close()
```

---

## 🐛 故障排查

### MongoDB 无法启动

```bash
# 检查日志
cat /tmp/mongodb-log/mongod.log

# 检查端口
netstat -tlnp | grep 27017

# 检查进程
ps aux | grep mongod

# 手动启动查看详细错误
mongod --config /tmp/mongod.conf --logpath /tmp/debug.log
```

### 连接失败

```bash
# 测试基本连接
mongosh --eval "db.adminCommand('ping')"

# 检查认证（如果启用了）
mongosh "mongodb://user:pass@127.0.0.1:27017/admin?authSource=admin"

# 查看 MongoDB 状态
mongosh --eval "db.serverStatus()"
```

### 忘记管理员密码

```bash
# 1. 停止 MongoDB
mongosh --eval "db.adminCommand({shutdown: 1})"

# 2. 以无认证模式启动（临时）
# 编辑 /tmp/mongod.conf，注释掉 security 部分
sed -i 's/authorization: enabled/# authorization: enabled/' /tmp/mongod.conf
mongod --config /tmp/mongod.conf

# 3. 重置密码
mongosh --eval '
db.getSiblingDB("admin").updateUser("admin", {
  pwd: "newpassword"
})
'

# 4. 恢复认证配置并重启
sed -i 's/# authorization: enabled/authorization: enabled/' /tmp/mongod.conf
mongosh --eval "db.adminCommand({shutdown: 1})"
sleep 2
mongod --config /tmp/mongod.conf
```

---

## 📊 性能监控

```bash
# 查看服务器状态
mongosh --eval "JSON.stringify(db.serverStatus(), null, 2)"

# 查看当前操作
mongosh --eval "db.currentOp()"

# 查看慢查询
mongosh --eval "db.setProfilingLevel(1, 100)"  # 记录 >100ms 的查询
mongosh --eval "db.system.profile.find().pretty()"

# 查看数据库大小
mongosh --eval "db.stats()"

# 查看集合大小
mongosh fastgpt --eval "db.users.stats()"
```

---

## ⚠️ MyBinder 特殊注意事项

1. **数据持久性**: 
   - `/tmp` 目录在容器重启后会清空
   - 重要数据应导出或保存到外部服务

2. **启动时间**: 
   - MyBinder 有 30 秒超时限制
   - 避免复杂的初始化操作
   - 推荐使用无认证模式

3. **资源限制**: 
   - 内存有限，注意 MongoDB 缓存大小
   - 可以通过配置限制 WiredTiger 缓存

4. **推荐配置**: 
   - ✅ 使用无认证模式
   - ✅ 单机模式（非副本集）
   - ✅ 定期清理测试数据

---

## 📚 参考资料

- [MongoDB 官方文档](https://www.mongodb.com/docs/)
- [PyMongo 文档](https://pymongo.readthedocs.io/)
- [MongoDB 连接字符串格式](https://www.mongodb.com/docs/manual/reference/connection-string/)
