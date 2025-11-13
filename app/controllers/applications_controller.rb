class ApplicationsController < ApplicationController
  def index
    @categories = Category.ordered.includes(:applications)
    @applications = if params[:category_id].present?
                     Application.includes(:category).by_category(params[:category_id]).recent.page(params[:page]).per(12)
                   else
                     Application.includes(:category).recent.page(params[:page]).per(12)
                   end
    @selected_category = Category.find_by(id: params[:category_id])
  end

  def show
    @application = Application.includes(:category).find(params[:id])
  end

  private
end
