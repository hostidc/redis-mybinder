"""
Redis 连接测试脚本
用于验证 Redis 服务器是否正常运行
"""

import sys

def test_redis_connection():
    """测试 Redis 连接"""
    try:
        import redis
    except ImportError:
        print("❌ Redis Python 客户端未安装")
        print("   请运行: pip install redis")
        return False
    
    try:
        # 创建 Redis 连接
        r = redis.Redis(
            host='localhost',
            port=6379,
            db=0,
            decode_responses=True,
            socket_timeout=2
        )
        
        # 测试 ping
        if r.ping():
            print("✅ Redis 连接成功!")
            
            # 获取 Redis 信息
            info = r.info('server')
            print(f"   Redis 版本: {info.get('redis_version', 'N/A')}")
            print(f"   运行模式: {info.get('redis_mode', 'N/A')}")
            print(f"   TCP 端口: {info.get('tcp_port', 'N/A')}")
            
            # 测试基本操作
            r.set('test_key', 'Hello from MyBinder!')
            value = r.get('test_key')
            print(f"   测试写入: test_key = '{value}'")
            
            # 清理测试数据
            r.delete('test_key')
            
            return True
        else:
            print("❌ Redis ping 失败")
            return False
            
    except redis.ConnectionError as e:
        print(f"❌ Redis 连接失败: {e}")
        print("   请确保 Redis 服务器已启动")
        print("   启动命令: redis-server /tmp/redis.conf")
        return False
    except Exception as e:
        print(f"❌ 发生错误: {e}")
        return False

if __name__ == '__main__':
    print("=" * 50)
    print("Redis 连接测试")
    print("=" * 50)
    print()
    
    success = test_redis_connection()
    
    print()
    print("=" * 50)
    if success:
        print("测试通过 ✅")
        sys.exit(0)
    else:
        print("测试失败 ❌")
        sys.exit(1)
