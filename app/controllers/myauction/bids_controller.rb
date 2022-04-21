class Myauction::BidsController < Myauction::ApplicationController
  before_action :get_product, only: [:new, :create]

  def index
    @search    = current_user.bid_products.search(params[:q])
    @products  = @search.result

    @products = if params[:cond] == '2'
      @products.status(2).where(" products.max_bid_id = bids.id ").order(dulation_end: :desc)
    else
      @products.status(0).order(:dulation_end)
    end

    @pproducts = @products.page(params[:page]).per(10).preload(:product_images, :user, max_bid: :user)

    @popular_products = Product.related_products(@products).populars.limit(Product::NEW_MAX_COUNT)
  end

  def new
    @bid = @product.bids.new(bid_params)
    @bid.user = current_user
  end

  def create
    @bid = @product.bids.new(bid_params)
    @bid.user = current_user

    loser = @product.max_bid.try(:user)

    if @bid.save
      Abtest::finish(session[:utag], :search_sort_01) # ABテスト

      if @product.max_bid.try(:user) == current_user
        # 入札成功

        mes = if @product.finished?
          # 即売
          BidMailer.success_user(current_user, @product).deliver
          BidMailer.success_company(@product).deliver

          "おめでとうございます。あなたが落札しました。"
        else
          BidMailer.bid_loser(loser, @product).deliver if loser.present? && loser.id != current_user.id
          BidMailer.bid_user(current_user, @bid).deliver
          BidMailer.bid_company(@product).deliver

          "入札を行いました。現在あなたの入札が最高金額です。"
        end
        redirect_to "/myauction/bids/#{@bid.id}", notice: mes

      else
        # 入札失敗

        flash.now[:alert] = if @product.lower_price.present? && @product.max_bid_id.blank?
          # 最低落札価格に達していない
          "入札金額が最低落札価格に達していませんでした。再度入札お願いいたします。"
        else
          "あなたの入札より、自動入札が上回りました。"
        end

        @bid.amount = nil # 一度金額をクリア
        render :new
      end
    else
      render :new
    end
  end

  def show
    @bid = Bid.find(params[:id])

    ### 人気商品 ###
    # @popular_products = Product.related_products(@bid.product).populars.limit(Product::NEW_MAX_COUNT)
    @popular_products = Rails.cache.fetch("popular_#{@bid.product.id}_#{Product::NEW_MAX_COUNT}", expires_in: 1.day) do
      Product.related_products(@bid.product).populars.limit(Product::NEW_MAX_COUNT)
    end

    ### 似たものサーチ ###
    # @nitamono_products = @bid.product.nitamono(Product::NEW_MAX_COUNT)
    # @nitamono_products = Rails.cache.fetch("nitamono_#{@bid.product.id}_#{Product::NEW_MAX_COUNT}", expires_in: 1.day) do
    #   @bid.product.nitamono(Product::NEW_MAX_COUNT)
    # end
    @nitamono_products = @bid.product.nitamono_02.limit(Product::NEW_MAX_COUNT)

  end

  private

  def bid_params
    params.require(:bid).permit(:amount)
  end

  def get_product
    @product = Product.find(params[:id])

    # 自社入札の禁止
    if @product.user_id == current_user.id
      redirect_to "/products/#{@product.id}", alert: "自社の商品への入札は行なえません"
    elsif Blacklist.exists?(user_id: @product.user_id, to_user_id: current_user.id)
      redirect_to "/products/#{@product.id}", alert: "申し訳ありません。現在、この出品会社の商品への入札は行なえません"
    end
  end
end
