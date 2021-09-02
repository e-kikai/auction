module LocalFeature
  extend ActiveSupport::Concern

  YOSHIDA_LIB_PATH = "/var/www/yoshida_lib"
  ZERO_NARRAY_02   =  Numo::SFloat.zeros(1)

  ### 局所特徴を抽出(バージョン対応) ###
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

    ### 局所特徴処理実行 ###
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
    ### 局所特徴の比較 ###

    def feature_test(version, query_id, target_id)
      bucket      = Product.s3_bucket # S3バケット取得

      query_file  = "/tmp/#{version}_#{query_id}.delg_local"
      target_file = "/tmp/#{version}_#{target_id}.delg_local"

      # query  = bucket.object(self.feature_s3_key(version, query_id)).get.body.read
      # target = bucket.object(self.feature_s3_key(version, target_id)).get.body.read

      bucket.object(self.feature_s3_key(version, query_id)).download_file(query_file)   unless File.exist? query_file
      bucket.object(self.feature_s3_key(version, target_id)).download_file(target_file) unless File.exist? target_file

      ### 局所特徴の比較 ###
      lib_path = "#{YOSHIDA_LIB_PATH}/local_feature/views"
      # cmd = "cd #{lib_path} && python3 test_02.py  \"#{query}\" \"#{target};\""
      cmd = "cd #{lib_path} && python3 test_02.py  \"#{query_file}\" \"#{target_file}\""
      logger.debug cmd
      o, e, s = Open3.capture3(cmd)

      logger.debug o
      logger.debug e
      logger.debug s

      o
    end

    def feature_csv(version)
      bucket   = Product.s3_bucket # S3バケット取得
      pids     = where(' id < 4000').pluck(:id).uniq.sort # 検索対象(出品中)の商品ID取得
      csv_file = "#{Rails.root.to_s}/tmp/vbpr/feature_score.csv"

      logger.debug csv_file

      CSV.open(csv_file, "wb") do |csv|
        pids.each do |query_id|
          query_file  = "/tmp/#{version}_#{query_id}.delg_local"
          bucket.object(self.feature_s3_key(version, query_id)).download_file(query_file) unless File.exist? query_file

          pids.each do |target_id|
            next if target_id <= query_id

            target_file = "/tmp/#{version}_#{target_id}.delg_local"
            unless File.exist? target_file
              bucket.object(self.feature_s3_key(version, target_id)).download_file(target_file)
            end

            cmd = "cd #{lib_path} && python3 test_02.py  \"#{query_file}\" \"#{target_file}\""
            # logger.debug cmd
            o, e, s = Open3.capture3(cmd)

            csv << [query_id, target_id, o]
            logger.debug "#{version} : #{query_id}_#{target_id} - #{o}"
          rescue
            logger.debug "ERROR :: #{version} : #{query_id}_#{target_id}"
            next
          end

        rescue
          logger.debug "ERROR :: #{version} : #{query_id}"
          next
        end
      end
    end

    # def feature_csv
    #   features    = Rails.cache.read(self.feature_cache(version)) || {} # キャッシュからベクトル群を取得
    #   bucket      = Product.s3_bucket # S3バケット取得
    #   update_flag = false

    #   ### 各ベクトル比較 ###
    #   pids = pluck(:id).uniq # 検索対象(出品中)の商品ID取得
    #   pids.each do |target_pid|
    #     ### ターゲット局所特徴の取得 ###
    #     target_feature = if features[target_pid].present? # 既存
    #       features[target_pid]
    #     else # 新規(ファイルからベクトル取得して追加)
    #       update_flag = true
    #       features[target_pid] = if bucket.object(self.feature_s3_key(version, target_pid)).exists?
    #         str = bucket.object(self.feature_s3_key(version, target_pid)).get.body.read
    #       else
    #         # logger.debug "ZERO"
    #         ''
    #       end

    #       features[pid]
    #     end

    #     pids.each do |pid|
    #       ### 比較する局所特徴の取得 ###
    #       index_feature = if features[pid].present? # 既存
    #         features[pid]
    #       else # 新規(ファイルからベクトル取得して追加)
    #         update_flag = true
    #         features[pid] = if bucket.object(self.feature_s3_key(version, pid)).exists?
    #           str = bucket.object(self.feature_s3_key(version, pid)).get.body.read
    #         else
    #           # logger.debug "ZERO"
    #           ''
    #         end

    #         features[pid]
    #       end

    #       ### 局所特徴の比較 ###
    #       target_feature index_feature
    #       cmd = "cd #{lib_path} && python3 test_00.py  #{target_feature} #{index_feature};"
    #       # logger.debug cmd
    #       o, e, s = Open3.capture3(cmd)

    #     end
    #   end


    # end

    ### 局所特徴検索処理(バージョン対応) ###
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

    ### 局所特徴ライブラリパス ###
    def feature_lib_path(version)
      "#{YOSHIDA_LIB_PATH}/local_feature/#{version}"
    end

    ### S3ベクトル格納パス ###
    def feature_s3_path(version)
      "features/#{version.pluralize}"
    end

    ### S3ベクトル格納キー生成 ###
    def feature_s3_key(version, product_id)
      "#{self.feature_s3_path(version)}/#{version}_#{product_id}.delg_local"
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