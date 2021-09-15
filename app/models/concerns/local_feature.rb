module LocalFeature
  extend ActiveSupport::Concern

  YOSHIDA_LIB_PATH = "/var/www/yoshida_lib"
  ZERO_NARRAY_02   =  Numo::SFloat.zeros(1)

  FEATURES_CSV_PATH = "#{Rails.root.to_s}/tmp/vbpr"

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

      o.to_f
    end

    def feature_csv_test(version)
      bucket   = Product.s3_bucket # S3バケット取得
      pids     = status(Product::STATUS[:start]).pluck(:id).uniq.sort # 検索対象(出品中)の商品ID取得
      csv_file = "#{FEATURES_CSV_PATH}/feature_score.csv"
      lib_path = "#{YOSHIDA_LIB_PATH}/local_feature/views"

      cmd = "cd #{lib_path} && python3 test_03.py  \"#{version}\" \"#{csv_file}\" #{pids.join(' ')}"
      logger.debug cmd
      o, e, s = Open3.capture3(cmd)

      score = o.to_f
    end

    # def feature_csv(version)
    #   bucket   = Product.s3_bucket # S3バケット取得
    #   pids     = status(Product::STATUS[:start]).pluck(:id).uniq.sort # 検索対象(出品中)の商品ID取得
    #   csv_file = "#{FEATURES_CSV_PATH}/feature_score.csv"
    #   lib_path = "#{YOSHIDA_LIB_PATH}/local_feature/views"

    #   logger.debug csv_file


    #   CSV.open(csv_file, "a+") do |csv|
    #     ### すでに取得しているものを取得 ###
    #     data_list = csv.read

    #     pids.each do |query_id|
    #       query_file  = "/tmp/#{version}_#{query_id}.delg_local"
    #       bucket.object(self.feature_s3_key(version, query_id)).download_file(query_file) unless File.exist? query_file

    #       pids.each do |target_id|
    #         next if target_id <= query_id
    #         if data_list.find { |v| v[0] == query_id.to_s && v[1] == target_id.to_s  }
    #           logger.debug "SKIP :: #{version} : #{query_id}_#{target_id}"
    #           next
    #         end

    #         target_file = "/tmp/#{version}_#{target_id}.delg_local"
    #         unless File.exist? target_file
    #           bucket.object(self.feature_s3_key(version, target_id)).download_file(target_file)
    #         end

    #         cmd = "cd #{lib_path} && python3 test_02.py  \"#{query_file}\" \"#{target_file}\""
    #         # logger.debug cmd
    #         o, e, s = Open3.capture3(cmd)

    #         score = o.to_f

    #         csv << [query_id, target_id, score]
    #         csv << [target_id, query_id, score]
    #         csv.flush

    #         logger.debug "#{version} : #{query_id}_#{target_id} - #{score}"
    #       rescue => e
    #         logger.debug "ERROR :: #{version} : #{query_id}_#{target_id}"
    #         logger.debug e.message
    #         next
    #       end

    #     rescue => e
    #       logger.debug "ERROR :: #{version} : #{query_id}"
    #       logger.debug e.message
    #       next
    #     end
    #   end
    # end

    def feature_csv_json(version)
      bucket   = Product.s3_bucket # S3バケット取得
      products = includes(:product_images).status(Product::STATUS[:start])
      # csv_file = "#{Rails.root.to_s}/tmp/vbpr/feature_score.csv"
      csv_file = feature_csv_file(version)
      lib_path = "#{YOSHIDA_LIB_PATH}/local_feature/views"

      products.each do |pr|
        ### 局所特徴の抽出(新規) ###
        pr.feature_process(version)

        ### ファイルをキャッシュ ###
        query_file  = "/tmp/#{version}_#{pr.id}.delg_local"
        logger.debug query_file
        bucket.object(self.feature_s3_key(version, pr.id)).download_file(query_file) unless File.exist? query_file
      rescue => e
        logger.debug e.message
      end

      res = {
        pids: products.pluck(:id).uniq.sort,
        csv_file: csv_file,
      }.to_json
    end

    ### 局所特徴検索処理(バージョン対応) ###
    def feature_search_pairs(version, query_id, limit=nil)
      csv_file = feature_csv_file(version)
      # csv_file = "#{Rails.root.to_s}/tmp/vbpr/feature_score.csv"

      ### CSVから局所特徴検索結果を取得 ###

      pairs = CSV.foreach(csv_file, headers: false).with_object([]) do |row, ids|
        ids << [row[1].to_i, row[2].to_i ] if row[0].to_i == query_id.to_i
      end.sort_by{ |pa| pa[1] }.reverse

      limit.present? ? pairs.take(limit) : pairs
    rescue => e
      logger.debug e.message
      []
    end

    ### IDとスコアのペアから商品取得 ###
    def search_by_pairs(pairs, limit=nil, page=1, mine=false)
      pairs = feature_search_pairs(version, query_id, limit).sort_by{ |pa| pa[1].to_f }.reverse

      ### データ取得とソートおよびlimit ###
      product_ids = pairs.map { |pa| pa[0] }
      Product.includes(:product_images).where(id: product_ids).sort_by{ |pr| product_ids.index(pr.id) }.take(limit)
    rescue
      Product.none
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

    ### CSVファイルパス ###
    def feature_csv_file(version)
      "#{FEATURES_CSV_PATH}/feature_#{version}_score.csv"
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