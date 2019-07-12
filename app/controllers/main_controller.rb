class MainController < ApplicationController
  def index
    # if Time.now < DateTime.parse("2018/05/15 00:00:00")
    #   redirect_to "/lp/index.html"
    # end

    @roots = Category.roots.order(:order_no)

    # 最近チェックした商品
    where_query = user_signed_in? ? {user_id: current_user.id} : {ip: ip}

    detaillog_ids = DetailLog.order(id: :desc).limit(Product::NEW_MAX_COUNT).select(:product_id).where(where_query)
    @detaillog_products = Product.includes(:product_images).where(id: detaillog_ids)

    # チェックした商品の関連商品

    # フォローした出品会社の新着
    if user_signed_in?
      if follows_user_ids = current_user.follows.pluck(:user_id)
        @follows_new_products = Product.status(Product::STATUS[:start]).includes(:product_images).where(user_id: follows_user_ids).reorder(dulation_start: :desc).limit(Product::NEW_MAX_COUNT)
      end
    end


    # 新着
    @new_products = Product.status(Product::STATUS[:start]).includes(:product_images).reorder(dulation_start: :desc).limit(Product::NEW_MAX_COUNT)

    # トップページ公開検索条件
    @searches = Search.where(publish: true).order("RANDOM()").limit(Search::TOPPAGE_COUNT)

    # ヘルプ
    @helps = Help.where(target: 0).order(:order_no).limit(10)
    @infos = Info.where(target: 0).order(start_at: :desc).limit(10)

  end

  def rss
    # 新着
    @products = Product.status(Product::STATUS[:start]).includes(:product_images, :category).search(news_week: Time.now.strftime("%F")).result.reorder(dulation_start: :desc)

    # 新着メール用
    @products = @products.reorder("RANDOM()").limit(9) if params[:mail]

    respond_to do |format|
      format.rss
    end
  end
end
