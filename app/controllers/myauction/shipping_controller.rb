class Myauction::ShippingController < Myauction::ApplicationController
  include Exports
  
  before_action :check_seller

  def index
    @labels  = ShippingLabel.where(user_id: current_user.id).order(:shipping_no)
    @fees    = ShippingFee.where(user_id: current_user.id)

    respond_to do |format|
      format.html
      format.csv { export_csv "shippings.csv" }
    end
  end


  def new
  end

  def create
    @res = ShippingFee.import(params[:file], current_user)

    redirect_to("/myauction/", notice: "送料設定をインポートしました")
  end

end
