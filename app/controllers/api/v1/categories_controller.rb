class Api::V1::CategoriesController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    @categories = Category.ordered.includes(:applications)
    render json: @categories.map { |category|
      {
        id: category.id,
        name: category.name,
        slug: category.slug,
        icon: category.icon,
        description: category.description,
        display_order: category.display_order,
        applications: category.applications.map { |app|
          {
            id: app.id,
            name: app.name,
            icon: app.icon_for_api
          }
        }
      }
    }
  end

  def show
    @category = Category.friendly.find(params[:id])
    render json: {
      id: @category.id,
      name: @category.name,
      slug: @category.slug,
      icon: @category.icon,
      description: @category.description,
      display_order: @category.display_order,
      applications: @category.applications.map { |app|
        {
          id: app.id,
          name: app.name,
          package_name: app.package_name,
          version: app.version,
          description: app.description,
          icon: app.icon_for_api,
          download_url: app.download_url,
          file_size: app.file_size,
          file_size_bytes: app.file_size_bytes,
          developer: app.developer,
          rating: app.rating,
          downloads: app.downloads,
          last_updated: app.last_updated,
          min_android_version: app.min_android_version,
          permissions_array: app.permissions_array,
          features_array: app.features_array
        }
      }
    }
  end
end
