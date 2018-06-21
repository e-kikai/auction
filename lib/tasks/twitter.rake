require 'twitter'

namespace :twitter do
  desc "新着商品を自動送信"
  task :new_product => :environment do
    client = get_twitter_client

    tweet1 = "自動投稿テスト その1 / #{Time.now}"
    update(client, tweet1)

    sleep(5)

    tweet2 = "自動投稿テスト その2 / #{Time.now}"
    update(client, tweet2)

    # Product.status(Product::STATUS[:success]).where(fee: nil).includes(max_bid: [:user]).each do |pr|
    #   pr.update(fee: pr.fee_calc)
    #
    #   BidMailer.success_user(pr.max_bid.user, pr).deliver
    #   BidMailer.success_company(pr).deliver
    # end
  end

  desc "トップページリンクを自動投稿(毎週月曜日 18:00)"
  task :toppage => :environment do
    client = get_twitter_client

    tweet1 = <<-EOS
〜ものづくりオークション〜

新品も中古も！欲しかったあの工具が格安で手に入るかも！
ものづくりの現場で活躍する機械・工具を安心安全な業者からネットオークションで購入！

#ものオク #ものづくり #オークション #工具 #工作機械
https://www.mnok.net/
EOS
    update(client, tweet1)
  end
end

def get_twitter_client
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = Rails.application.secrets.twitter_consumer_key
    config.consumer_secret     = Rails.application.secrets.twhtter_consumer_secret
    config.access_token        = Rails.application.secrets.twitter_access_token
    config.access_token_secret = Rails.application.secrets.twitter_access_token_secret
  end
  client
end

def update(client, tweet)
  begin
    tweet = (tweet.length > 140) ? tweet[0..139].to_s : tweet
    client.update(tweet.chomp)
  rescue => e
    Rails.logger.error "<<twitter.rake::tweet.update ERROR : #{e.message}>>"
  end
end
