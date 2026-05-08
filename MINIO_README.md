# MinIO 对象存储使用指南

## 📋 概述

本项目已配置 MinIO 对象存储服务器，可在 MyBinder 环境中使用。MinIO 提供 S3 兼容的对象存储服务。

## 🔑 认证信息

- **Access Key**: `minioadmin`
- **Secret Key**: `minioadmin`
- **API Endpoint**: `http://localhost:9000`
- **Console URL**: `http://localhost:9001`

## 🚀 快速开始

### 1. Web 控制台访问

在浏览器中打开：
```
http://localhost:9001
```

使用以下凭据登录：
- Username: `minioadmin`
- Password: `minioadmin`

### 2. 验证安装

```bash
# 检查 MinIO 进程
ps aux | grep minio

# 测试 API 健康状态
curl http://localhost:9000/minio/health/live

# 查看日志
cat /tmp/minio.log
```

## 💻 Python 使用示例

### 安装客户端

```bash
pip install minio
```

### 基本操作

```python
from minio import Minio
from minio.error import S3Error

# 创建客户端
client = Minio(
    "localhost:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False  # 使用 HTTP
)

# 创建 bucket
bucket_name = "my-bucket"
if not client.bucket_exists(bucket_name):
    client.make_bucket(bucket_name)
    print(f"Bucket '{bucket_name}' created")
else:
    print(f"Bucket '{bucket_name}' already exists")

# 上传文件
client.fput_object(
    bucket_name,
    "test-file.txt",
    "/path/to/local/file.txt"
)
print("File uploaded successfully")

# 下载文件
client.fget_object(
    bucket_name,
    "test-file.txt",
    "/path/to/download/file.txt"
)
print("File downloaded successfully")

# 列出所有 objects
objects = client.list_objects(bucket_name)
for obj in objects:
    print(f"Object: {obj.object_name}, Size: {obj.size} bytes")

# 删除文件
client.remove_object(bucket_name, "test-file.txt")
print("File deleted")

# 删除 bucket（必须先清空）
client.remove_bucket(bucket_name)
print("Bucket deleted")
```

### 上传字节数据

```python
from minio import Minio
import io

client = Minio(
    "localhost:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False
)

# 上传字符串
data = b"Hello, MinIO!"
client.put_object(
    "my-bucket",
    "hello.txt",
    io.BytesIO(data),
    length=len(data),
    content_type="text/plain"
)

# 读取对象
response = client.get_object("my-bucket", "hello.txt")
content = response.read()
print(content.decode('utf-8'))
response.close()
response.release_conn()
```

### 设置对象元数据

```python
from minio import Minio
from datetime import datetime
import io

client = Minio(
    "localhost:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False
)

metadata = {
    "Content-Type": "application/json",
    "x-amz-meta-author": "John Doe",
    "x-amz-meta-created": datetime.now().isoformat()
}

data = b'{"name": "test", "value": 123}'
client.put_object(
    "my-bucket",
    "data.json",
    io.BytesIO(data),
    length=len(data),
    metadata=metadata
)
```

## 🌐 JavaScript/Node.js 使用示例

### 安装 SDK

```bash
npm install minio
```

### 基本操作

```javascript
const Minio = require('minio');

// 创建客户端
const client = new Minio.Client({
    endPoint: 'localhost',
    port: 9000,
    useSSL: false,
    accessKey: 'minioadmin',
    secretKey: 'minioadmin'
});

// 创建 bucket
async function createBucket() {
    const bucketName = 'my-bucket';
    const exists = await client.bucketExists(bucketName);
    
    if (!exists) {
        await client.makeBucket(bucketName);
        console.log(`Bucket '${bucketName}' created`);
    } else {
        console.log(`Bucket '${bucketName}' already exists`);
    }
}

// 上传文件
async function uploadFile() {
    const bucketName = 'my-bucket';
    const objectName = 'test-file.txt';
    const filePath = '/path/to/local/file.txt';
    
    await client.fPutObject(bucketName, objectName, filePath);
    console.log('File uploaded successfully');
}

// 列出 objects
async function listObjects() {
    const bucketName = 'my-bucket';
    const stream = client.listObjects(bucketName, '', true);
    
    stream.on('data', (obj) => {
        console.log(`Object: ${obj.name}, Size: ${obj.size}`);
    });
    
    stream.on('error', (err) => {
        console.error('Error:', err);
    });
}

// 下载文件
async function downloadFile() {
    const bucketName = 'my-bucket';
    const objectName = 'test-file.txt';
    const filePath = '/path/to/download/file.txt';
    
    await client.fGetObject(bucketName, objectName, filePath);
    console.log('File downloaded successfully');
}

// 执行
createBucket()
    .then(() => uploadFile())
    .then(() => listObjects())
    .catch(console.error);
```

