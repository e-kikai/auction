require 'csv'

### ユーザID、商品ID、フラグ(1)ごとにArrayを生成する ###
res = ["product_id"].to_csv
@products_ids.each do |val|
  res += [val].to_csv
end

res
