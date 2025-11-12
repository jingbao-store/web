class Api::V1::CategoriesController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    @categories = Category.ordered.includes(:applications)
    render json: @categories.as_json(
      only: [:id, :name, :slug, :icon, :description, :display_order],
      include: {
        applications: {
          only: [:id, :name, :package_name, :version, :icon, :download_url, :file_size, :file_size_bytes, :rating, :downloads]
        }
      }
    )
  end

  def show
    @category = Category.friendly.find(params[:id])
    render json: @category.as_json(
      only: [:id, :name, :slug, :icon, :description, :display_order],
      include: {
        applications: {
          only: [:id, :name, :package_name, :version, :description, :icon, :download_url, :file_size, :file_size_bytes, :developer, :rating, :downloads, :last_updated, :min_android_version],
          methods: [:permissions_array, :features_array]
        }
      }
    )
  end
end
