class System::CategoriesController < System::ApplicationController
  include Exports
  before_action :get_child, only: [:new, :create]

  def index
    respond_to do |format|
      format.html {
        @parent     = Category.find_or_initialize_by(id: params[:parent_id])
        @categories = params[:parent_id].present? ? @parent.children.order(:order_no) : Category.roots.order(:order_no)
      }

      format.csv {
        @categories  = Category.all.order(:id)
        export_csv "categories.csv"
      }
    end
  end

  def new
  end

  def create
    if @category.update(category_params)
      redirect_to "/system/categories?parent_id=#{@category.parent_id}", notice: "#{@category.name}を登録しました"
    else
      render :new
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      redirect_to "/system/categories?parent_id=#{@category.parent_id}", notice: "#{@category.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.soft_destroy!
    redirect_to "/system/categories?parent_id=#{@category.parent_id}", notice: "#{@category.name}を削除しました"
  end

  private

  def get_child
    @category = params[:parent_id].present? ? Category.find(params[:parent_id]).children.new : Category.new
  end

  def category_params
    params.require(:category).permit(:name, :order_no)
  end
end
