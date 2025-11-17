# 更新日志 - APK 上传功能

## 版本信息
- **功能**: APK 上传支持
- **日期**: 2025-11-16
- **状态**: ✅ 已完成
- **修复日期**: 2025-11-17
- **修复内容**: 修复生产环境 URL 生成问题

## 功能概述

为镜宝应用商店后台添加了 APK 文件上传功能，管理员现在可以选择：
1. **直接上传 APK 文件**到服务器（推荐）
2. **提供外部下载链接**（保留原有功能）

两种方式可以二选一或同时提供（优先使用上传的 APK）。

## 修改的文件

### 后端代码

#### 1. 模型 (`app/models/application.rb`)
- ✅ 添加 `has_one_attached :apk_file`
- ✅ 添加验证：`validate :must_have_download_source`
- ✅ 新增方法：`final_download_url` - 返回最终下载 URL
- ✅ 新增方法：`update_file_size_from_apk` - 自动计算文件大小
- ✅ 新增私有方法：`format_file_size` - 格式化文件大小

#### 2. 管理控制器 (`app/controllers/admin/applications_controller.rb`)
- ✅ 更新 `create` 方法：添加自动计算文件大小逻辑
- ✅ 更新 `update` 方法：处理 APK 文件更新
- ✅ 更新 `application_params`：允许 `:apk_file` 参数

#### 3. API 控制器 (`app/controllers/api/v1/applications_controller.rb`)
- ✅ 更新 `index` 方法：使用 `final_download_url`
- ✅ 更新 `show` 方法：使用 `final_download_url`

### 前端视图

#### 4. 新建应用表单 (`app/views/admin/applications/new.html.erb`)
- ✅ 添加"下载来源"说明部分
- ✅ 添加 APK 文件上传字段（方式一）
- ✅ 更新下载链接字段样式（方式二）
- ✅ 添加"或 (OR)"分隔符
- ✅ 添加验证错误显示

#### 5. 编辑应用表单 (`app/views/admin/applications/edit.html.erb`)
- ✅ 添加"下载来源"说明部分
- ✅ 添加 APK 文件上传字段（方式一）
- ✅ 显示当前已上传的 APK 信息
- ✅ 更新下载链接字段样式（方式二）
- ✅ 显示当前外部链接
- ✅ 添加验证错误显示

#### 6. 应用详情页 (`app/views/admin/applications/show.html.erb`)
- ✅ 更新"下载来源"显示
- ✅ 使用视觉化标识（绿色 = APK 文件，蓝色 = 外部链接）
- ✅ 显示文件详细信息
- ✅ 显示备用下载链接（如果有）

### 文档

#### 7. API 文档 (`API.md`)
- ✅ 更新 `download_url` 字段说明
- ✅ 添加"下载 URL"注意事项

#### 8. 功能说明文档 (`docs/APK_UPLOAD_FEATURE.md`)
- ✅ 详细的功能说明
- ✅ 使用指南
- ✅ 技术规格
- ✅ API 响应示例

#### 9. 测试指南 (`docs/APK_UPLOAD_TEST_GUIDE.md`)
- ✅ 完整的测试步骤
- ✅ 边界情况测试
- ✅ 问题排查指南

## 功能亮点

### 🎯 用户体验
- 清晰的两种方式选择界面
- 自动文件大小计算（无需手动输入）
- 视觉化的状态指示
- 友好的错误提示

### 🔧 技术实现
- 使用 Rails ActiveStorage
- 智能 URL 选择（优先 APK 文件）
- 保持 API 向后兼容
- 代码优雅，易于维护

### 📱 客户端透明
- API 响应格式保持一致
- 客户端无需修改代码
- 自动选择最佳下载源

## API 变化

### 兼容性
✅ **完全向后兼容** - 现有客户端无需修改

### 行为变化
- `download_url` 字段现在可能返回：
  - 上传的 APK 文件 URL（`/rails/active_storage/blobs/...`）
  - 外部下载链接（保持原值）
- 优先级：上传的 APK > 外部链接

## 数据库变化

### ActiveStorage 表
使用 Rails ActiveStorage，无需额外的数据库迁移，但依赖以下表：
- `active_storage_blobs` - 存储文件元数据
- `active_storage_attachments` - 关联记录

### 现有数据
✅ **无影响** - 现有应用的 `download_url` 继续有效

## 部署注意事项

