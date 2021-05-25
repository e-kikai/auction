module ImageVector
  extend ActiveSupport::Concern

  YOSHIDA_LIB_PATH = "/var/www/yoshida_lib"
  ZERO_NARRAY_02   =  Numo::SFloat.zeros(1)

  ### 画像特徴ベクトルを抽出(バージョン対応) ###
  def vector_process_02(version)
    bucket = Product.s3_bucket # S3バケット取得

    vector_key = self.class.vector_s3_key(version, self.id) # ベクトルを保存するS3キー
    image      = product_images.first                       # ベクトル変換する画像ファイルパス

    if image.blank?  # 画像の有無チェック
      errors.add(:base, '商品に画像が登録されていません') and return false
    elsif bucket.object(vector_key).exists? # ベクトルファイルの存否を確認
      errors.add(:base, 'ベクトルファイルがすでに存在します') and return false
    end

    filename    = image.image_identifier # 変換元画像ファイル名
    image_key   = "uploads/product_image/image/#{image.id}/#{filename}" # S3画像格納キー

    lib_path    = self.class.vector_lib_path(version)
    image_path  = "#{lib_path}/../image/#{filename}"
    vector_path = "#{lib_path}/../image_vectors/#{filename}.npy"

    # logger.debug image_path
    # logger.debug vector_path

    bucket.object(image_key).download_file(image_path) # S3より画像ファイルの取得

    ### 画像特徴ベクトル処理実行 ###
    cmd = "cd #{lib_path} && python3 process_images.py --output_folder=\"../\" \"#{image_path}\";"
    # logger.debug cmd
    o, e, s = Open3.capture3(cmd)

    bucket.object(vector_key).upload_file(vector_path) # ベクトルファイルアップロード

    File.delete(vector_path, image_path) # 不要になった画像ファイル、ベクトルファイルの削除

    self
  rescue
    logger.debug "*** X : rescue"
    return
  end

  class_methods do
    ### 画像特徴ベクトル検索処理(バージョン対応) ###
    def vector_search_02(version, target, limit=nil, page=1, mine=false)
      return Product.none if target.nil?

      vectors = Rails.cache.read(self.vector_cache(version)) || {} # キャッシュからベクトル群を取得
      bucket  = Product.s3_bucket # S3バケット取得
      update_flag = false

      ### 各ベクトル比較 ###
      pids = pluck(:id).uniq # 検索対象(出品中)の商品ID取得

      sorts = pids.map do |pid|
        ### ベクトルの取得 ###
        pr_narray = if vectors[pid].present? && vectors[pid] != ZERO_NARRAY_02 # 既存
          vectors[pid]
        else # 新規(ファイルからベクトル取得して追加)
          update_flag = true
          vectors[pid] = if bucket.object(self.vector_s3_key(version, pid)).exists?

            str = bucket.object(self.vector_s3_key(version, pid)).get.body.read
            Npy.load_string(str) rescue ZERO_NARRAY_02
          else
            ZERO_NARRAY_02
          end

          vectors[pid]
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
      Rails.cache.write(self.vector_cache(version), vectors) if update_flag == true

      ### 結果を返す ###
      where(id: sorts.keys).sort_by { |pr| sorts[pr.id] }
    end

    ### 画像特徴ベクトルライブラリパス ###
    def vector_lib_path(version)
      "#{YOSHIDA_LIB_PATH}/image_vector/#{version}"
    end

  ### S3ベクトル格納パス ###
    def vector_s3_path(version)
      "#{version.pluralize}"
    end

    ### S3ベクトル格納キー生成 ###
    def vector_s3_key(version, product_id)
      "#{self.vector_s3_path(version)}/#{version}_#{product_id}.npy"
    end

    ### ベクトルキャッシュ名 ###
    def vector_cache(version)
      version
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