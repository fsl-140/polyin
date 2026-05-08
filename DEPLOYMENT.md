# 保利管道库存管理系统 - 部署文档

## 📋 系统要求

### 硬件要求
- **CPU**: 2核及以上
- **内存**: 4GB 及以上（推荐 8GB）
- **硬盘**: 10GB 可用空间
- **网络**: 支持 HTTP/HTTPS 访问

### 软件要求
- **操作系统**: Windows 7/8/10/11 或 Windows Server 2012+
- **Java**: JDK 8 或 JDK 11（推荐 AdoptOpenJDK 或 Oracle JDK）
- **MySQL**: 5.7 或 8.0+
- **Maven**: 3.6+（仅编译时需要，运行不需要）

---

## 🚀 快速部署

### 方式一：使用部署脚本（推荐）

```batch
# 1. 双击运行部署脚本
deploy.bat

# 2. 按照提示输入 MySQL root 密码

# 3. 部署完成后，使用启动脚本启动
start.bat
```

### 方式二：手动部署

#### 1. 安装 Java 环境

```powershell
# 下载并安装 JDK 8 或 JDK 11
# 推荐下载地址：
# - AdoptOpenJDK: https://adoptium.net/
# - Oracle JDK: https://www.oracle.com/java/technologies/downloads/

# 验证安装
java -version
```

#### 2. 安装 MySQL 数据库

```powershell
# 下载并安装 MySQL 5.7 或 8.0
# 推荐下载地址：https://dev.mysql.com/downloads/mysql/

# 验证安装
mysql --version
```

#### 3. 初始化数据库

```powershell
# 登录 MySQL
mysql -u root -p

# 执行初始化脚本
source sql/init.sql
source sql/user.sql
source sql/supplier.sql
source sql/optimize_indexes.sql

# 或使用命令行
mysql -u root -p < sql\init.sql
mysql -u root -p < sql\user.sql
mysql -u root -p < sql\supplier.sql
mysql -u root -p < sql\optimize_indexes.sql
```

#### 4. 修改配置文件

编辑 `src\main\resources\application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/polyin_inventory?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: root          # 修改为实际的用户名
    password: your_password # 修改为实际的密码

# 生产环境建议修改
logging:
  level:
    com.polyin.inventory: info  # 改为 info 级别
```

#### 5. 打包应用

```powershell
cd f:\ai\polyin-inventory
mvn clean package -DskipTests
```

#### 6. 启动服务

```powershell
# 方式一：使用启动脚本
start.bat

# 方式二：直接运行
java -jar -Xms256m -Xmx512m target\polyin-inventory.jar

# 方式三：后台运行（无控制台窗口）
start /b java -jar -Xms256m -Xmx512m target\polyin-inventory.jar
```

---

## 🔧 生产环境配置

### 1. 创建 Windows 服务（推荐）

