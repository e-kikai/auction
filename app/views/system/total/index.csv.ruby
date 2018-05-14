["ID", "会社名", "出品件数", "落札件数", "閲覧総数", "ウォッチ総数", "落札総額", "手数料(10%)"].to_csv +
@companies.sum do |co|
  month_products = co.products.where(dulation_end: @date.beginning_of_month..@date.end_of_month)
  fee_products   = month_products.where.not(fee: nil).order(:dulation_end)

  count        = month_products.count
  success      = fee_products.length
  access       = month_products.sum(:detail_logs_count)
  watch        = month_products.sum(:watches_count)
  price        = fee_products.sum(&:max_price)
  fee          = fee_products.sum(&:fee)
  fee_tax      = fee_products.sum(&:fee_tax)
  fee_with_tax = fee_products.sum(&:fee_with_tax)

  [co.id, co.company, count, success, access, watch, price, fee].to_csv
end.to_s
