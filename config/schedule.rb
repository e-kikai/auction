# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# 出力先のログファイルの指定
set :output, 'log/crontab.log'
# 事故防止の為RAILS_ENVの指定が無い場合にはdevelopmentを使用する
rails_env = ENV['RAILS_ENV'] || :development

set :environment, rails_env

# sitemap
every 1.day, at: '5:00 am' do
  rake '-s sitemap:refresh'
end

# 落札確認処理
every :minute do
  runner "Product.scheduling"
  # rake 'scheduling:all'
end

# Twitter自動投稿
if rails_env == :production
  every :monday, at: '6:00 pm' do
    rake 'twitter:toppage'
  end
end
