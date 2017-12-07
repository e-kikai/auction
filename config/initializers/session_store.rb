# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_omdc2_session'
Rails.application.config.session_store :active_record_store, key: '_auction_session', expire_after: 8.year
