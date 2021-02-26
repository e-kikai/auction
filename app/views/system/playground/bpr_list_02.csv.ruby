require 'csv'

### ユーザID、商品ID、フラグ(1)ごとにArrayを生成する ###
["user_id", "product_id", "bias"].to_csv +
@lists.sum do |key, val|
  [key[0], key[1], val].to_csv
end
