class Myauction::StarsController < Myauction::ApplicationController
  before_action :check_product, only: [ :edit, :update ]

  def edit
  end

  def update
    if @product.update(star_params)
      BidMailer.star_company(@product).deliver

      redirect_to "/myauction/bids?cond=2", notice: "#{@product.name}の受取確認と評価を行いました"
    else
      render :edit
    end
  end

  private

  def check_product
    @product = Product.status(Product::STATUS[:success]).find(params[:id])

    if @product.max_bid.user_id != current_user.id
      redirect_to "/myauction/bids?cond=2", notice: "#{@product.name}はあなたが落札した商品ではありません"
    end
  end

  def star_params
    params.require(:product).permit(:star)
  end
end
