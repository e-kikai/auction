CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => Rails.application.secrets.aws_access_key_id,
      :aws_secret_access_key  => Rails.application.secrets.aws_secret_access_key,
      :region                 => 'ap-northeast-1', # Tokyo
      :path_style             => true,
  }

  config.fog_public     = true # public-read
  config.fog_attributes = {'Cache-Control' => 'public, max-age=86400'}

  # case Rails.env
  # when 'production'
  #   config.fog_directory = 'mnok'
  #   config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/mnok'
  # when 'staging'
  #   config.fog_directory = 'staging.auction'
  #   config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/staging.auction'
  # when 'development'
  #   config.fog_directory = 'development.auction'
  #   config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/development.auction'
  # when 'test'
  #   config.fog_directory = 'test.auction'
  #   config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/test.auction'
  # end

  config.fog_directory = Rails.application.secrets.aws_s3_bucket
  config.asset_host    = "https://s3-ap-northeast-1.amazonaws.com/#{Rails.application.secrets.aws_s3_bucket}"

end
