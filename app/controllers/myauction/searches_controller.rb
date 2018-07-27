class Myauction::SearchesController < Myauction::ApplicationController
  before_action :get_search, only: [:edit, :update, :destroy]

  def index
    @searches = current_user.searches
    @psearches = @searches.page(params[:page])
  end

  def new
    @search = current_user.searches.new(search_params)

    if current_user.seller?
      @search.products.each do |pr|
        if pr.product_images.present?
          @search.product_image_id = pr.product_images[0].id
          break
        end
      end
    end
  end

  def create
    @search = current_user.searches.new(search_params)
    if @search.save
      redirect_to "/myauction/searches", notice: "検索条件「#{@search.name}」を登録しました"
    else
      redirect_to "/myauction/searches", alert: "検索条件「#{@search.name}」を登録できませんでした"
    end
  end

  def edit
  end

  def update
    # if current_user.seller?
    #   if @search.publish?
    #     @search.update(publish: false)
    #     redirect_to "/myauction/searches/", notice: "検索条件「#{@search.name}」のトップページ公開を解除しました"
    #   else
    #     @search.update(publish: true)
    #     redirect_to "/myauction/searches/", notice: "検索条件「#{@search.name}」のトップページ公開しました"
    #   end
    # else
    #   @search.update(publish: false)
    #   redirect_to "/myauction/searches/", notice: "検索条件の公開は行なえません"
    # end

    if @search.update(search_params)
      redirect_to "/myauction/searches/", notice: "#{@search.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @search.soft_destroy!
    redirect_to "/myauction/searches/", notice: "検索条件「#{@search.name}」を削除しました"
  end

  private

  def get_search
    @search = current_user.searches.find(params[:id])
  end

  def search_params
    params.require(:search).permit(:name, :keywords, :category_id, :company_id, :q, :publish, :description, :product_image_id)
  end


end
