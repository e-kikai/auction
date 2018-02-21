class Myauction::SearchesController < Myauction::ApplicationController
  def index
    @searches = current_user.searches
    @psearches = @searches.page(params[:page])
  end

  def new
    @search = current_user.searches.new(search_params)

    # @serach.products.each do |pr|
    #   if pr.images.present?
    #     @serach.product_image_id = pr.images[0]
    #     break
    #   end
    # end
  end

  def create
    @search = current_user.searches.new(search_params)
    if @search.save
      redirect_to "/myauction/searches", notice: "検索条件「#{@search.name}」を登録しました"
    else
      redirect_to "/myauction/searches", alert: "検索条件「#{@search.name}」を登録できませんでした"
    end
  end

  def update
    @search = current_user.searches.find(params[:id])

    if current_user.seller?
      if @search.publish?
        @search.update(publish: false)
        redirect_to "/myauction/searches/", notice: "検索条件「#{@search.name}」のトップページ公開を解除しました"
      else
        @search.update(publish: true)
        redirect_to "/myauction/searches/", notice: "検索条件「#{@search.name}」のトップページ公開しました"
      end
    else
      @search.update(publish: false)
      redirect_to "/myauction/searches/", notice: "検索条件の公開は行なえません"
    end
  end

  def destroy
    @search = current_user.searches.find(params[:id])
    @search.soft_destroy!
    redirect_to "/myauction/searches/", notice: "検索条件「#{@search.name}」を削除しました"
  end

  private

  def search_params
    params.require(:search).permit(:name, :keywords, :category_id, :q, :publish)
  end
end
