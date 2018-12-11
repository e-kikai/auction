class System::SchedulingController < ApplicationController
  # before_action :check_ip

  def product_scheduling
    Product.scheduling

    render plain: 'OK', status: 200
  end

  def alert_scheduling
    Alert.scheduling

    render plain: 'OK', status: 200
  end

  def watch_scheduling
    Watch.scheduling

    render plain: 'OK', status: 200
  end

  def twitter_new_product
    @product = Product.status(Product::STATUS[:start]).where("dulation_start > ?", Time.now - 12.hours).order("RANDOM()").first

    twitter_send(render_to_string(formats: :text)) if @product.present?

    render plain: 'OK', status: 200
  end

  def twitter_toppage
    twitter_send(render_to_string(formats: :text))

    render plain: 'OK', status: 200
  end

  private

  def check_ip
    unless request.env['HTTP_X_FORWARDED_FOR'] == "127.0.0.1"
      render plain: request.env['HTTP_X_FORWARDED_FOR'], status: 404
      return
    end
  end

  def twitter_send(tweet)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret     = Rails.application.secrets.twhtter_consumer_secret
      config.access_token        = Rails.application.secrets.twitter_access_token
      config.access_token_secret = Rails.application.secrets.twitter_access_token_secret
    end

    begin
      tweet = (tweet.length > 140) ? tweet[0..139].to_s : tweet
      client.update(tweet.chomp)
    rescue => e
      Rails.logger.error "<<twitter.rake::tweet.update ERROR : #{e.message}>>"
    end
  end
end
