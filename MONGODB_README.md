# MongoDB 使用指南

## 📋 概述

本项目已配置 MongoDB 7.0 服务器，可在 MyBinder 环境中使用。MongoDB 将随容器自动启动。

## 🚀 快速开始

### 1. 验证安装

```bash
# 检查 MongoDB 版本
mongod --version

# 检查 mongosh（MongoDB Shell）
mongosh --version

# 查看安装位置
which mongod
# 输出: /home/jovyan/.local/bin/mongod
```

### 2. 测试连接

```bash
# 运行 Python 测试脚本
python3 test_mongodb.py
```

### 3. 手动启动（如果需要）

```bash
# 启动 MongoDB
mongod --config /tmp/mongod.conf

# 验证是否运行
mongosh --eval "db.adminCommand('ping')"
```

## 💻 使用示例

### Python 连接 MongoDB

```python
from pymongo import MongoClient

# 创建连接
client = MongoClient('mongodb://localhost:27017/')

# 选择数据库
db = client['mydatabase']

# 选择集合
collection = db['users']

# 插入文档
user = {
    'name': 'Alice',
    'age': 25,
    'email': 'alice@example.com',
    'skills': ['Python', 'JavaScript', 'MongoDB']
}
result = collection.insert_one(user)
print(f"Inserted ID: {result.inserted_id}")

# 查询单个文档
user = collection.find_one({'name': 'Alice'})
print(f"Found user: {user}")

# 查询多个文档
users = collection.find({'age': {'$gte': 18}})
for user in users:
    print(user)

# 更新文档
collection.update_one(
    {'name': 'Alice'},
    {'$set': {'age': 26}}
)

# 删除文档
collection.delete_one({'name': 'Alice'})

# 关闭连接
client.close()
```

### 使用 mongosh（MongoDB Shell）

```bash
# 连接到 MongoDB
mongosh

# 在 mongosh 中执行命令
> show dbs
> use mydatabase
> show collections
> db.users.find()
> db.users.insertOne({name: "Bob", age: 30})
> db.users.createIndex({name: 1})
> exit
```

### 高级查询示例

```python
from pymongo import MongoClient, ASCENDING, DESCENDING

client = MongoClient('mongodb://localhost:27017/')
db = client['mydatabase']
collection = db['products']

# 插入多个文档
products = [
    {'name': 'Laptop', 'price': 999, 'category': 'Electronics', 'stock': 50},
    {'name': 'Phone', 'price': 699, 'category': 'Electronics', 'stock': 100},
    {'name': 'Book', 'price': 29, 'category': 'Education', 'stock': 200},
]
collection.insert_many(products)

# 条件查询
expensive_products = collection.find({'price': {'$gt': 500}})

# 排序
sorted_products = collection.find().sort('price', DESCENDING)

# 分页
page = collection.find().skip(0).limit(10)

# 聚合查询
pipeline = [
    {'$group': {'_id': '$category', 'avg_price': {'$avg': '$price'}}},
    {'$sort': {'avg_price': -1}}
]
results = collection.aggregate(pipeline)

for result in results:
    print(result)
```

## ⚙️ 配置说明

### MongoDB 安装位置

- **安装目录**: `$HOME/.local/mongodb`（非 root 用户可写）
- **二进制文件**: `$HOME/.local/bin/mongod`, `$HOME/.local/bin/mongosh`
- **配置文件**: `/tmp/mongod.conf`
- **数据目录**: `/tmp/mongodb-data`
- **日志目录**: `/tmp/mongodb-log`
- **监听地址**: `127.0.0.1:27017`

### 环境变量配置

MongoDB 的 bin 目录已自动添加到 PATH：

```bash
# 在 ~/.bashrc 和 ~/.profile 中
export PATH="$HOME/.local/bin:$PATH"
```

### 主要配置项

```
systemLog:
  destination: file
  path: /tmp/mongodb-log/mongod.log
  logAppend: true

storage:
  dbPath: /tmp/mongodb-data
  # WiredTiger 引擎默认启用 journaling，无需显式配置

net:
  bindIp: 127.0.0.1
  port: 27017

processManagement:
  fork: true
```

**注意**: MongoDB 7.0+ 已移除 `storage.journal.enabled` 配置项，因为 WiredTiger 存储引擎默认就启用了 journaling。

### 修改配置

编辑 `/tmp/mongod.conf` 文件后重启 MongoDB：

```bash
# 停止 MongoDB
mongosh --eval "db.adminCommand({shutdown: 1})"

# 重新启动
mongod --config /tmp/mongod.conf
```

## 🔧 高级配置

### 启用认证

1. 创建管理员用户：

```javascript
// 在 mongosh 中执行
use admin
db.createUser({
  user: "admin",
  pwd: "your_secure_password",
  roles: [{role: "root", db: "admin"}]
})
```

2. 修改配置文件，启用认证：

```yaml
security:
  authorization: enabled
```

3. 重启 MongoDB

4. Python 连接时使用认证：

```python
from pymongo import MongoClient

client = MongoClient(
    'mongodb://admin:your_secure_password@localhost:27017/',
    authSource='admin'
)
```

