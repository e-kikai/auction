# 出力先のログファイルの指定
# set :output, 'log/crontab.log'

# 事故防止の為RAILS_ENVの指定が無い場合にはdevelopmentを使用する
rails_env = ENV['RAILS_ENV'] || :development

set :environment, rails_env

### wget URL ###
url = case rails_env.to_sym
when :production; "https://www.mnok.net"
when :staging;    "52.198.119.255"
else;             "http://127.0.0.1:8087"
end

scheduling_url = url + "/system/scheduling"

# sitemap
every 1.day, at: '5:00 am' do
  rake '-s sitemap:refresh'
end

# 落札確認処理
every :minute do
  # runner "Product.scheduling"
  command "wget --spider #{scheduling_url + '/product_scheduling'}"
end

# 新着アラート
every :day, at: '7:00 am' do
  # runner "Alert.scheduling"
  command "wget --spider #{scheduling_url + '/alert_scheduling'}"
end

# ウォッチおすすめ新着
every :day, at: '8:00 am' do
  # runner "Watch.scheduling"
  command "wget --spider #{scheduling_url + '/watch_scheduling'}"
end

# Twitter自動投稿
if rails_env.to_sym == :production
  every :day, at: ['6:00 am', '6:00 pm'] do
    # rake 'twitter:new_product'
    command "wget --spider #{scheduling_url + '/twitter_new_product'}"
  end

  every :monday, at: '6:00 pm' do
    # rake 'twitter:toppage'
    command "wget --spider #{scheduling_url + '/twitter_toppage'}"
  end
end
