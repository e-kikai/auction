%w|ID 商品名 最低価格 ウォッチ数(商品名合算)|.to_csv +
@populars.sum do |pr|
  [pr.id, pr.name, pr.start_price_with_tax, pr.count].to_csv
end
