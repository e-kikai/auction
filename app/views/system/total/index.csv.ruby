["ID", "会社名", "担当者名", "メールアドレス", "総出品件数",
   "出品件数", "落札件数", "閲覧総数", "ウォッチ総数", "落札総額", "システム使用料(10%)"].to_csv +
@companies.sum do |co|
  month_products = co.products.where(cancel: nil, dulation_end: @rstart..@rend)
  fee_products   = month_products.where.not(fee: nil).order(:dulation_end)

  count        = month_products.count
  success      = fee_products.length
  access       = month_products.sum(:detail_logs_count)
  watch        = month_products.sum(:watches_count)
  price        = fee_products.sum(&:max_price)
  fee          = price * Product::FEE_RATE / 100
  # fee_tax      = fee_products.sum(&:fee_tax)
  # fee_with_tax = fee_products.sum(&:fee_with_tax)

  [co.id, co.company, co.charge, co.email, @product_counts[co.id],
    count, success, access, watch, price, fee].to_csv
end.to_s
