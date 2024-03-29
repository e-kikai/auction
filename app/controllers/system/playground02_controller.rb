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
        # @products_01 = @products.vector_search_02("vector", @target.get_vector_02("vector"), 16)
        # @products_02 = @products.vector_search_02("vol00", @target.get_vector_02("vol00"), 16)

        ### キャッシュテスト ###
        @products_01 = Rails.cache.fetch("vector_search_vector_#{@target.id}_16", expires_in: 1.minutes) do
          @products.vector_search_02("vector", @target.get_vector_02("vector"), 16)
        end

        # @products_02 = Rails.cache.fetch("vector_search_vol00_#{@target.id}_16", expires_in: 1.minutes) do
        #   @products.vector_search_02("vol00", @target.get_vector_02("vol00"), 16)
        # end

        # @products_03 = Rails.cache.fetch("vector_search_vol01_20210706_#{@target.id}_16", expires_in: 1.minutes) do
        #   @products.vector_search_02("vol01_20210706", @target.get_vector_02("vol01_20210706"), 16)
        # end

        @products_02 = Rails.cache.fetch("vector_search_vol01_20210706_#{@target.id}_16", expires_in: 1.minutes) do
          @products.vector_search_02("vol01_20210706", @target.get_vector_02("vol01_20210706"), 16)
        end

        @products_03 = Rails.cache.fetch("vector_search_vol02_20210829_#{@target.id}_16", expires_in: 1.minutes) do
          @products.vector_search_02("vol02_20210829", @target.get_vector_02("vol02_20211026"), 16)
        end

        ### 局所特徴 ###
        @features_pairs_01   = @products.feature_search_pairs("f00", @target.id)
        @features_product_01 = @products.search_by_pairs(@features_pairs_01, 16)
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

  def process_vector
    @product = Product.find(params[:id])
    @product.vector_process_02(params[:version])

    redirect_to "/system/playground_02/search_02?nitamono=#{params[:id]}", notice: "画像特徴ベクトル変換処理を行いました"
  end

  ### 画像特徴ベクトル一括変換 ###
  def all_process_vector
    # @products = Product.includes(:product_images).where(template: false).order(id: :desc).each do |pr|
    Product.includes(:product_images).status(Product::STATUS[:start]).order(id: :desc).each do |pr|
      pr.vector_process_02(params[:version])
    end

    redirect_to "/system/playground_02/search_02", notice: "すべての画像特徴ベクトル変換処理を行いました"
  end

  ### 局所特徴変換 ###
  def process_feature
    @product = Product.find(params[:id])
    @product.feature_process(params[:version])

    redirect_to "/system/playground_02/search_02?nitamono=#{params[:id]}", notice: "局所特徴変換処理を行いました"
  end

  ### 画像局所特徴一括変換 ###
  def all_process_feature
    # @products = Product.includes(:product_images).where(template: false).order(id: :desc).each do |pr|
    Product.includes(:product_images).status(Product::STATUS[:start]).order(id: :desc).each do |pr|
      pr.feature_process(params[:version])
    end

    redirect_to "/system/playground_02/search_02", notice: "すべての局所特徴変換処理を行いました"
  end

  def feature_test
    res = Product::feature_test(params[:version], params[:query_id], params[:target_id])

    render plain: "result :: #{res}"
  end

  def feature_csv
    res = Product::feature_csv(params[:version])

    render plain: "result :: success"
  end

  def feature_csv_test
    res = Product::feature_csv_test(params[:version])

    render plain: "result :: success"
  end

  def feature_csv_json
    respond_to do |format|
      format.json { render plain: Product::feature_csv_json(params[:version]) }
    end
  end

  def vector_search_json
    products = Product.status(Product::STATUS[:start]).order(id: :desc)
    pr       = Product.find(params[:id])

    res = products.vector_search_02(params[:version], pr.get_vector_02(params[:version]), params[:num]).pluck(:id)

    respond_to do |format|
      format.json { render plain: res.to_json }
    end
  end

  def feature_pair_test
    products = Product.status(Product::STATUS[:start]).order(id: :desc)
    pr       = Product.find(params[:id])

    res = products.feature_search_pairs(params[:version], pr.id)

    respond_to do |format|
      format.json { render plain: res.to_json }
    end
  end

  def plot_json
    products = Product.includes(:product_images).status(Product::STATUS[:start])

    res = products.map do |pr|
      next unless pr.top_image?

      {
        id:    pr.id,
        name:  pr.name,
        thumb: pr&.product_images&.first&.image&.thumb&.url
      }
    rescue => e
      logger.debug e.message
      nil
    end.compact

    respond_to do |format|
      format.json { render plain: res.to_json }
    end
  end

  def csv
    # @populars = Product.osusume("pops")
    temp = Product.unscoped.joins(:watches).group(:name).select("name, count(watches.id) as count")
    @populars = Product.status(Product::STATUS[:start])
      .joins("INNER JOIN (#{temp.to_sql}) as pr2 ON products.name = pr2.name")
      .reorder("pr2.count DESC, products.dulation_end ASC").select("products.*, pr2.count")

    respond_to do |format|
      format.html
      format.csv { export_csv "populars.csv" }
    end
  end

  def vectors_csv
    @products = Product.status(Product::STATUS[:start]).includes(:product_images, :category).order(id: :asc)



  end
end