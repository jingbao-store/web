# APK 下载 URL 修复

## 问题

应用详情页显示"暂无下载链接"，但后台已经上传了 APK 文件。API 返回的 `download_url` 显示为 `http://localhost:3000/...` 而不是 `https://jingbao.store/...`。

## 快速修复（生产环境）

### 1️⃣ 设置环境变量

在服务器上执行：

```bash
export PUBLIC_HOST=jingbao.store
```

### 2️⃣ 重启 Rails 应用

```bash
# 根据您的部署方式选择：

# 使用 systemd
sudo systemctl restart jingbao-webapp

# 或使用 Passenger
touch tmp/restart.txt

# 或使用 Puma
kill -USR2 $(cat tmp/pids/server.pid)
```

### 3️⃣ 验证修复

运行测试脚本：

```bash
cd /path/to/jingbao-webapp
RAILS_ENV=production bin/test-apk-urls
```

或手动测试 API：

```bash
curl https://jingbao.store/api/v1/applications/10 | jq '.download_url'
```

应该看到：

```json
"https://jingbao.store/rails/active_storage/blobs/..."
```

而不是：

```json
"http://localhost:3000/rails/active_storage/blobs/..."
```

## 永久修复

为了让配置持久化，选择以下方式之一：

### 方式 A: 使用 .env 文件

在项目根目录创建 `.env` 文件：

```bash
PUBLIC_HOST=jingbao.store
```

确保在启动 Rails 时加载此文件（使用 dotenv gem 或在启动脚本中 source）。

### 方式 B: 系统环境配置

**Ubuntu/Debian (systemd):**

编辑 `/etc/systemd/system/jingbao-webapp.service`：

```ini
[Service]
Environment="PUBLIC_HOST=jingbao.store"
```

然后重新加载：

```bash
sudo systemctl daemon-reload
sudo systemctl restart jingbao-webapp
```

**使用 ~/.bashrc 或 ~/.bash_profile:**

```bash
echo 'export PUBLIC_HOST=jingbao.store' >> ~/.bashrc
source ~/.bashrc
```

### 方式 C: Docker 配置

在 `docker-compose.yml` 中：

```yaml
services:
  web:
    environment:
      - PUBLIC_HOST=jingbao.store
```

## 代码修改总结

本次修复修改了以下文件：

### 1. `app/models/application.rb`

增强了 `final_download_url` 方法，确保正确生成完整 URL：

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

添加了备用 URL 构建方法：

```ruby
def build_full_url(path)
  # 手动构建完整 URL，确保包含正确的 host
end
```

### 2. `config/environments/production.rb`

添加了 ActiveStorage URL 配置：

```ruby
config.action_controller.default_url_options = host_and_port_and_protocol
config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

### 3. `config/environments/development.rb`

同样添加了开发环境的 URL 配置：

```ruby
config.action_controller.default_url_options = host_and_port_and_protocol
```

## 工作原理

1. **环境检测**: `lib/env_checker.rb` 读取 `PUBLIC_HOST` 环境变量
2. **URL 配置**: Rails 使用这个配置生成所有 URL
3. **APK URL**: `final_download_url` 方法生成 ActiveStorage blob URL
4. **API 响应**: 控制器使用 `final_download_url` 返回正确的下载链接

## 验证清单

修复完成后，请检查：

- [ ] `PUBLIC_HOST` 环境变量已设置
- [ ] Rails 应用已重启
- [ ] 运行 `bin/test-apk-urls` 脚本无错误
- [ ] API 返回正确的域名（`https://jingbao.store`）
- [ ] 网站前端显示"下载"按钮而不是"暂无下载链接"
- [ ] 点击下载链接可以正常下载 APK

## 测试示例

### 测试 1: 检查环境配置

```bash
RAILS_ENV=production rails console

# 在 console 中执行：
Rails.application.routes.default_url_options
# => {:host=>"jingbao.store", :port=>443, :protocol=>"https"}
```

### 测试 2: 检查应用 URL

```bash
RAILS_ENV=production rails console

# 在 console 中执行：
app = Application.find(10)
app.apk_file.attached?  # => true
app.final_download_url  # => "https://jingbao.store/rails/active_storage/blobs/..."
```

### 测试 3: 测试 API

```bash
curl https://jingbao.store/api/v1/applications/10 | jq
```

应该看到：

```json
{
  "id": 10,
  "name": "讯飞输入法",
  "download_url": "https://jingbao.store/rails/active_storage/blobs/redirect/xxx/xxx.apk",
  "file_size": "6.92 MB"
}
```

## 故障排查

### 问题：环境变量设置后仍然显示 localhost

**原因**: Rails 应用未重启或环境变量未正确加载

**解决**:
1. 确认环境变量存在: `echo $PUBLIC_HOST`
2. 重启 Rails 应用
3. 检查进程环境: `cat /proc/<PID>/environ | tr '\0' '\n' | grep PUBLIC_HOST`

### 问题：API 返回的 download_url 为 null

**原因**: APK 文件未成功上传或附加失败

**解决**:
1. 在 Rails console 中检查: `Application.find(10).apk_file.attached?`
2. 检查 `storage/` 目录权限: `chmod -R 755 storage/`
3. 查看 Rails 日志: `tail -f log/production.log`

### 问题：下载链接返回 404

**原因**: ActiveStorage 路由或文件权限问题

**解决**:
1. 检查路由: `RAILS_ENV=production rails routes | grep rails_blob`
2. 检查文件: `ls -la storage/`
3. 检查 web 服务器配置（Nginx/Apache）

## 相关文档

- [完整配置指南](docs/PRODUCTION_URL_CONFIG.md)
- [APK 上传功能说明](docs/APK_UPLOAD_FEATURE.md)
- [测试指南](docs/APK_UPLOAD_TEST_GUIDE.md)

## 注意事项

1. **必须重启**: 修改环境变量后必须重启 Rails 应用
2. **持久化**: 建议使用 systemd 或 .env 文件持久化配置
3. **安全性**: 确保 `storage/` 目录有正确的权限
4. **监控**: 建议添加监控检查 URL 生成是否正常

---

**最后更新**: 2025-11-17

如有问题，请查看详细文档或联系开发团队。

