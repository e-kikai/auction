Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.reload_classes_only_on_change = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # if Rails.root.join('tmp/caching-dev.txt').exist?
  #   config.action_controller.perform_caching = true
  #
  # config.cache_store = :memory_store
  # config.cache_store = :dalli_store, '192.168.33.110', '192.168.33.110', { :namespace => mnok, :expires_in => 1.day, :compress => true }
  # config.cache_store = :file_store, "#{Rails.root}/tmp/cache"
  config.cache_store = :file_store , "/tmp/rails-cache/assets/#{Rails.env}/"

  # config.cache_store = :redis_store, 'redis://localhost:6379/2/cache', { expires_in: 90.day }

  #   config.public_file_server.headers = {
  #     'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
  #   }
  # else
  #   config.action_controller.perform_caching = false
  #
  #   config.cache_store = :null_store
  # end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.assets.digest = false

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.action_mailer.default_url_options = { host: '192.168.33.110', port: 8087 }
  config.action_mailer.delivery_method = :letter_opener_web

  # config.web_console.whitelisted_ips = '0.0.0.0/0'
end
