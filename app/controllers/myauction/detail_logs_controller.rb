class Myauction::DetailLogsController < Myauction::ApplicationController
  def index
    @products = Product.includes(:product_images).joins(:detail_logs)
      .select("products.*, detail_logs.created_at as ca")
      .reorder("detail_logs.id DESC")
      .where.not(detail_logs: {r: ["reload", "back"]})
      .where(detail_logs: {user_id: current_user.id})

      @dl_osusume  = Product.osusume("dl_osusume", {user_id: current_user.id})
        .limit(Product::NEWS_LIMIT) # 閲覧履歴に基づくオススメ

    @pproducts = @products.page(params[:page]).per(50)
  end
end
