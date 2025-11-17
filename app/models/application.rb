class Application < ApplicationRecord
  belongs_to :category
  
  has_one_attached :icon
  has_many_attached :screenshots
  has_one_attached :apk_file

  validates :name, presence: true
  validates :package_name, presence: true, uniqueness: true
  validates :downloads, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validate :must_have_download_source

  scope :recent, -> { order(last_updated: :desc, created_at: :desc) }
  scope :popular, -> { order(downloads: :desc) }
  scope :top_rated, -> { where.not(rating: nil).order(rating: :desc) }
  scope :by_category, ->(category) { where(category: category) }

  def permissions_array
    permissions.present? ? JSON.parse(permissions) : []
  rescue JSON::ParserError
    []
  end

  def features_array
    features.present? ? JSON.parse(features) : []
  rescue JSON::ParserError
    []
  end

  def permissions_array=(value)
    self.permissions = value.to_json if value.is_a?(Array)
  end

  def features_array=(value)
    self.features = value.to_json if value.is_a?(Array)
  end


  # 返回截图的相对路径数组，供 API 使用
  def screenshot_urls
    return [] unless screenshots.attached?
    screenshots.map { |shot| Rails.application.routes.url_helpers.rails_blob_path(shot, only_path: true) }
  end

  # 返回应用图标：优先 ActiveStorage 路径，否则回退为数据库中的 icon 字段
  def icon_for_api
    if self.icon.respond_to?(:attached?) && self.icon.attached?
      Rails.application.routes.url_helpers.rails_blob_path(self.icon, only_path: true)
    else
      self[:icon]
    end
  end

  # 返回最终的下载 URL：优先使用上传的 APK 文件，否则使用 download_url 字段
  def final_download_url
    if apk_file.attached?
      # 使用 ActiveStorage 的 URL 生成器，确保包含完整的 host 信息
      begin
        url_options = Rails.application.routes.default_url_options
        Rails.application.routes.url_helpers.rails_blob_url(apk_file, **url_options)
      rescue => e
        Rails.logger.error("Error generating APK URL: #{e.message}")
        # 如果生成失败，尝试使用相对路径并手动构建完整 URL
        path = Rails.application.routes.url_helpers.rails_blob_path(apk_file, only_path: true)
        build_full_url(path)
      end
    else
      download_url
    end
  end

  # 自动计算并更新文件大小（当 APK 文件上传时）
  def update_file_size_from_apk
    return unless apk_file.attached?
    
    self.file_size_bytes = apk_file.byte_size
    self.file_size = format_file_size(file_size_bytes)
  end

  private

  # 验证：必须有下载来源（APK 文件或下载 URL）
  def must_have_download_source
    if !apk_file.attached? && download_url.blank?
      errors.add(:base, "必须提供 APK 文件或下载 URL 其中之一")
    end
  end

  # 格式化文件大小
  def format_file_size(bytes)
    return "0 B" if bytes.nil? || bytes == 0
    
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    exponent = (Math.log(bytes) / Math.log(1024)).floor
    exponent = [exponent, units.length - 1].min
    
    size = bytes.to_f / (1024 ** exponent)
    
    if size >= 100
      "#{size.round(0).to_i} #{units[exponent]}"
    elsif size >= 10
      "#{size.round(1)} #{units[exponent]}"
    else
      "#{size.round(2)} #{units[exponent]}"
    end
  end

  # 构建完整的 URL（用于 APK 文件）
  def build_full_url(path)
    return path if path.blank? || path.start_with?('http')
    
    url_options = Rails.application.routes.default_url_options
    protocol = url_options[:protocol] || 'https'
    host = url_options[:host] || 'localhost'
    port = url_options[:port]
    
    # 构建基础 URL
    base_url = "#{protocol}://#{host}"
    
    # 只在非标准端口时添加端口号（http 的 80 和 https 的 443 是标准端口）
    if port && !((protocol == 'https' && port == 443) || (protocol == 'http' && port == 80))
      base_url += ":#{port}"
    end
    
    "#{base_url}#{path}"
  end
end
