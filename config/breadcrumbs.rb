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

crumb :myauction_products_confirm do
  link   "確認", "/myauction/products/confirm"
  parent :myauction_products_new
end

crumb :myauction_products do
  link   "出品一覧", "/myauction/products"
  parent :myauction
end

crumb :myauction_csv_new do
  link   "CSVインポート", "/myauction/csv/new"
  parent :myauction
end

crumb :myauction_csv_confirm do
  link   "確認", "/myauction/csv/confirm"
  parent :myauction_csv_new
end

crumb :myauction_bids_end do
  link   "落札分", "/myauction/bids/?cond=2"
  parent :myauction
end

crumb :myauction_bids_trade do |pr|
  link   "#{pr.name} 取引", "/myauction/trade/?product_id=#{pr.id}"
  parent :myauction_bids_end
end

crumb :myauction_bids_star do |pr|
  link   "#{pr.name} 受取確認・評価", "/myauction/star/#{pr.id}"
  parent :myauction_bids_end
end

crumb :myauction_products_end do
  link   "出品終了分(落札済み)", "/myauction/products/?cond=2"
  parent :myauction
end

crumb :myauction_products_trade do |pr|
  link   "#{pr.name} 取引", "/myauction/trade/?product_id=#{pr.id}"
  parent :myauction_products_end
end

crumb :myacution_categories do |ca|
  if ca.blank?
    link "カテゴリ管理", "/myauction/categories"
    parent :myauction
  elsif ca.root?
    link ca.name, "/myauction/categories"
    parent :myacution_categories
  else
    link ca.name, "/myauction/categories?parent_id=#{ca.id}"
    parent :myacution_categories, ca.parent
  end
end

crumb :myauction_categories_edit do |ca|
  if ca.name.blank?
    link "新規カテゴリ追加", "/myauction/categories/new"
  else
    link ca.name, "/myauction/categories/#{ca.id}/edit"
  end

  parent :myacution_categories, ca.parent
end

crumb :myauction_something do |title|
  link   title
  parent :myauction
end
