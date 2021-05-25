class System::Playground02Controller < ApplicationController
  include Exports
  include PlaygroundDb

  before_action :change_db
  after_action  :restore_db

  def search_02
    # 初期検索クエリ作成
    @products = Product.status(Product::STATUS[:start]).includes(:product_images, :category).order(id: :desc)

    if params[:nitamono]
      ### 似たものサーチ(比較) ###
      @time = Benchmark.realtime do
        @target   = Product.find(params[:nitamono])

        ### 比較 ###
        logger.debug @target.get_vector_02("vector")
        @products_01 = @products.vector_search_02("vector", @target.get_vector_02("vector"), 10)
        # @products_02 = @products.vector_search_02("vol00", @target.get_vector_02("vol00"), 10)
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