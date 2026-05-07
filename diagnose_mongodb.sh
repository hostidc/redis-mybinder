#!/bin/bash
# ============================================
# MongoDB 诊断脚本
# 用于排查 MongoDB 启动问题
# ============================================

echo "========================================="
echo "MongoDB Diagnostic Tool"
echo "========================================="
echo ""

# 1. 检查 MongoDB 进程
echo ">>> Checking MongoDB process..."
if pgrep -x "mongod" > /dev/null; then
    echo "✓ MongoDB process is running"
    ps aux | grep mongod | grep -v grep
else
    echo "✗ MongoDB process is NOT running"
fi
echo ""

# 2. 检查端口监听
echo ">>> Checking port 27017..."
if netstat -tlnp 2>/dev/null | grep -q ":27017"; then
    echo "✓ Port 27017 is listening"
    netstat -tlnp | grep ":27017"
elif ss -tuln 2>/dev/null | grep -q ":27017"; then
    echo "✓ Port 27017 is listening"
    ss -tuln | grep ":27017"
else
    echo "✗ Port 27017 is NOT listening"
fi
echo ""

# 3. 检查配置文件
echo ">>> Checking configuration file..."
if [ -f /tmp/mongod.conf ]; then
    echo "✓ Configuration file exists: /tmp/mongod.conf"
    echo "Content:"
    cat /tmp/mongod.conf
else
    echo "✗ Configuration file NOT found"
fi
echo ""

# 4. 检查数据目录
echo ">>> Checking data directory..."
if [ -d /tmp/mongodb-data ]; then
    echo "✓ Data directory exists: /tmp/mongodb-data"
    ls -la /tmp/mongodb-data/ | head -10
else
    echo "✗ Data directory NOT found"
fi
echo ""

# 5. 检查日志文件
echo ">>> Checking log file..."
if [ -f /tmp/mongodb-log/mongod.log ]; then
    echo "✓ Log file exists: /tmp/mongodb-log/mongod.log"
    echo ""
    echo "Last 20 lines of log:"
    echo "---"
    tail -n 20 /tmp/mongodb-log/mongod.log
    echo "---"
    
    # 检查是否有错误
    echo ""
    if grep -i "error\|fatal\|exception" /tmp/mongodb-log/mongod.log | tail -5; then
        echo "⚠ Found errors in log"
    else
        echo "✓ No obvious errors in log"
    fi
else
    echo "✗ Log file NOT found"
fi
echo ""

# 6. 检查 mongosh 可用性
echo ">>> Checking mongosh..."
if command -v mongosh &> /dev/null; then
    echo "✓ mongosh is available"
    which mongosh
    mongosh --version
else
    echo "✗ mongosh NOT found"
fi
echo ""

# 7. 尝试手动连接
echo ">>> Testing connection..."
echo "Attempting to connect to MongoDB..."
timeout 5 mongosh --eval "db.adminCommand('ping')" 2>&1 || echo "Connection failed"
echo ""

# 8. 检查磁盘空间
echo ">>> Checking disk space..."
df -h /tmp
echo ""

# 9. 检查内存
echo ">>> Checking memory..."
free -h
echo ""

# 10. 提供解决方案
echo "========================================="
echo "Diagnostic Summary"
echo "========================================="
echo ""

if pgrep -x "mongod" > /dev/null; then
    echo "✅ MongoDB appears to be running"
    echo ""
    echo "Try connecting with:"
    echo "  mongosh mongodb://127.0.0.1:27017/"
else
    echo "❌ MongoDB is not running properly"
    echo ""
    echo "Suggested actions:"
    echo "  1. Check the log file: cat /tmp/mongodb-log/mongod.log"
    echo "  2. Try starting manually: mongod --config /tmp/mongod.conf"
    echo "  3. Check if port 27017 is in use: netstat -tlnp | grep 27017"
    echo "  4. Verify configuration: cat /tmp/mongod.conf"
    echo ""
    echo "To restart MongoDB:"
    echo "  # Stop any existing process"
    echo "  pkill mongod || true"
    echo "  sleep 2"
    echo "  # Start with config"
    echo "  mongod --config /tmp/mongod.conf"
fi
echo ""
echo "========================================="
