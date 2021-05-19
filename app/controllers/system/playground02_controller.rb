class System::Playground02Controller < ApplicationController
  include Exports
  include PlaygroundDb

  before_action :change_db
  after_action  :restore_db

  def search_02
    # 初期検索クエリ作成
    @products = Product.status(Product::STATUS[:mix])
      .where("products.created_at <= ?", Date.new(2020, 7, 3).to_time)
      .includes(:product_images, :category, :user)
      .order(id: :desc)

    if params[:nitamono]
      ### 似たものサーチ(比較) ###
      @time = Benchmark.realtime do
        @target   = Product.find(params[:nitamono])
        # @sorts = sort_by_vector(@target, @products)

        @products    = @target.nitamono(Product::NEW_MAX_COUNT)
        @products_02 = @target.nitamono(Product::NEW_MAX_COUNT) # 比較
      end
    else
      ### 通常サーチ ###
      ### 検索キーワード ###
      @keywords = params[:keywords].to_s

      # 初期検索クエリ作成
      @products = @products.with_keywords(@keywords)

      # カテゴリ
      if params[:category_id].present?
        @category = Category.find(params[:category_id])
        @products = @products.search(category_id_in: @category.subtree_ids).result
      end

      ### ページャ ###
      @pproducts = @products.page(params[:page])
    end

    ### 検索セレクタ ###
    @categories_selector = Category.options

    respond_to do |format|
      format.html
      format.csv { export_csv "products_images.csv" }
    end
  end

  ### 画像特徴ベクトル一括変換 ###
  def all_process_vector
    @products = Product.includes(:product_images).where(template: false).order(id: :desc).each do |pr|
      pr.process_vector
    end

    redirect_to "/playground_02/search_02", notice: "すべての画像特徴ベクトル変換処理を行いました"
  end
end