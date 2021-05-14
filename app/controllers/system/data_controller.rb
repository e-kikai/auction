class System::DataController < ApplicationController
  ### VBPR処理用データ出力 ###
  def vbpr
    ### ログのあるを取得 ###
    img_ids      = ProductImage.distinct.select(:product_id)
    products     = Product.all # 削除されたものを除外
    @watches     = Watch.distinct.where(product_id: img_ids).where(product_id: products, created_at: DetailLog::VBPR_RANGE).pluck(:user_id, :product_id)
    @bids        = Bid.distinct.where(product_id: img_ids).where(product_id: products, created_at: DetailLog::VBPR_RANGE).pluck(:user_id, :product_id)
    @detail_logs = DetailLog.distinct.where.not(user_id: nil).where(product_id: img_ids, created_at: DetailLog::VBPR_RANGE).where(product_id: products).pluck(:user_id, :product_id)

    ### 現在出品中の商品(画像あり)を取得 ###
    @now_products = Product.status(Product::STATUS[:start]).where(id: img_ids).pluck(:id)

    ### バイアスを集計 ###
    @biases = @detail_logs.map { |lo| [[lo[0], lo[1]] , DetailLog::VBPR_BIAS[:detail]] }.to_h
    @watches.each { |wa| @biases[[wa[0], wa[1]]] = (@biases[[wa[0], wa[1]]] || 0) + DetailLog::VBPR_BIAS[:watch] }
    @bids.each    { |bi| @biases[[bi[0], bi[1]]] = (@biases[[bi[0], bi[1]]] || 0) + DetailLog::VBPR_BIAS[:bid] }

    ### スパース行列に変換 ###
    user, product, bias = [], [], []

    @biases.each do |key, val|
      user    << key[0].to_i
      product << key[1].to_i
      bias    << val || 1
    end

    user_idx = user.uniq.map.with_index { |v, i| [v, i] }.to_h # ユーザインデックスhash
    user_key = user.map { |v| user_idx[v] } # ユーザインデックスに変換

    product_idx = product.uniq.map.with_index { |v, i| [v, i] }.to_h # 商品インデックスhash
    product_key = product.map { |v| product_idx[v] } # 商品インデックスに変換

    ### 現在出品中の商品のみインデックスhash ###
    now_product_idx = @now_products.map { |pid| [ pid, product_idx[pid] ] }.to_h

    ### 現在出品中、かつ、ログのない商品をインデックスに追加 ###
    plus_products_idx = (@now_products - product.uniq).map.with_index { |v, i| [v, (i + product.uniq.length)] }.to_h
    product_idx.merge! plus_products_idx

    res = {
      user_idx:    user_idx,
      user_key:    user_key,
      product_idx: product_idx,
      product_key: product_key,
      bias:        bias,

      now_product_idx:   now_product_idx,
      plus_products_idx: plus_products_idx,

      # 設定類
      config: {
        bucket_name: Rails.application.secrets.aws_s3_bucket,
        # bucket_name: @bucket_name,
        vbpr_csv_file: DetailLog::VBPR_CSV_FILE,
        bpr_csv_file:  DetailLog::BPR_CSV_FILE,
        npz_file:      DetailLog::VBPR_NPZ_FILE,
        tempfile:      DetailLog::VBPR_TEMP,
        limit:         DetailLog::VBPR_LIMIT,
        epochs:        DetailLog::VBPR_EPOCHS,
      }
    }.to_json

    respond_to do |format|
      format.json { render plain: res }
    end
  end
end
