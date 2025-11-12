class Admin::ApplicationsController < Admin::BaseController
  before_action :set_application, only: [:show, :edit, :update, :destroy]

  def index
    @applications = Application.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @application = Application.new
  end

  def create
    @application = Application.new(application_params)

    if @application.save
      redirect_to admin_application_path(@application), notice: 'Application was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @application.update(application_params)
      redirect_to admin_application_path(@application), notice: 'Application was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @application.destroy
    redirect_to admin_applications_path, notice: 'Application was successfully deleted.'
  end

  private

  def set_application
    @application = Application.find(params[:id])
  end

  def application_params
    params.require(:application).permit(:name, :package_name, :version, :description, :icon, :download_url, :file_size, :file_size_bytes, :developer, :rating, :downloads, :last_updated, :min_android_version, :permissions, :features, :category_id)
  end
end
