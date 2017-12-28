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
    @search    = current_user.products.finished(params[:finished]).search(params[:q])

    @products  = @search.result
    @pproducts = @products.page(params[:page]).includes(:product_images, max_bid: :user)
  end

  def new
    if params[:id].present?
      @product = Product.templates.find(params[:id])
      @product.attributes = {name: "", start_price: nil, prompt_dicision_price: nil, dulation_start: nil, dulation_end: nil, category_id: nil}
      @product.description = "\n\n" + @product.description
    else
      @product = current_user.products.new
    end

    ProductImage::IMAGE_NUM.times { @product.product_images.build }
  end

  def create
    @product = current_user.products.new(product_params)
    if @product.save
      redirect_to "/myauction/", notice: "#{@product.name}を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
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
      product_images_attributes: [:image])
  end
end
