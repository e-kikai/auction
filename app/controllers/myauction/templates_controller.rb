class Myauction::TemplatesController < Myauction::ApplicationController
  before_action :get_template, only: [:edit, :update, :destroy]

  include Exports

  def index
    @search    = current_user.products.templates.search(params[:q])

    @templates  = @search.result
    @ptemplates = @templates.page(params[:page])

    respond_to do |format|
      format.html
      format.csv { export_csv "templates.csv" }
    end
  end

  def new
    @template = current_user.products.new
    ProductImage::IMAGE_NUM.times { @template.product_images.build }

  end

  def create
    @template = current_user.products.new(template_params)
    if @template.save
      redirect_to "/myauction/", notice: "#{@template.name}を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to "/myauction/", notice: "#{@template.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @template.soft_destroy!
    redirect_to "/myauction/templates/", notice: "#{@template.name}を削除しました"
  end

  private

  def get_template
    @template = current_user.products.find(params[:id])
  end

  def template_params
    params.require(:product).permit(:category_id, :code, :name, :description,
      :dulation_start, :dulation_end, :start_price, :prompt_dicision_price,
      :shipping_user, :state, :state_comment, :returns, :returns_comment, :early_termination, :auto_extension, :auto_resale, :shipping_no, :addr_1, :addr_2,
      :template,
      product_images_attributes: [:image])
  end
end
