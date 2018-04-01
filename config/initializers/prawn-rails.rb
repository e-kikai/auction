require 'prawn/measurement_extensions'

PrawnRails.config do |config|
  config.page_layout   = :landscape
  config.page_size     = "A4"
  config.skip_page_creation = true

  config.top_margin    = 8.mm
  config.bottom_margin = 8.mm
  config.left_margin   = 8.mm
  config.right_margin  = 8.mm
end
