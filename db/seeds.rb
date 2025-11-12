# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# IMPORTANT: Do NOT add Administrator data here!
# Administrator accounts should be created manually by user.
# This seeds file is only for application data (products, categories, etc.)

puts "🌱 Seeding database..."

# Clear existing data
puts "Clearing existing data..."
Application.destroy_all
Category.destroy_all

# Create categories based on jingbao-store structure
puts "Creating categories..."

categories_data = [
  { name: "游戏娱乐", icon: "🎮", description: "适配智能眼镜的游戏应用，提供沉浸式游戏体验", display_order: 1 },
  { name: "影音视频", icon: "🎬", description: "专为眼镜优化的视频播放和影音应用", display_order: 2 },
  { name: "阅读学习", icon: "📖", description: "电子书阅读和学习辅助应用", display_order: 3 },
  { name: "工具效率", icon: "🛠️", description: "提升效率的实用工具应用", display_order: 4 },
  { name: "运动健康", icon: "🏃", description: "运动追踪和健康管理应用", display_order: 5 },
  { name: "手机应用", icon: "📱", description: "可与眼镜搭配使用的手机应用，如蓝牙键盘、虚拟鼠标等配件类应用", display_order: 6 },
  { name: "创意设计", icon: "🎨", description: "图像处理和创意设计应用", display_order: 7 },
  { name: "社交网络", icon: "🌐", description: "社交通讯和网络应用", display_order: 8 }
]

categories = categories_data.map do |cat_data|
  category = Category.create!(cat_data)
  puts "  ✓ Created category: #{category.name}"
  category
end

# Create sample applications
puts "Creating sample applications..."

# Sample app for 游戏娱乐
game_category = categories.find { |c| c.name == "游戏娱乐" }
Application.create!([
  {
    name: "小蜜蜂游戏",
    package_name: "com.rokid.bee.game",
    version: "1.0.0",
    description: "经典的小蜜蜂射击游戏，完美适配智能眼镜，支持手势控制和语音操作。体验复古游戏的乐趣，享受全新的AR游戏体验。",
    icon: "🐝",
    download_url: "https://github.com/jingbao-store/releases/download/v1.0.0/bee-game.apk",
    file_size: "13 MB",
    file_size_bytes: 13631488,
    developer: "Rokid",
    rating: 4.5,
    downloads: 1250,
    last_updated: Date.today - 15.days,
    min_android_version: "8.0",
    permissions: ["网络访问", "存储权限"].to_json,
    features: ["手势控制", "语音操作", "多关卡挑战"].to_json,
    category: game_category
  },
  {
    name: "太空冒险",
    package_name: "com.jingbao.space.adventure",
    version: "2.1.0",
    description: "在浩瀚的宇宙中探险，驾驶飞船完成各种任务。支持3D视觉效果，为眼镜设备特别优化。",
    icon: "🚀",
    download_url: "https://example.com/space-adventure.apk",
    file_size: "25 MB",
    file_size_bytes: 26214400,
    developer: "Space Games Studio",
    rating: 4.8,
    downloads: 3420,
    last_updated: Date.today - 7.days,
    min_android_version: "9.0",
    permissions: ["网络访问", "存储权限", "传感器访问"].to_json,
    features: ["3D图形", "关卡系统", "成就系统"].to_json,
    category: game_category
  }
])

# Sample app for 影音视频
video_category = categories.find { |c| c.name == "影音视频" }
Application.create!([
  {
    name: "AR视频播放器",
    package_name: "com.jingbao.ar.player",
    version: "2.5.1",
    description: "专为智能眼镜优化的视频播放器，支持多种格式，字幕显示，手势控制播放进度。享受私人影院般的观影体验。",
    icon: "📺",
    download_url: "https://example.com/ar-player.apk",
    file_size: "18 MB",
    file_size_bytes: 18874368,
    developer: "AR Media Labs",
    rating: 4.6,
    downloads: 5680,
    last_updated: Date.today - 3.days,
    min_android_version: "8.0",
    permissions: ["存储权限", "网络访问"].to_json,
    features: ["多格式支持", "字幕显示", "手势控制", "播放列表"].to_json,
    category: video_category
  }
])

