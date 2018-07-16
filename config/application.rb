require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

require "charwidth"
require "charwidth/string"
# require "charwidth/active_record"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Auction
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil

    I18n.available_locales = I18n.available_locales.push(:ja)
    config.i18n.default_locale = :ja

    config.active_record.default_timezone = :local
    config.time_zone = 'Tokyo'

    # config.active_job.queue_adapter = :sidekiq

    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default_url_options = { :host => 'localhost' }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address => Rails.application.secrets.mail_smtp_server,
      :port => 587,
      :user_name => Rails.application.secrets.mail_user_name,
      :password => Rails.application.secrets.mail_passwd,

      :authentication => :plain,
      :enable_starttls_auto => true
    }
  end
end
