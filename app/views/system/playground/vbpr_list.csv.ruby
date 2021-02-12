require 'csv'

### ユーザID、商品ID、フラグ(1)ごとにArrayを生成する ###
@lists.sum do |list|
  [list[0], list[1]].to_csv
end

# result =  @lists.map { |list| list[0] }.to_csv
# result += @lists.map { |list| list[1] }.to_csv
# result += @lists.map { |list| 1 }.to_csv
