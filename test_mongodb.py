"""
MongoDB 连接测试脚本
用于验证 MongoDB 服务器是否正常运行
"""

import sys

def test_mongodb_connection():
    """测试 MongoDB 连接"""
    try:
        from pymongo import MongoClient
    except ImportError:
        print("❌ PyMongo 未安装")
        print("   请运行: pip install pymongo")
        return False
    
    try:
        # 创建 MongoDB 连接
        client = MongoClient(
            'mongodb://localhost:27017/',
            serverSelectionTimeoutMS=5000
        )
        
        # 测试连接
        client.admin.command('ping')
        print("✅ MongoDB 连接成功!")
        
        # 获取服务器信息
        server_info = client.server_info()
        print(f"   MongoDB 版本: {server_info.get('version', 'N/A')}")
        print(f"   Git 版本: {server_info.get('gitVersion', 'N/A')}")
        
        # 测试基本操作
        db = client['test_db']
        collection = db['test_collection']
        
        # 插入文档
        test_doc = {'name': 'MyBinder', 'type': 'test', 'value': 42}
        result = collection.insert_one(test_doc)
        print(f"   插入文档 ID: {result.inserted_id}")
        
        # 查询文档
        doc = collection.find_one({'name': 'MyBinder'})
        print(f"   查询结果: {doc}")
        
        # 清理测试数据
        collection.delete_one({'name': 'MyBinder'})
        client.drop_database('test_db')
        
        return True
        
    except Exception as e:
        print(f"❌ MongoDB 连接失败: {e}")
        print("   请确保 MongoDB 服务器已启动")
        print("   启动命令: mongod --config /tmp/mongod.conf")
        return False

if __name__ == '__main__':
    print("=" * 50)
    print("MongoDB 连接测试")
    print("=" * 50)
    print()
    
    success = test_mongodb_connection()
    
    print()
    print("=" * 50)
    if success:
        print("测试通过 ✅")
        sys.exit(0)
    else:
        print("测试失败 ❌")
        sys.exit(1)
