class Myauction::DetailLogsController < Myauction::ApplicationController
  def index
    @detail_logs = DetailLog.joins(:product).includes(product: [:user, :product_images])
      .where.not(r: ["reload", "back"]).where(products: {template: false})
      .merge(DetailLog.where(user_id: current_user&.id).or(DetailLog.where(utag: session[:utag])))
      .reorder(id: :desc)

    @pdetail_logs = @detail_logs.page(params[:page]).per(50)

    ###  閲覧履歴に基づくオススメ ###
    @dl_osusume  = Product.osusume("dl_osusume", {user_id: current_user&.id}).limit(Product::NEW_MAX_COUNT)
  end
end
