module PlaygroundDb
  extend ActiveSupport::Concern

  private

  ### テスト用DB切替 ###
  def change_db
    Thread.current[:request] = request

    case Rails.env
    when "production"; redirect_to "/"
    when "staging"
      ActiveRecord::Base.establish_connection(:production)
      @img_base    = "https://s3-ap-northeast-1.amazonaws.com/mnok/uploads/product_image/image"
      @link_base   = "https://www.mnok.net/"
      @bucket_name = "mnok"

      CarrierWave.configure do |config|
        config.asset_host = "https://s3-ap-northeast-1.amazonaws.com/mnok" # 本環境画像パス設定
      end
    else
      @img_base    = "https://s3-ap-northeast-1.amazonaws.com/development.auction/uploads/product_image/image"
      @link_base   = "http://192.168.33.110:8087/"
      @bucket_name = Rails.application.secrets.aws_s3_bucket
    end
  end

  ### DB切替を戻す ###
  def restore_db
    case Rails.env
    when "production"; redirect_to "/"
    when "staging"
      ActiveRecord::Base.establish_connection(:staging)
    end
  end
end