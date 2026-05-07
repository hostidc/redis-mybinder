# MyBinder Redis 配置说明

## 📋 概述

本项目已配置 Redis 服务器，可在 MyBinder 环境中使用。Redis 将随容器自动启动。

## 🚀 快速开始

### 1. 构建和启动

在 MyBinder 中打开此仓库时，Redis 会自动启动。你也可以手动启动：

```bash
# 启动 Redis 服务器
redis-server /tmp/redis.conf

# 验证 Redis 是否运行
redis-cli ping
# 应返回: PONG
```

### 2. 测试连接

```bash
# 运行 Python 测试脚本
python3 test_redis.py
```

## 💻 使用示例

### Python 连接 Redis

```python
import redis

# 创建连接
r = redis.Redis(
    host='localhost',
    port=6379,
    db=0,
    decode_responses=True
)

# 基本操作
r.set('name', 'MyBinder')
value = r.get('name')
print(f"Name: {value}")  # 输出: Name: MyBinder

# 列表操作
r.lpush('tasks', 'task1', 'task2', 'task3')
tasks = r.lrange('tasks', 0, -1)
print(f"Tasks: {tasks}")

# 哈希操作
r.hset('user:1', mapping={'name': 'Alice', 'age': '25'})
user = r.hgetall('user:1')
print(f"User: {user}")
```

### 命令行操作

```bash
# 连接到 Redis CLI
redis-cli

# 基本命令
127.0.0.1:6379> SET mykey "Hello Redis"
OK
127.0.0.1:6379> GET mykey
"Hello Redis"
127.0.0.1:6379> KEYS *
1) "mykey"
127.0.0.1:6379> DEL mykey
(integer) 1
```

## ⚙️ 配置说明

### Redis 配置文件位置

- **配置文件**: `/tmp/redis.conf`
- **数据目录**: `/tmp/redis-data`
- **日志文件**: `/tmp/redis.log`

### 主要配置项

```conf
bind 127.0.0.1          # 监听地址
port 6379               # 监听端口
maxmemory 256mb         # 最大内存
maxmemory-policy allkeys-lru  # 内存淘汰策略
save 60 1              # 持久化：60秒内至少1个键变化则保存
```

### 修改配置

编辑 `/tmp/redis.conf` 文件后重启 Redis：

```bash
# 停止 Redis
redis-cli shutdown

# 重新启动
redis-server /tmp/redis.conf
```

## 🔧 高级配置

### 启用密码认证

1. 编辑 `/tmp/redis.conf`，取消注释并设置密码：
   ```conf
   requirepass your_secure_password
   ```

2. Python 连接时使用密码：
   ```python
   r = redis.Redis(
       host='localhost',
       port=6379,
       password='your_secure_password',
       decode_responses=True
   )
   ```

### 远程访问（不推荐）

如果需要从容器外访问 Redis：

1. 修改配置文件：
   ```conf
   bind 0.0.0.0
   protected-mode no
   ```

2. 重启 Redis

⚠️ **警告**: 这会降低安全性，仅用于开发环境！

## 📊 监控和调试

### 查看 Redis 状态

```bash
# 查看服务器信息
redis-cli INFO

# 查看客户端连接
redis-cli CLIENT LIST

# 实时监控命令
redis-cli MONITOR
```

### 性能测试

```bash
# 基准测试
redis-benchmark -q -n 10000 -c 50

# 查看内存使用
redis-cli INFO memory
```

### 查看日志

```bash
# 查看 Redis 日志
cat /tmp/redis.log

# 实时跟踪日志
tail -f /tmp/redis.log
```

## ⚠️ 注意事项

1. **数据持久性**: 
   - MyBinder 容器重启后，`/tmp` 目录的数据会丢失
   - 如需持久化，考虑使用外部 Redis 服务（如 Redis Cloud）

2. **内存限制**: 
   - 默认最大内存为 256MB
   - 超出后会按 LRU 策略淘汰键

3. **安全性**: 
   - 默认无密码认证
   - 生产环境务必设置 `requirepass`

4. **端口占用**: 
   - Redis 默认使用 6379 端口
   - 确保没有其他服务占用该端口

## 🐛 故障排查

### Redis 无法启动

```bash
# 检查日志
cat /tmp/redis.log

# 检查端口是否被占用
netstat -tlnp | grep 6379

# 手动启动查看详细错误
redis-server /tmp/redis.conf --loglevel debug
```

### 连接失败

```bash
# 检查 Redis 是否运行
ps aux | grep redis

# 测试本地连接
redis-cli ping

# 检查防火墙规则（如果有）
iptables -L
```

### Python 连接错误

```python
# 确保安装了 redis 包
pip install redis

# 测试连接
import redis
r = redis.Redis(host='localhost', port=6379)
print(r.ping())  # 应返回 True
```

## 📚 参考资料

- [Redis 官方文档](https://redis.io/documentation)
- [Redis Python 客户端](https://redis-py.readthedocs.io/)
- [MyBinder 文档](https://mybinder.readthedocs.io/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置！