# Sample apps for 手机应用 (Phone companion apps)
phone_category = categories.find { |c| c.name == "手机应用" }
Application.create!([
  {
    name: "蓝牙键盘助手",
    package_name: "io.appground.blek",
    version: "1.2.0",
    description: "将您的手机变成蓝牙键盘，配合智能眼镜使用，提供便捷的文字输入体验。支持多种布局和快捷键设置。",
    icon: "⌨️",
    download_url: "https://play.google.com/store/apps/details?id=io.appground.blek",
    file_size: "8 MB",
    file_size_bytes: 8388608,
    developer: "AppGround",
    rating: 4.4,
    downloads: 12500,
    last_updated: Date.today - 20.days,
    min_android_version: "7.0",
    permissions: ["蓝牙", "网络访问"].to_json,
    features: ["多种键盘布局", "自定义快捷键", "手势支持"].to_json,
    category: phone_category
  },
  {
    name: "虚拟鼠标控制器",
    package_name: "com.jingbao.virtual.mouse",
    version: "3.0.2",
    description: "将手机变成无线鼠标和触摸板，配合眼镜实现精准的交互控制。支持手势操作和自定义按键。",
    icon: "🖱️",
    download_url: "https://example.com/virtual-mouse.apk",
    file_size: "6 MB",
    file_size_bytes: 6291456,
    developer: "JingBao Team",
    rating: 4.7,
    downloads: 8930,
    last_updated: Date.today - 10.days,
    min_android_version: "8.0",
    permissions: ["蓝牙", "网络访问"].to_json,
    features: ["触摸板模式", "手势操作", "按键自定义", "多设备支持"].to_json,
    category: phone_category
  },
  {
    name: "游戏手柄映射",
    package_name: "com.jingbao.gamepad.mapper",
    version: "1.5.0",
    description: "将手机变成游戏手柄，通过蓝牙连接眼镜，为游戏提供更好的操作体验。支持按键映射和震动反馈。",
    icon: "🎮",
    download_url: "https://example.com/gamepad-mapper.apk",
    file_size: "10 MB",
    file_size_bytes: 10485760,
    developer: "Gaming Tools",
    rating: 4.3,
    downloads: 6740,
    last_updated: Date.today - 12.days,
    min_android_version: "8.0",
    permissions: ["蓝牙", "震动", "网络访问"].to_json,
    features: ["按键映射", "震动反馈", "多种预设", "低延迟"].to_json,
    category: phone_category
  }
])

# Sample app for 工具效率
tools_category = categories.find { |c| c.name == "工具效率" }
Application.create!([
  {
    name: "AR录像工具",
    package_name: "com.jingbao.ar.recorder",
    version: "1.3.0",
    description: "专业的AR录像应用，记录您在智能眼镜中看到的一切。支持高清录制和实时预览。",
    icon: "📹",
    download_url: "https://example.com/ar-recorder.apk",
    file_size: "15 MB",
    file_size_bytes: 15728640,
    developer: "JingBao Tools",
    rating: 4.5,
    downloads: 4210,
    last_updated: Date.today - 5.days,
    min_android_version: "9.0",
    permissions: ["相机", "麦克风", "存储权限"].to_json,
    features: ["高清录制", "实时预览", "滤镜效果"].to_json,
    category: tools_category
  }
])

puts "✅ Seeding completed!"
puts "  - Created #{Category.count} categories"
puts "  - Created #{Application.count} applications"
puts ""
puts "Categories:"
Category.ordered.each do |cat|
  puts "  #{cat.icon} #{cat.name} (#{cat.applications.count} apps)"
end