使用 [WinSW](https://github.com/winsw/winsw) 将应用注册为 Windows 服务：

#### 安装 WinSW
```powershell
# 下载 WinSW
# https://github.com/winsw/winsw/releases

# 重命名为 winsw.exe 并放到应用目录
```

#### 创建服务配置文件 `polyin-inventory.xml`

```xml
<service>
  <id>polyin-inventory</id>
  <name>保利管道库存管理系统</name>
  <description>保利管道个体经营户商品入库出库管理系统</description>
  <executable>java</executable>
  <arguments>-jar -Xms512m -Xmx1024m "%BASE%\target\polyin-inventory.jar"</arguments>
  <log mode="roll"></log>
  <startmode>Automatic</startmode>
</service>
```

#### 注册服务

```powershell
# 安装服务
winsw.exe install

# 启动服务
net start polyin-inventory

# 停止服务
net stop polyin-inventory

# 卸载服务
winsw.exe uninstall
```

### 2. 配置防火墙

```powershell
# 允许 8082 端口通过防火墙（以管理员身份运行）
netsh advfirewall firewall add rule name="Polyin Inventory" dir=in action=allow protocol=TCP localport=8082
```

### 3. 配置 HTTPS（可选但推荐）

如果需要 HTTPS 访问，需要：

1. 申请 SSL 证书（Let's Encrypt 免费）
2. 修改 `application.yml`：

```yaml
server:
  port: 8443
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: your_password
    key-store-type: PKCS12
```

### 4. 配置反向代理（可选）

如果使用 Nginx 反向代理：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 📊 数据库配置

### 创建专用数据库用户（推荐）

```sql
-- 登录 MySQL
mysql -u root -p

-- 创建专用用户
CREATE USER 'polyin'@'localhost' IDENTIFIED BY 'your_secure_password';

-- 授权
GRANT ALL PRIVILEGES ON polyin_inventory.* TO 'polyin'@'localhost';

-- 刷新权限
FLUSH PRIVILEGES;
```

然后修改 `application.yml`：

```yaml
spring:
  datasource:
    username: polyin
    password: your_secure_password
```

### 数据库备份

```powershell
# 创建备份脚本 backup.bat
@echo off
set BACKUP_DIR=D:\backups\polyin_inventory
set MYSQL_USER=root
set MYSQL_PASSWORD=your_password

md %BACKUP_DIR% 2>nul

mysqldump -u %MYSQL_USER% -p%MYSQL_PASSWORD% polyin_inventory > %BACKUP_DIR%\backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.sql

echo 备份完成：%BACKUP_DIR%
```

---

## 🔍 监控与维护

### 1. 查看日志

```powershell
# 如果使用 start.bat，日志会显示在控制台

# 如果注册为 Windows 服务，日志位置：
# C:\path\to\app\logs\
```

### 2. 健康检查

```powershell
# 检查服务是否运行
curl http://localhost:8082

# 或使用浏览器访问
# http://localhost:8082
```

### 3. 性能调优

修改 JVM 参数（在 start.bat 中）：

```batch
# 根据服务器配置调整内存
java -jar -Xms512m -Xmx2048m target\polyin-inventory.jar
```

### 4. 日志级别调整

生产环境建议修改 `application.yml`：

```yaml
logging:
  level:
    com.polyin.inventory: info  # 开发环境用 debug，生产用 info
    com.polyin.inventory.**.dao: info  # 关闭 SQL 日志
```

---

## ⚠️ 注意事项

### 安全建议
1. ✅ 修改默认数据库密码
2. ✅ 修改默认管理员密码（admin/admin123）
3. ✅ 生产环境启用 HTTPS
4. ✅ 配置防火墙，只开放必要端口
5. ✅ 定期备份数据库
6. ✅ 不要将配置文件中的密码提交到版本控制

### 性能建议
1. ✅ 生产环境关闭 debug 日志
2. ✅ 配置数据库连接池（默认使用 HikariCP）
3. ✅ 根据服务器配置调整 JVM 内存
4. ✅ 定期清理日志文件

### 常见问题

**Q: 端口被占用怎么办？**
```yaml
# 修改 application.yml 中的端口
server:
  port: 8083  # 改为其他端口
```

**Q: 如何后台运行？**
```powershell
# Windows
start /b java -jar target\polyin-inventory.jar

# 或注册为 Windows 服务（推荐）
```

**Q: 如何查看运行日志？**
```powershell
# 如果前台运行，直接看控制台
# 如果使用 WinSW，日志在应用目录的 logs 文件夹
```

---

## 📞 技术支持

- **API 文档**: http://localhost:8082/doc.html
- **默认账号**: admin / admin123
- **系统端口**: 8082（可配置）

---

## 📝 更新日志

- **v1.0.0** (2026-04-15)
  - 初始版本发布
  - 支持商品管理、入库管理、出库管理
  - 支持供应商管理、用户管理
  - 支持销售单导出（Excel）
  - 接口参数校验
  - 数据库索引优化
