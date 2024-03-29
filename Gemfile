source "https://rubygems.org"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2'
gem 'rails-i18n'

gem 'bootsnap', require: false

# Use sqlite3 as the database for Active Record
gem 'pg', '~> 0.21'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc
gem 'sdoc'

gem 'unicorn'
gem 'unicorn-worker-killer'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # gem 'rails-footnotes'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'pry-rails'
  gem 'hirb'
  gem 'hirb-unicode'

  gem 'better_errors'
  gem 'binding_of_caller'

  # RSpec
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_bot_rails'
  gem 'faker'
  gem "shoulda-matchers"
end

gem 'ransack'  # 検索

# VIEWテンプレート
gem 'slim'
gem 'slim-rails'

# 認証
gem 'devise'
gem 'devise-bootstrap-views'
gem 'devise-i18n'
gem 'devise-i18n-views'
gem 'devise-encryptable'

# gem 'activeadmin', '= 2.1.0' # 管理者ページ
# gem 'active_bootstrap_skin'

gem 'gretel'         # パンくず
gem 'charwidth'      # 全角半角自動変換
gem 'kaminari'       # ページャ
gem 'kakurenbo-puti' # 論理削除

# フォーム関連
gem 'nested_form'
gem 'simple_form'

group :development do
  # デプロイ
  gem "capistrano"
  gem "capistrano-rails"
  gem "capistrano-bundler"
  gem "capistrano3-unicorn"
  # gem 'capistrano-sidekiq'
  # gem 'capistrano-bower'

  gem 'listen', '~> 3.0.5'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  gem 'rails-erd' # ER図書き出し

  gem 'html2slim'

  gem 'letter_opener' # メールテスト
  gem 'letter_opener_web'

  gem 'rails_real_favicon' # favicon
end

gem 'annotate'  # DBスキーマ書き出し


# assets
# source 'https://rails-assets.org' do
#   gem 'rails-assets-jquery-ujs'
#   gem 'rails-assets-bootstrap-sass-official'
#   gem 'rails-assets-jquery.lazyload'
#   gem 'rails-assets-bootstrap-fileinput'
#   gem 'rails-assets-bootstrap-select'
#   gem 'rails-assets-bootstrap3-datetimepicker'
#   gem 'rails-assets-moment'
# end
gem "bower-rails"

### SEO ###
gem 'sitemap_generator' # Googleサイトマップ
gem 'meta-tags'

gem 'activerecord-session_store' # セッションDB保存

# 画像ファイル保存・変換
gem 'carrierwave'
gem 'rmagick'
# gem 'fog'
gem "fog-aws"

# Google Analytics
# gem 'google-analytics-rails'
# gem 'google-analytics-turbolinks'

gem 'whenever', require: false # cron
gem 'ancestry'                 # カテゴリ階層構造

gem 'counter_culture' # 件数キャッシュ

# PDF
gem 'prawn'
gem 'prawn-table'
gem 'prawn-rails'

gem 'actionview-encoded_mail_to' # メールアドレスエンコード

gem 'redcarpet' # Markdown

gem 'twitter'

gem "mailchimp-api", require: "mailchimp"

gem 'jb'

### 似たものサーチ ###
gem 'npy'

# gem "dalli"
gem 'redis'
gem 'redis-rails'

gem 'aws-sdk-s3', '~> 1'

### python ###
# gem 'pycall'
# gem "rumale"
# gem "numo-linalg"

gem "turnout"

gem 'font-awesome-sass'
# gem 'bootstrap', '~> 3.2.3'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'sassc-rails', '>= 2.1.0'

gem 'therubyracer'
gem 'less-rails'

gem 'activerecord-import'