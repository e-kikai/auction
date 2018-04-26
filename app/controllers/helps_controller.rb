class HelpsController < ApplicationController
  def index
    @helps = Help.where(target: 0).order(:order_no)
  end

  def show
    @helps = Help.where(target: 0).order(:order_no)

    @help  = Help.where(target: 0).find_by(uid: params[:id])
  end
end
