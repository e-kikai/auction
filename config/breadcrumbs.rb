### ユーザ画面 ###
crumb :root do
  link "TOP", "/"
end

crumb :something do |title|
  link   title
  parent :root
end

crumb :search do |q|
  link   "検索結果", "/products/"
  parent :root
end

crumb :category do |ca|
  link ca.name, "/products?category_id=#{ca.id}"
  if ca.root?
    parent :root
  else
    parent :category, ca.parent
  end
end

crumb :products_show do |pr|
  link   pr.name, "/products/#{pr.id}"
  parent :category, pr.category
end



### マイ・オークション ###
crumb :myauction do
  link   "マイ・オークション", "/myauction/"
  parent :root
end

crumb :myauction_bid_new do |pr|
  link   "入札確認", "/products/bids/new?id=#{pr.id}"
  parent :products_show, pr
end

crumb :myauction_bid_show do |bi|
  link   "入札完了", "/products/bids/#{bi.id}"
  parent :products_show, bi.product
end

crumb :myauction_products_new do
  link   "出品する", "/myauction/products/new"
  parent :myauction
end

crumb :myauction_products do
  link   "出品一覧", "/myauction/products"
  parent :myauction
end

crumb :myauction_something do |title|
  link   title
  parent :myauction
end
