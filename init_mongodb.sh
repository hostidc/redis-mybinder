#!/bin/bash
# ============================================
# MongoDB 初始化脚本
# 支持无认证模式和认证模式
# ============================================

set -e

echo "========================================="
echo "MongoDB Initialization Script"
echo "========================================="

# 检测 MongoDB 是否运行
if ! mongosh --eval "db.adminCommand('ping')" --quiet 2>/dev/null | grep -q "ok"; then
    echo "❌ MongoDB is not running!"
    echo "   Please start MongoDB first: mongod --config /tmp/mongod.conf"
    exit 1
fi

echo "✓ MongoDB is running"

# -------------------------------------------
# 选择初始化模式
# -------------------------------------------
echo ""
echo "Select initialization mode:"
echo "  1) Simple Mode (No Authentication) - Recommended for development"
echo "  2) Secure Mode (With Authentication) - Recommended for production"
echo ""
read -p "Enter choice (1 or 2): " MODE_CHOICE

if [ "$MODE_CHOICE" = "2" ]; then
    # -------------------------------------------
    # 模式 2: 启用认证
    # -------------------------------------------
    echo ""
    echo ">>> Setting up authentication..."
    
    # 读取用户输入
    read -p "Admin username: " ADMIN_USER
    read -s -p "Admin password: " ADMIN_PASS
    echo ""
    read -p "Database name (default: fastgpt): " DB_NAME
    DB_NAME=${DB_NAME:-fastgpt}
    
    echo ""
    echo "Creating admin user..."
    
    # 创建管理员用户
    mongosh --port 27017 --eval "
        db.getSiblingDB('admin').createUser({
            user: '$ADMIN_USER',
            pwd: '$ADMIN_PASS',
            roles: [
                { role: 'root', db: 'admin' },
                { role: 'dbOwner', db: '$DB_NAME' }
            ]
        })
    "
    
    echo "✓ Admin user created: $ADMIN_USER"
    
    # 停止 MongoDB
    echo ""
    echo "Stopping MongoDB to enable authentication..."
    mongosh --port 27017 --eval "db.adminCommand({shutdown: 1})" || true
    sleep 2
    
    # 修改配置文件启用认证
    echo "Enabling authentication in config..."
    sed -i 's/# security:/security:/' /tmp/mongod.conf
    sed -i 's/#   authorization: enabled/  authorization: enabled/' /tmp/mongod.conf
    
    # 重新启动 MongoDB
    echo "Restarting MongoDB with authentication..."
    mongod --config /tmp/mongod.conf
    sleep 2
    
    # 验证认证
    echo ""
    echo "Testing authenticated connection..."
    if mongosh "mongodb://${ADMIN_USER}:${ADMIN_PASS}@127.0.0.1:27017/admin?authSource=admin" --eval "db.adminCommand('ping')" --quiet 2>/dev/null | grep -q "ok"; then
        echo "✅ Authentication enabled successfully!"
        echo ""
        echo "Connection strings:"
        echo "  Admin:  mongodb://${ADMIN_USER}:<password>@127.0.0.1:27017/admin?authSource=admin"
        echo "  App DB: mongodb://${ADMIN_USER}:<password>@127.0.0.1:27017/${DB_NAME}?authSource=admin"
        echo ""
        echo "Python example:"
        echo "  from pymongo import MongoClient"
        echo "  client = MongoClient('mongodb://${ADMIN_USER}:${ADMIN_PASS}@127.0.0.1:27017/${DB_NAME}?authSource=admin')"
    else
        echo "❌ Authentication test failed!"
        echo "   Check logs: cat /tmp/mongodb-log/mongod.log"
        exit 1
    fi
    
else
    # -------------------------------------------
    # 模式 1: 无认证（默认）
    # -------------------------------------------
    echo ""
    echo ">>> Using simple mode (no authentication)..."
    
    read -p "Database name (default: fastgpt): " DB_NAME
    DB_NAME=${DB_NAME:-fastgpt}
    
    # 测试连接
    echo ""
    echo "Testing connection..."
    if mongosh --port 27017 --eval "db.adminCommand('ping')" --quiet 2>/dev/null | grep -q "ok"; then
        echo "✅ MongoDB is accessible without authentication"
        echo ""
        echo "Connection strings:"
        echo "  Direct: mongodb://127.0.0.1:27017/${DB_NAME}"
        echo ""
        echo "Python example:"
        echo "  from pymongo import MongoClient"
        echo "  client = MongoClient('mongodb://127.0.0.1:27017/${DB_NAME}')"
        echo "  db = client['${DB_NAME}']"
        echo ""
        echo "⚠️  Note: This mode has NO authentication. Only use for development!"
    else
        echo "❌ Connection test failed!"
        exit 1
    fi
fi

echo ""
echo "========================================="
echo "Initialization completed!"
echo "========================================="