### 远程访问（不推荐）

如果需要从容器外访问 MongoDB：

1. 修改配置文件：

```yaml
net:
  bindIp: 0.0.0.0
  port: 27017
```

2. 重启 MongoDB

⚠️ **警告**: 这会降低安全性，仅用于开发环境！务必启用认证！

## 📊 监控和调试

### 查看 MongoDB 状态

```bash
# 查看服务器状态
mongosh --eval "db.serverStatus()"

# 查看当前操作
mongosh --eval "db.currentOp()"

# 查看数据库列表
mongosh --eval "show dbs"

# 查看集合统计
mongosh --eval "db.collection.stats()"
```

### 性能分析

```bash
# 慢查询分析
mongosh --eval "db.setProfilingLevel(1, 100)"  # 记录超过100ms的查询

# 查看慢查询
mongosh --eval "db.system.profile.find().pretty()"
```

### 查看日志

```bash
# 查看 MongoDB 日志
cat /tmp/mongodb-log/mongod.log

# 实时跟踪日志
tail -f /tmp/mongodb-log/mongod.log
```

## 🐛 故障排查

### MongoDB 无法启动

```bash
# 检查日志
cat /tmp/mongodb-log/mongod.log

# 检查端口是否被占用
netstat -tlnp | grep 27017

# 检查数据目录权限
ls -la /tmp/mongodb-data/

# 手动启动查看详细错误
mongod --config /tmp/mongod.conf --logpath /tmp/mongodb-debug.log
```

### 连接失败

```bash
# 检查 MongoDB 是否运行
ps aux | grep mongod

# 测试本地连接
mongosh --eval "db.adminCommand('ping')"

# 检查防火墙规则
iptables -L
```

### Python 连接错误

```python
# 确保安装了 pymongo
pip install pymongo

# 测试连接
from pymongo import MongoClient
client = MongoClient('mongodb://localhost:27017/', serverSelectionTimeoutMS=5000)
print(client.admin.command('ping'))
```

### 磁盘空间不足

```bash
# 查看数据目录大小
du -sh /tmp/mongodb-data/

# 清理未使用的数据库
mongosh --eval "db.adminCommand({listDatabases: 1}).databases.forEach(function(db) { 
    if (db.name !== 'admin' && db.name !== 'local') {
        db.getSiblingDB(db.name).dropDatabase();
    }
})"
```

## 📚 常用命令速查

### mongosh 命令

```javascript
// 数据库操作
show dbs                    // 显示所有数据库
use dbname                  // 切换数据库
db.dropDatabase()           // 删除当前数据库

// 集合操作
show collections            // 显示所有集合
db.createCollection('name') // 创建集合
db.collection.drop()        // 删除集合

// 文档操作
db.collection.find()        // 查询所有文档
db.collection.findOne()     // 查询单个文档
db.collection.insertOne()   // 插入单个文档
db.collection.insertMany()  // 插入多个文档
db.collection.updateOne()   // 更新单个文档
db.collection.deleteOne()   // 删除单个文档
db.collection.deleteMany()  // 删除多个文档

// 索引操作
db.collection.createIndex({field: 1})      // 创建索引
db.collection.getIndexes()                 // 查看索引
db.collection.dropIndex('index_name')      // 删除索引

// 用户管理
db.createUser({user, pwd, roles})          // 创建用户
db.dropUser('username')                    // 删除用户
db.getUser('username')                     // 查看用户
```

### 查询操作符

```javascript
// 比较操作符
{$eq: value}      // 等于
{$ne: value}      // 不等于
{$gt: value}      // 大于
{$gte: value}     // 大于等于
{$lt: value}      // 小于
{$lte: value}     // 小于等于
{$in: [values]}   // 在数组中
{$nin: [values]}  // 不在数组中

// 逻辑操作符
{$and: [exprs]}   // 与
{$or: [exprs]}    // 或
{$not: expr}      // 非
{$nor: [exprs]}   // 或非

// 数组操作符
{$all: [values]}  // 包含所有值
{$elemMatch: expr}// 数组元素匹配
{$size: number}   // 数组大小

// 正则表达式
{name: {$regex: /pattern/, $options: 'i'}}
```

## ⚠️ 注意事项

1. **数据持久性**: 
   - MyBinder 容器重启后，`/tmp` 目录的数据会丢失
   - 如需持久化，考虑使用外部 MongoDB 服务（如 MongoDB Atlas）

2. **内存使用**: 
   - MongoDB 会使用大量内存进行缓存
   - 可以通过配置文件限制 WiredTiger 缓存大小

3. **安全性**: 
   - 默认无认证
   - 生产环境务必启用认证并设置强密码

4. **端口占用**: 
   - MongoDB 默认使用 27017 端口
   - 确保没有其他服务占用该端口

## 📚 参考资料

- [MongoDB 官方文档](https://www.mongodb.com/docs/)
- [PyMongo 文档](https://pymongo.readthedocs.io/)
- [MongoDB University](https://university.mongodb.com/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置！