## 🔧 命令行工具 (mc)

### 安装 mc

```bash
# 通过 postBuild 或手动安装
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/
```

### 配置别名

```bash
# 添加 MinIO 服务器
mc alias set myminio http://localhost:9000 minioadmin minioadmin

# 验证连接
mc ls myminio
```

### 常用命令

```bash
# 创建 bucket
mc mb myminio/my-bucket

# 上传文件
mc cp localfile.txt myminio/my-bucket/

# 下载文件
mc cp myminio/my-bucket/localfile.txt ./

# 列出 bucket
mc ls myminio

# 列出 objects
mc ls myminio/my-bucket

# 删除文件
mc rm myminio/my-bucket/test-file.txt

# 删除 bucket
mc rb myminio/my-bucket

# 设置公开访问
mc policy set public myminio/my-bucket

# 查看 bucket 信息
mc stat myminio/my-bucket
```

## ⚙️ 配置说明

### 环境变量

MinIO 通过 `/tmp/minio.env` 配置文件：

```bash
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_VOLUMES=/tmp/minio-data
MINIO_CONSOLE_ADDRESS=:9001
```

### 修改认证信息

1. 编辑 `/tmp/minio.env`：
```bash
MINIO_ROOT_USER=your_username
MINIO_ROOT_PASSWORD=your_password
```

2. 重启 MinIO：
```bash
pkill minio
sleep 2
source /tmp/minio.env
minio server /tmp/minio-data --address ':9000' --console-address ':9001' > /tmp/minio.log 2>&1 &
```

### 数据持久化

- **数据目录**: `/tmp/minio-data`
- **注意**: MyBinder 容器重启后数据会丢失
- **建议**: 重要数据应导出或保存到外部服务

## 📊 监控和调试

### 查看日志

```bash
# 实时查看日志
tail -f /tmp/minio.log

# 查看最后 50 行
tail -n 50 /tmp/minio.log

# 搜索错误
grep -i "error\|fatal" /tmp/minio.log
```

### 健康检查

```bash
# API 健康状态
curl http://localhost:9000/minio/health/live

# 集群健康状态
curl http://localhost:9000/minio/health/cluster

# 就绪状态
curl http://localhost:9000/minio/health/ready
```

### 性能监控

```bash
# 查看 MinIO 进程
ps aux | grep minio

# 查看端口监听
netstat -tlnp | grep -E '9000|9001'

# 查看磁盘使用
du -sh /tmp/minio-data
```

## 🐛 故障排查

### MinIO 无法启动

```bash
# 检查日志
cat /tmp/minio.log

# 检查端口占用
netstat -tlnp | grep 9000

# 检查进程
ps aux | grep minio

# 手动启动测试
minio server /tmp/minio-data --address ':9000' --console-address ':9001'
```

### 连接失败

```bash
# 测试 API 连接
curl http://localhost:9000/minio/health/live

# 检查防火墙
iptables -L

# 验证认证信息
echo $MINIO_ROOT_USER
echo $MINIO_ROOT_PASSWORD
```

### Python 连接错误

```python
# 确保安装了 minio 包
pip install minio

# 测试连接
from minio import Minio
client = Minio(
    "localhost:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False
)
print(client.bucket_exists("test"))
```

## ⚠️ 注意事项

1. **数据持久性**: 
   - MyBinder 容器重启后，`/tmp` 目录的数据会丢失
   - 如需持久化，考虑使用外部 MinIO 服务（如 MinIO Cloud）

2. **安全性**: 
   - 默认凭证为 `minioadmin/minioadmin`
   - 生产环境务必修改为强密码
   - 启用 HTTPS/TLS

3. **资源限制**: 
   - MinIO 会占用一定内存和磁盘空间
   - 定期清理不需要的 bucket 和 objects

4. **端口占用**: 
   - API 端口: 9000
   - Console 端口: 9001
   - 确保没有其他服务占用这些端口

## 📚 参考资料

- [MinIO 官方文档](https://docs.min.io/)
- [MinIO Python SDK](https://docs.min.io/docs/python-client-quickstart-guide.html)
- [MinIO JavaScript SDK](https://docs.min.io/docs/javascript-client-quickstart-guide.html)
- [MinIO Client (mc)](https://docs.min.io/docs/minio-client-quickstart-guide.html)
- [S3 API 兼容性](https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置！
