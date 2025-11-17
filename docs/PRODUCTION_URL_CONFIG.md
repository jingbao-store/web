# 生产环境 URL 配置指南

## 问题描述

当 APK 文件上传后，API 返回的 `download_url` 显示为 `http://localhost:3000/...` 而不是生产环境的域名 `https://jingbao.store/...`。

## 原因分析

Rails 在生成 URL 时需要知道应用的 host、port 和 protocol 信息。这些信息通过环境变量 `PUBLIC_HOST` 来配置。

## 解决方案

### 1. 设置环境变量

在生产环境中设置 `PUBLIC_HOST` 环境变量：

```bash
export PUBLIC_HOST=jingbao.store
```

### 2. 配置选项

根据您的部署方式选择：

#### 选项 A: 使用环境变量文件

创建或编辑 `.env` 文件（在项目根目录）：

```bash
# .env
PUBLIC_HOST=jingbao.store
```

#### 选项 B: 在系统环境中设置

在服务器的环境配置中添加：

**对于 systemd 服务：**

编辑服务文件（如 `/etc/systemd/system/jingbao-webapp.service`）：

```ini
[Service]
Environment="PUBLIC_HOST=jingbao.store"
```

**对于 Docker：**

在 `docker-compose.yml` 中：

```yaml
services:
  web:
    environment:
      - PUBLIC_HOST=jingbao.store
```

或使用 `docker run`：

```bash
docker run -e PUBLIC_HOST=jingbao.store ...
```

**对于 Capistrano 部署：**

在 `config/deploy/production.rb` 中：

```ruby
set :default_env, {
  'PUBLIC_HOST' => 'jingbao.store'
}
```

#### 选项 C: 直接在 shell 配置中

编辑 `~/.bashrc` 或 `~/.zshrc`：

```bash
export PUBLIC_HOST=jingbao.store
```

然后重新加载：

```bash
source ~/.bashrc  # 或 source ~/.zshrc
```

### 3. 验证配置

#### 3.1 检查环境变量

在 Rails console 中验证：

```bash
# 进入生产环境 console
RAILS_ENV=production rails console

# 检查配置
Rails.application.routes.default_url_options
# 应该输出: {:host=>"jingbao.store", :port=>443, :protocol=>"https"}
```

#### 3.2 测试 URL 生成

在 Rails console 中测试：

```ruby
# 获取一个有 APK 文件的应用
app = Application.find(10)

# 检查是否有 APK 附件
app.apk_file.attached?
# 应该返回: true

# 生成下载 URL
app.final_download_url
# 应该返回: "https://jingbao.store/rails/active_storage/blobs/..."
```

#### 3.3 测试 API 响应

```bash
curl https://jingbao.store/api/v1/applications/10 | jq '.download_url'
# 应该返回: "https://jingbao.store/rails/active_storage/blobs/..."
```

### 4. 重启应用

设置环境变量后，需要重启 Rails 应用：

```bash
# 如果使用 systemd
sudo systemctl restart jingbao-webapp

# 如果使用 Passenger
touch tmp/restart.txt

# 如果使用 Puma 直接运行
kill -USR2 $(cat tmp/pids/server.pid)

# 如果使用 Docker
docker-compose restart web
```

## 工作原理

### 代码实现

在 `lib/env_checker.rb` 中：

```ruby
def get_public_host_and_port_and_protocol
  if ENV['PUBLIC_HOST'].present?
    return { host: ENV.fetch('PUBLIC_HOST'), port: 443, protocol: 'https' }
  end
  
  # 回退到 localhost（仅开发环境）
  return { host: 'localhost', port: 3000, protocol: 'http' }
end
```

在 `config/environments/production.rb` 中：

```ruby
host_and_port_and_protocol = EnvChecker.get_public_host_and_port_and_protocol
Rails.application.routes.default_url_options = host_and_port_and_protocol
config.action_controller.default_url_options = host_and_port_and_protocol
```

在 `app/models/application.rb` 中：

```ruby
def final_download_url
  if apk_file.attached?
    url_options = Rails.application.routes.default_url_options
    Rails.application.routes.url_helpers.rails_blob_url(apk_file, **url_options)
  else
    download_url
  end
end
```

## 故障排查

### 问题 1: 环境变量未生效

**症状**: 设置了 `PUBLIC_HOST` 但 URL 仍然是 `localhost`

**解决**:
1. 确认环境变量在 Rails 进程中可见：
   ```bash
   ps aux | grep rails
   cat /proc/<PID>/environ | tr '\0' '\n' | grep PUBLIC_HOST
   ```

2. 确保重启了 Rails 应用

3. 检查日志中的配置：
   ```bash
   tail -f log/production.log
   ```

### 问题 2: URL 生成错误

**症状**: `download_url` 返回 `nil` 或空值

**解决**:
1. 检查 APK 文件是否真的已上传：
   ```ruby
   app = Application.find(10)
   app.apk_file.attached?  # 应该返回 true
   app.apk_file.filename   # 应该显示文件名
   ```

2. 检查 Rails 日志：
   ```bash
   tail -f log/production.log | grep "Error generating APK URL"
   ```

3. 检查 ActiveStorage 配置：
   ```bash
   # 在 Rails console 中
   Rails.application.config.active_storage.service
   # 应该是 :local 或配置的云存储服务
   ```

### 问题 3: 下载链接 404 错误

**症状**: URL 生成正确，但访问时返回 404

**可能原因**:
1. ActiveStorage 路由未正确配置
2. Nginx/Apache 配置问题
3. 文件权限问题

**解决**:
1. 检查 Rails 路由：
   ```bash
   RAILS_ENV=production rails routes | grep rails_blob
   ```

2. 检查文件是否存在：
   ```bash
   ls -la storage/
   ```

3. 检查文件权限：
   ```bash
   chmod -R 755 storage/
   chown -R deploy:deploy storage/
   ```

## 快速修复命令

如果您现在就需要修复生产环境：

```bash
# 1. 设置环境变量
echo "export PUBLIC_HOST=jingbao.store" >> ~/.bashrc
source ~/.bashrc

# 2. 或者在当前会话中
export PUBLIC_HOST=jingbao.store

# 3. 重启 Rails（根据您的部署方式选择）
# 使用 systemd
sudo systemctl restart jingbao-webapp

# 或使用 Passenger
touch /path/to/jingbao-webapp/tmp/restart.txt

# 4. 验证
RAILS_ENV=production rails console
# 然后在 console 中运行:
Rails.application.routes.default_url_options
# 应该看到: {:host=>"jingbao.store", :port=>443, :protocol=>"https"}
```

## 测试清单

配置完成后，请执行以下测试：

- [ ] 环境变量已设置并可见
- [ ] Rails 应用已重启
- [ ] `Rails.application.routes.default_url_options` 返回正确的 host
- [ ] API 返回的 `download_url` 使用正确的域名
- [ ] 可以通过返回的 URL 下载 APK 文件
- [ ] 网站前端可以正常显示下载链接

## 相关文件

- `lib/env_checker.rb` - 环境变量检查和获取
- `config/environments/production.rb` - 生产环境配置
- `app/models/application.rb` - URL 生成逻辑
- `app/controllers/api/v1/applications_controller.rb` - API 控制器

## 参考链接

- [Rails URL Generation Guide](https://guides.rubyonrails.org/routing.html#generating-urls)
- [ActiveStorage Overview](https://guides.rubyonrails.org/active_storage_overview.html)

---

**注意**: 设置环境变量后，请务必重启 Rails 应用才能生效。如有问题，请检查 Rails 日志文件。

