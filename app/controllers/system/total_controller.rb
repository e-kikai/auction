class System::TotalController < ApplicationController
  def index
    @date = params[:date] ? Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1) : Time.now

    @companies = User.companies.order(:id)
  end
end
