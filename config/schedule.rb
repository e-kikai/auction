# 出力先のログファイルの指定
# set :output, 'log/crontab.log'
set :output, nil

# 事故防止の為RAILS_ENVの指定が無い場合にはdevelopmentを使用する
rails_env = ENV['RAILS_ENV'] || :development

set :environment, rails_env

### wget URL ###
url = case rails_env.to_sym
when :production; "https://www.mnok.net"
when :staging;    "http://54.248.15.132"
else;             "http://192.168.33.110:8087"
end

scheduling_url = url + "/system/scheduling"

# sitemap
every 1.day, at: '5:00 am' do
  rake '-s sitemap:refresh'
end

# 落札確認処理
every :minute do
  # runner "Product.scheduling"
  # command "wget --spider #{scheduling_url + '/product_scheduling'}"
  command "curl -s -X POST #{scheduling_url + '/product_scheduling'}"
end

# 新着アラート
every :day, at: '7:00 am' do
  # runner "Alert.scheduling"
  # command "wget --spider #{scheduling_url + '/alert_scheduling'}"
  command "curl -s -X POST #{scheduling_url + '/alert_scheduling'}"
end

# ウォッチおすすめ新着
every :day, at: '8:00 am' do
  # runner "Watch.scheduling"
  # command "wget --spider #{scheduling_url + '/watch_scheduling'}"
  command "curl -s -X POST #{scheduling_url + '/watch_scheduling'}"
end

# Twitter自動投稿
if rails_env.to_sym == :production
  # every :day, at: ['6:00 am', '6:00 pm'] do
  every 6.hours do
    # rake 'twitter:new_product'
    # command "wget --spider #{scheduling_url + '/twitter_new_product'}"
    command "curl -s -X POST #{scheduling_url + '/twitter_new_product'}"
  end

  every :monday, at: '6:00 pm' do
    # rake 'twitter:toppage'
    # command "wget --spider #{scheduling_url + '/twitter_toppage'}"
    command "curl -s -X POST #{scheduling_url + '/twitter_toppage'}"
  end

  every :friday, at: '5:00 pm' do
    # command "wget --spider #{scheduling_url + '/twitter_news_week'}"
    command "curl -s -X POST #{scheduling_url + '/twitter_news_week'}"
  end

  # every :friday, at: '4:00 pm' do
  #   command "wget --spider #{scheduling_url + '/news_mail'}"
  # end
end
