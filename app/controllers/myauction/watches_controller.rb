class Myauction::WatchesController <  Myauction::ApplicationController
  def index
    @search    = current_user.watch_products.search(params[:q])

    @products  = @search.result

    @products = if params[:result].present?
      @products.where("dulation_end <= now()").order(:dulation_end)
    else
      @products.where("dulation_end > now()").order(dulation_end: :desc)
    end

    @pproducts = @products.page(params[:page]).preload(:user, :product_images, max_bid: :user)
  end

  def create
    @watch = current_user.watches.new(product_id: params[:id])
    if @watch.save
      redirect_to "/myauction/watches", notice: "ウォッチリストに登録しました"
    else
      redirect_to "/myauction/watches", alert: "既にウォッチリストに登録されています"
    end
  end

  def destroy
    @watch = current_user.watches.find_by(product_id: params[:id])
    @watch.soft_destroy!
    redirect_to "/myauction/watches/", notice: "ウォッチリストから商品を削除しました"
  end
end
