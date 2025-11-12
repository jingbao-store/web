FactoryBot.define do
  factory :application do

    name { "MyString" }
    package_name { "MyString" }
    version { "MyString" }
    description { "MyText" }
    icon { "MyString" }
    download_url { "MyString" }
    file_size { "MyString" }
    file_size_bytes { nil }
    developer { "MyString" }
    rating { 4.5 }
    downloads { 1 }
    last_updated { Date.today }
    min_android_version { "MyString" }
    permissions { "MyText" }
    features { "MyText" }
    association :category

  end
end
