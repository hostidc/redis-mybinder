"""
MinIO 连接测试脚本
用于验证 MinIO 服务器是否正常运行
"""

import sys
import io

def test_minio_connection():
    """测试 MinIO 连接和基本操作"""
    try:
        from minio import Minio
        from minio.error import S3Error
    except ImportError:
        print("❌ MinIO Python 客户端未安装")
        print("   请运行: pip install minio")
        return False
    
    try:
        # 创建 MinIO 客户端
        client = Minio(
            "localhost:9000",
            access_key="minioadmin",
            secret_key="minioadmin",
            secure=False
        )
        
        print("✅ MinIO 连接成功!")
        
        # 测试健康状态
        print("\n>>> Testing health check...")
        import urllib.request
        response = urllib.request.urlopen('http://localhost:9000/minio/health/live')
        if response.getcode() == 200:
            print("✓ API health check passed")
        else:
            print(f"✗ API health check failed with status {response.getcode()}")
            return False
        
        # 创建测试 bucket
        print("\n>>> Creating test bucket...")
        bucket_name = "test-bucket-" + str(hash("test") % 10000)
        
        if not client.bucket_exists(bucket_name):
            client.make_bucket(bucket_name)
            print(f"✓ Bucket '{bucket_name}' created")
        else:
            print(f"✓ Bucket '{bucket_name}' already exists")
        
        # 上传测试数据
        print("\n>>> Uploading test data...")
        test_data = b"Hello from MyBinder MinIO!"
        object_name = "test-file.txt"
        
        client.put_object(
            bucket_name,
            object_name,
            io.BytesIO(test_data),
            length=len(test_data),
            content_type="text/plain"
        )
        print(f"✓ File '{object_name}' uploaded to bucket '{bucket_name}'")
        
        # 下载并验证
        print("\n>>> Downloading and verifying data...")
        response = client.get_object(bucket_name, object_name)
        downloaded_data = response.read()
        response.close()
        response.release_conn()
        
        if downloaded_data == test_data:
            print("✓ Data integrity verified")
        else:
            print("✗ Data mismatch!")
            return False
        
        # 列出 objects
        print("\n>>> Listing objects...")
        objects = list(client.list_objects(bucket_name))
        print(f"✓ Found {len(objects)} object(s) in bucket")
        for obj in objects:
            print(f"   - {obj.object_name} ({obj.size} bytes)")
        
        # 获取 bucket 信息
        print("\n>>> Getting bucket info...")
        buckets = client.list_buckets()
        print(f"✓ Total buckets: {len(buckets)}")
        for bucket in buckets:
            print(f"   - {bucket.name} (created: {bucket.creation_date})")
        
        # 清理测试数据
        print("\n>>> Cleaning up test data...")
        client.remove_object(bucket_name, object_name)
        client.remove_bucket(bucket_name)
        print(f"✓ Test bucket '{bucket_name}' removed")
        
        return True
        
    except S3Error as e:
        print(f"❌ MinIO S3 Error: {e}")
        return False
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        print("   请确保 MinIO 服务器已启动")
        print("   启动命令: minio server /tmp/minio-data --address ':9000' --console-address ':9001'")
        return False

if __name__ == '__main__':
    print("=" * 50)
    print("MinIO Connection Test")
    print("=" * 50)
    print()
    print("Configuration:")
    print("  Endpoint: http://localhost:9000")
    print("  Access Key: minioadmin")
    print("  Secret Key: minioadmin")
    print()
    
    success = test_minio_connection()
    
    print()
    print("=" * 50)
    if success:
        print("All tests passed! ✅")
        print()
        print("Quick Start:")
        print("  Web Console: http://localhost:9001")
        print("  Username: minioadmin")
        print("  Password: minioadmin")
        sys.exit(0)
    else:
        print("Tests failed! ❌")
        sys.exit(1)
