class Myauction::HelpsController < Myauction::ApplicationController
  def index
    @helps = Help.where(target: 100).order(:order_no)
  end

  def show
    @helps = Help.where(target: 100).order(:order_no)

    @help  = Help.where(target: 100).find_by(uid: params[:id])
  end
end
