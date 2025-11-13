class Api::V1::ApplicationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    @applications = if params[:category_id].present?
                      Application.includes(:category).by_category(params[:category_id]).recent
                    else
                      Application.includes(:category).recent
                    end
    
    render json: @applications.as_json(
      only: [:id, :name, :package_name, :version, :description, :icon, :download_url, :file_size, :file_size_bytes, :developer, :rating, :downloads, :last_updated, :min_android_version],
      include: { category: { only: [:id, :name, :icon] } },
      methods: [:permissions_array, :features_array]
    )
  end

  def show
    @application = Application.includes(:category).find(params[:id])
    data = @application.as_json(
      only: [:id, :name, :package_name, :version, :description, :icon, :download_url, :file_size, :file_size_bytes, :developer, :rating, :downloads, :last_updated, :min_android_version, :created_at, :updated_at],
      include: { category: { only: [:id, :name, :slug, :icon] } },
      methods: [:permissions_array, :features_array]
    )
    data['icon'] = @application.icon_for_api
    data['screenshots'] = @application.screenshot_urls
    render json: data
  end
end