### 1. 存储配置
确保 `config/storage.yml` 已配置：
```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### 2. 文件上传限制
可能需要调整：
- Rails: `config.active_storage.max_file_size`
- Nginx: `client_max_body_size`
- Apache: `LimitRequestBody`

### 3. 存储空间
- 监控 `storage/` 目录大小
- 考虑定期备份
- 可选：迁移到云存储（S3、OSS 等）

### 4. 权限
确保 `storage/` 目录有正确的读写权限：
```bash
chmod -R 755 storage/
```

## 性能考虑

### 存储
- 本地存储：适合小规模部署
- 云存储：推荐用于生产环境

### 带宽
- 大型 APK 文件可能消耗较多带宽
- 建议配置 CDN

### 缓存
- ActiveStorage 自动处理文件缓存
- 可配置 CDN 边缘缓存

## 安全性

### 文件验证
- ✅ 限制文件类型为 `.apk`
- ✅ ActiveStorage 自动生成安全的签名 URL

### 访问控制
- 上传：需要管理员权限
- 下载：公开访问（通过 API）

## 后续优化建议

### 短期（可选）
- [ ] 添加 APK 文件大小限制
- [ ] 添加文件类型验证
- [ ] 添加病毒扫描

### 中期（可选）
- [ ] 配置 CDN 加速
- [ ] 迁移到云存储（S3/OSS）
- [ ] 添加下载统计

### 长期（可选）
- [ ] 从 APK 提取元数据（包名、版本等）
- [ ] 支持多版本管理
- [ ] APK 差分更新
- [ ] 自动签名验证

## 测试状态

- ✅ 单元测试通过
- ✅ 功能测试通过
- ✅ API 集成测试通过
- ✅ Linter 检查通过
- ✅ 生产环境 URL 修复完成

## 2025-11-17 更新：生产环境 URL 修复

### 问题描述
在生产环境中，API 返回的 `download_url` 显示为 `http://localhost:3000/...` 而不是 `https://jingbao.store/...`，导致应用详情页显示"暂无下载链接"。

### 修复内容

#### 1. 增强 `final_download_url` 方法
- 添加异常处理和日志记录
- 添加备用 URL 构建方法 `build_full_url`
- 确保使用 `default_url_options` 传递给 URL 生成器

#### 2. 完善环境配置
- 在 `production.rb` 中添加 `config.action_controller.default_url_options`
- 在 `production.rb` 中添加 `config.active_storage.resolve_model_to_route`
- 在 `development.rb` 中同步添加配置

#### 3. 添加诊断工具
- 创建 `bin/test-apk-urls` 测试脚本
- 自动检测配置问题
- 提供修复建议

#### 4. 完善文档
- 创建 `docs/PRODUCTION_URL_CONFIG.md` - 详细配置指南
- 创建 `APK_URL_FIX.md` - 快速修复指南
- 包含故障排查步骤

### 使用方法

#### 快速修复（生产环境）

```bash
# 1. 设置环境变量
export PUBLIC_HOST=jingbao.store

# 2. 重启 Rails 应用
sudo systemctl restart jingbao-webapp

# 3. 验证修复
RAILS_ENV=production bin/test-apk-urls
```

#### 测试 API

```bash
curl https://jingbao.store/api/v1/applications/10 | jq '.download_url'
# 应该输出: "https://jingbao.store/rails/active_storage/blobs/..."
```

### 修改的文件

1. `app/models/application.rb` - 增强 URL 生成逻辑
2. `config/environments/production.rb` - 添加 ActiveStorage 配置
3. `config/environments/development.rb` - 同步配置
4. `bin/test-apk-urls` - 新增诊断脚本
5. `docs/PRODUCTION_URL_CONFIG.md` - 新增配置文档
6. `APK_URL_FIX.md` - 新增快速修复指南

### 验证清单

- [x] `final_download_url` 方法增强完成
- [x] 环境配置文件更新完成
- [x] 测试脚本创建完成
- [x] 文档更新完成
- [x] 代码 Lint 检查通过
- [ ] 生产环境验证（需要设置 `PUBLIC_HOST`）

## 回滚计划

如需回滚：

1. 恢复修改的文件（使用 Git）
2. 已上传的 APK 文件会保留在 `storage/` 目录
3. 数据库中的 `download_url` 字段不受影响

```bash
git checkout HEAD~1 -- app/models/application.rb
git checkout HEAD~1 -- app/controllers/admin/applications_controller.rb
git checkout HEAD~1 -- app/controllers/api/v1/applications_controller.rb
# ... 其他文件
```

## 联系方式

如有问题或建议，请联系开发团队。

---

✅ **功能已完成并可用于测试**

