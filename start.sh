#!/bin/bash
# ============================================
# MyBinder 容器启动脚本
# 自动启动 MongoDB、Redis 服务器和 Jupyter Lab
# ============================================

set -e

echo "========================================="
echo "Starting MyBinder environment..."
echo "========================================="

# -------------------------------------------
# 1. 启动 MongoDB 服务器
# -------------------------------------------
if [ -f /tmp/mongod.conf ]; then
    echo ""
    echo ">>> Starting MongoDB server..."
    
    # 确保数据和日志目录存在
    mkdir -p /tmp/mongodb-data /tmp/mongodb-log
    
    # 检查是否已经在运行
    if pgrep -x "mongod" > /dev/null; then
        echo "✓ MongoDB is already running"
    else
        # 启动 MongoDB（后台模式）
        mongod --config /tmp/mongod.conf
        
        # 等待 MongoDB 完全启动
        echo "   Waiting for MongoDB to start..."
        MAX_RETRIES=10
        RETRY_COUNT=0
        
        while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
            sleep 1
            RETRY_COUNT=$((RETRY_COUNT + 1))
            
            # 尝试连接 MongoDB
            if mongosh --eval "db.adminCommand('ping')" 2>/dev/null | grep -q '"ok"'; then
                echo "✓ MongoDB server is running on port 27017"
                
                # 显示 MongoDB 信息
                MONGO_INFO=$(mongosh --eval "db.version()" 2>/dev/null | tail -1)
                echo "   MongoDB version: $MONGO_INFO"
                break
            fi
            
            if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
                echo "✗ Failed to start MongoDB server (timeout after ${MAX_RETRIES}s)"
                echo "Check logs: cat /tmp/mongodb-log/mongod.log"
                
                # 显示最后几行日志帮助调试
                echo ""
                echo "Last 10 lines of MongoDB log:"
                tail -n 10 /tmp/mongodb-log/mongod.log 2>/dev/null || echo "No log file found"
                break
            fi
        done
    fi
else
    echo ""
    echo "⚠ MongoDB configuration not found, skipping MongoDB startup"
fi

# -------------------------------------------
# 2. 启动 Redis 服务器
# -------------------------------------------
if [ -f /tmp/redis.conf ]; then
    echo ""
    echo ">>> Starting Redis server..."
    
    # 确保数据目录存在
    mkdir -p /tmp/redis-data
    
    # 启动 Redis（后台模式）
    redis-server /tmp/redis.conf
    
    # 短暂等待 Redis 启动
    sleep 1
    
    # 验证 Redis 是否成功启动
    if redis-cli ping 2>/dev/null | grep -q "PONG"; then
        echo "✓ Redis server is running on port 6379"
        
        # 显示 Redis 信息
        REDIS_INFO=$(redis-cli INFO server | grep -E "redis_version|tcp_port|uptime")
        echo "$REDIS_INFO"
    else
        echo "✗ Failed to start Redis server"
        echo "Check logs: cat /tmp/redis.log"
        # 不退出，继续启动其他服务
    fi
else
    echo ""
    echo "⚠ Redis configuration not found, skipping Redis startup"
fi

# -------------------------------------------
# 3. 环境检测（MyBinder vs 本地）
# -------------------------------------------
echo ""
echo ">>> Detecting environment..."

if [ -n "$BINDER_LAUNCH_URL" ] || [ -n "$JUPYTERHUB_API_TOKEN" ]; then
    echo "✓ Running in MyBinder/JupyterHub environment"
    BINDER_MODE=true
else
    echo "✓ Running in standard mode"
    BINDER_MODE=false
fi

# -------------------------------------------
# 4. 启动 Jupyter Lab
# -------------------------------------------
echo ""
echo ">>> Starting Jupyter Lab..."

# 构建 Jupyter 启动命令
JUPYTER_CMD="jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root"

# 在 MyBinder 环境中添加额外参数
if [ "$BINDER_MODE" = true ]; then
    echo "   Using MyBinder optimized settings"
    JUPYTER_CMD="$JUPYTER_CMD --ServerApp.base_url=$JUPYTERHUB_SERVICE_PREFIX"
fi

echo "   Command: $JUPYTER_CMD"
echo ""
echo "========================================="
echo "Environment ready!"
echo "- MongoDB: localhost:27017"
echo "- Redis: localhost:6379"
echo "- Jupyter Lab: http://localhost:8888"
echo "========================================="
echo ""

# 执行 Jupyter Lab（保持容器运行）
exec $JUPYTER_CMD
