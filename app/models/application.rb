class Application < ApplicationRecord
  belongs_to :category

  validates :name, presence: true
  validates :package_name, presence: true, uniqueness: true
  validates :downloads, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true

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
end
