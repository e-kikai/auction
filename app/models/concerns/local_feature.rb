module LocalFeature
  extend ActiveSupport::Concern

  YOSHIDA_LIB_PATH = "/var/www/yoshida_lib"
  ZERO_NARRAY_02   =  Numo::SFloat.zeros(1)

  ### 画像特徴ベクトルを抽出(バージョン対応) ###
  def feature_process(version)
    bucket = Product.s3_bucket # S3バケット取得

    feature_key = self.class.feature_s3_key(version, self.id) # ベクトルを保存するS3キー
    image      = product_images.first                       # ベクトル変換する画像ファイルパス

    if image.blank?  # 画像の有無チェック
      errors.add(:base, '商品に画像が登録されていません') and return false
    elsif bucket.object(feature_key).exists? # ベクトルファイルの存否を確認
      errors.add(:base, '局所特徴ファイルがすでに存在します') and return false
    end

    filename    = image.image_identifier # 変換元画像ファイル名
    image_key   = "uploads/product_image/image/#{image.id}/#{filename}" # S3画像格納キー

    lib_path    = self.class.feature_lib_path(version)
    image_path  = "#{lib_path}/../image/#{filename}"
    feature_path = "#{lib_path}/../image_feature/#{filename}.delg_local"

    # logger.debug image_path
    # logger.debug feature_path

    bucket.object(image_key).download_file(image_path) # S3より画像ファイルの取得

    ### 画像特徴ベクトル処理実行 ###
    # cmd = "cd #{lib_path} && python3 process_images.py --output_folder=\"../\" \"#{image_path}\";"
    cmd = "cd #{lib_path} && sh run_extract_delg_features.sh;"
    # logger.debug cmd
    o, e, s = Open3.capture3(cmd)

    bucket.object(feature_key).upload_file(feature_path) # ベクトルファイルアップロード

    File.delete(feature_path, image_path) # 不要になった画像ファイル、ベクトルファイルの削除

    self
  # rescue
  #   logger.debug "*** X : rescue"
  #   return
  end

  ### この商品のベクトルを取得(バージョン対応) ###
  def get_feature(version)
    return nil unless top_image? # 画像の有無チェック

    features = Rails.cache.read(self.class.feature_cache(version)) || {} # キャッシュからベクトル群を取得
    bucket  = Product.s3_bucket # S3バケット取得
    logger.debug self.class.feature_s3_key(version, id)

    ### ターゲットベクトル取得 ###
    if features[id].present? # キャッシュからベクトル取得
      logger.debug "get by cache :: #{id}"
      features[id]
    elsif bucket.object(self.class.feature_s3_key(version, id)).exists? # アップロードファイルからベクトル取得
      logger.debug "get by bucket :: #{id}"

      str = bucket.object(self.class.feature_s3_key(version, id)).get.body.read
      Npy.load_string(str)
    else # ない場合
      logger.debug "!!!!!! nil !!!!!! :: #{id}"

      nil
    end
  end

  class_methods do
    ### 画像特徴ベクトル検索処理(バージョン対応) ###
    def feature_search(version, target, limit=nil, page=1, mine=false)

      logger.debug "# feature_search #"

      return Product.none if target.nil?

      features    = Rails.cache.read(self.feature_cache(version)) || {} # キャッシュからベクトル群を取得
      bucket      = Product.s3_bucket # S3バケット取得
      update_flag = false

      ### 各ベクトル比較 ###
      pids = pluck(:id).uniq # 検索対象(出品中)の商品ID取得

      sorts = pids.map do |pid|
        # logger.debug pid

        ### ベクトルの取得 ###
        pr_narray = if features[pid].present? && features[pid] != ZERO_NARRAY_02 # 既存
          features[pid]
        else # 新規(ファイルからベクトル取得して追加)
          update_flag = true
          features[pid] = if bucket.object(self.feature_s3_key(version, pid)).exists?

            str = bucket.object(self.feature_s3_key(version, pid)).get.body.read
            Npy.load_string(str) rescue ZERO_NARRAY_02
          else
            # logger.debug "ZERO"
            ZERO_NARRAY_02
          end

          features[pid]
        end

        ### ベクトル比較 ###
        if pr_narray == ZERO_NARRAY_02 || pr_narray.nil? # ベクトルなし
          nil
        else
          sub = pr_narray - target
          res = (sub * sub).sum

          (res > 0 || mine == true) ? [pid, res]  : nil
        end
      end.compact.sort_by { |v| v[1] }

      ### 件数フィルタリング ###
      limit = limit.to_i
      page  = page.to_i < 1 ? 1 : page.to_i

      sorts = sorts.slice(limit * (page - 1), limit) if limit > 0
      sorts = sorts.to_h

      # ベクトルキャシュ更新
      Rails.cache.write(self.feature_cache(version), features) if update_flag == true

      ### 結果を返す ###
      where(id: sorts.keys).sort_by { |pr| sorts[pr.id] }

    end

    ### 画像特徴ベクトルライブラリパス ###
    def feature_lib_path(version)
      "#{YOSHIDA_LIB_PATH}/local_feature/#{version}"
    end

    ### S3ベクトル格納パス ###
    def feature_s3_path(version)
      "#{version.pluralize}"
    end

    ### S3ベクトル格納キー生成 ###
    def feature_s3_key(version, product_id)
      "#{self.feature_s3_path(version)}/#{version}_#{product_id}.npy"
    end

    ### ベクトルキャッシュ名 ###
    def feature_cache(version)
      "f_#{version}"
    end

    ### S3リソース設定 ###
    def s3_resource
      Aws::S3::Resource.new(
        access_key_id:     Rails.application.secrets.aws_access_key_id,
        secret_access_key: Rails.application.secrets.aws_secret_access_key,
        region:            'ap-northeast-1', # Tokyo
      )
    end

    ### S3バケット取得 ###
    def s3_bucket
      s3_resource.bucket(Rails.application.secrets.aws_s3_bucket)
    end
  end
end