class Myauction::ProductsController < Myauction::ApplicationController
  before_action :get_product,        only: [:edit, :update, :destroy]

  def index
    # respond_to do |format|
    #   format.html
    #   format.csv {
    #     if params[:output] == "import"
    #       export_csv "update_products.csv", "/bid/products/import.csv"
    #     else
    #       export_csv "products.csv", "/bid/products/index.csv"
    #     end
    #   }
    # end
    @search    = current_user.products.status(params[:cond]).search(params[:q])

    @products  = @search.result
    @pproducts = @products.page(params[:page]).includes(:product_images, max_bid: :user).order(:dulation_start)
  end

  def new
    @product = if params[:id].present?
      Product.templates.find(params[:id]).dup_init
    else
      current_user.products.new
    end

    # ProductImage::IMAGE_NUM.times { @product.product_images.build }
  end

  # def confirm
  #   @product = current_user.products.new(product_params)
  #   render :new if @product.invalid?
  # end

  def create
    @product = current_user.products.new(product_params)
    params[:images].each { |img| @product.product_images.new(image: img) } if params[:images].present?

    # if params[:back]
    #   render :new
    # elsif @product.save
    if @product.save
      redirect_to "/myauction/", notice: "#{@product.name}を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    params[:images].each { |img| @product.product_images.new(image: img) } if params[:images].present?

    if @product.update(product_params)
      redirect_to "/myauction/", notice: "#{@product.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @product.soft_destroy!
    redirect_to "/myauction/products/", notice: "#{@product.name}を削除しました"
  end

  private

  def get_product
    @product = current_user.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:category_id, :code, :name, :description,
      :dulation_start, :dulation_end, :start_price, :prompt_dicision_price,
      :shipping_user, :state, :state_comment, :returns, :returns_comment, :early_termination, :auto_extension, :auto_resale, :template,
      product_images_attributes: [:id, :image, :_destroy])
  end
end
