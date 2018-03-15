class CompaniesController < ApplicationController
  def show
    @company = User.companies.find(params[:id])
  end
end
