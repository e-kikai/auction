class System::SchedulingController < ApplicationController
  # before_action :check_ip

  # 定期実行処理
  def product_scheduling
    Product.scheduling

    render plain: 'OK', status: 200
  end

  # 新着メール通知
  def alert_scheduling
    Alert.scheduling

    render plain: 'OK', status: 200
  end

  # ウォッチ新着
  def watch_scheduling
    Watch.scheduling

    render plain: 'OK', status: 200
  end

  # Twitter新着
  def twitter_new_product
    @product = Product.status(Product::STATUS[:start]).where("dulation_start > ?", Time.now - Product::TWITTER_INTERVAL).order("RANDOM()").first

    # 新着がなければ、別処理
    @news = if @product.blank?
      @product = Product.status(Product::STATUS[:start]).order("RANDOM()").first
      false
    else
      true
    end

    twitter_send(render_to_string(formats: :text))

    render plain: 'OK', status: 200
  end

  # Twitter定期bot
  def twitter_toppage
    twitter_send(render_to_string(formats: :text))

    render plain: 'OK', status: 200
  end

  # Twitter週末新着
  def twitter_news_week
    twitter_send(render_to_string(formats: :text))

    render plain: 'OK', status: 200
  end

  # チラシメール定期
  def flyer_mail
    User.where(allow_mail: false).each do |us|
      BidMailer.flyer(us).deliver
    end

    render plain: 'OK', status: 200
  end

  # 週間新着メール
  def news_mail
    date    = Time.now
    res     = Product.status(Product::STATUS[:start]).search(news_week: date.strftime("%F")).result
    product = res.limit(Product::NEWS_LIMIT)
    count   = res.count

    User.where(allow_mail: true).where.not(confirmed_at: nil).reorder(id: :desc).each do |us|
      BidMailer.news_week(us, date, product, count).deliver
    end

    render plain: 'OK', status: 200
  end

  # def reconfirm_mail
  #   User.where(confirmed_at: false).reorder(id: :desc).each do |us|
  #     BidMailer.reconfirm(us, date, product, count).deliver
  #   end
  #
  #   render plain: 'OK', status: 200
  # end

  private

  def check_ip
    unless request.env['HTTP_X_FORWARDED_FOR'] == "127.0.0.1"
      render plain: request.env['HTTP_X_FORWARDED_FOR'], status: 404
      return
    end
  end

  # Twitter共通送信処理
  def twitter_send(tweet)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret     = Rails.application.secrets.twhtter_consumer_secret
      config.access_token        = Rails.application.secrets.twitter_access_token
      config.access_token_secret = Rails.application.secrets.twitter_access_token_secret
    end

    begin
      # tweet = (tweet.length > 140) ? tweet[0..139].to_s : tweet
      client.update(tweet.chomp)
    rescue => e
      Rails.logger.error "<<twitter.rake::tweet.update ERROR : #{e.message}>>"
    end
  end
end
