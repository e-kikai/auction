### ユーザ画面 ###
crumb :root do
  link "ものオク", "/"
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
  # elsif ca.depth <= 1 # 工具のみのときの仮処理
  #   parent :root
  else
    parent :category, ca.parent
  end
end

crumb :company do |us|
  link   us.company, "/products?company_id=#{us.id}"
  parent :root
end

crumb :company_show do |us|
  link   "出品会社情報", "/companeis/#{us.id}"
  parent :company, us
end

crumb :products_show do |pr|
  link   pr.name, "/products/#{pr.id}"
  parent :category, pr.category
end

# crumb :products_nitamono do |pr|
#   link   "似たものサーチ", "/products/#{pr.id}/nitamono"
#   parent :products_show, pr
# end

crumb :products_bids do |pr|
  link   "入札履歴", "/products/#{pr.id}/bids"
  parent :products_show, pr
end

crumb :helps do
  link   "ヘルプ一覧", "/helps"
  parent :root
end

crumb :helps_show do |he|
  link   he.title, "/helps/#{he.id}"
  parent :helps
end

crumb :infos do
  link   "お知らせ一覧", "/infos"
  parent :root
end

crumb :infos_show do |inf|
  link   inf.title, "/infos/#{inf.id}"
  parent :infos
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
  link   "出品終了分 - 落札済", "/myauction/products/?cond=2"
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
    link ca.name, "/myauction/categories?parent_id=#{ca.id}"
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

crumb :myauction_helps do
  link   "出品者向けヘルプ一覧", "/myauction/helps"
  parent :myauction
end

crumb :myauction_helps_show do |he|
  link   he.title, "/myauction/helps/#{he.id}"
  parent :myauction_helps
end

crumb :myauction_infos do
  link   "出品者向けお知らせ一覧", "/myauction/infos"
  parent :myauction
end

crumb :myauction_infos_show do |inf|
  link   inf.title, "/myauction/infos/#{inf.id}"
  parent :myauction_infos
end

crumb :myauction_answers do
  link   "ユーザからの問合せ・取引一覧", "/myauction/answers"
  parent :myauction
end

crumb :myauction_answer do |product, owner|
  label = product.trade_success?(owner) ? "取引" : "問合せ"
  link   "#{product.name} | #{owner.company} #{owner.name} からの#{label}", "/myauction/answers/#{product.id}/#{owner.id}"
  parent :myauction_answers
end

crumb :myauction_contacts do
  link   "商品についての問合せ・取引一覧", "/myauction/contacts/"
  parent :myauction
end

crumb :myauction_contact do |product, owner|
  label = product.trade_success?(owner) ? "取引" : "問合せ"
  link   "#{product.name} についての#{label}", "/myauction/contacts/#{product.id}"
  parent :myauction_contacts
end


crumb :myauction_something do |title|
  link   title
  parent :myauction
end

### 管理者ページ ###
crumb :system do
  link   "管理者ページ", "/system/"
  # parent :root
end

crumb :system_categories do |ca|
  if ca.blank?
    link "カテゴリ管理", "/system/categories"
    parent :system
  elsif ca.root?
    link ca.name, "/system/categories?parent_id=#{ca.id}"
    parent :system_categories
  else
    link ca.name, "/system/categories?parent_id=#{ca.id}"
    parent :system_categories, ca.parent
  end
end

crumb :system_categories_edit do |ca|
  if ca.name.blank?
    link "新規カテゴリ追加", "/system/categories/new"
  else
    link ca.name, "/system/categories/#{ca.id}/edit"
  end

  parent :system_categories, ca.parent
end

crumb :system_users do
  link   "ユーザ管理", "/system/users/"
  parent :system
end

crumb :system_users_new do
  link   "新規ユーザ登録", "/system/users/new"
  parent :system_users
end

crumb :system_users_edit do |user|
  link   "ユーザ情報変更", "/system/users/#{user.id}/edit"
  parent :system_users
end

crumb :system_users_edit_password do |user|
  link   "パスワード変更", "/system/users/#{user.id}/edit_password"
  parent :system_users
end

crumb :system_helps do
  link   "ヘルプ管理", "/system/helps/"
  parent :system
end

crumb :system_helps_new do
  link   "新規ヘルプ登録", "/system/helps/new"
  parent :system_helps
end

crumb :system_helps_edit do |help|
  link   "ヘルプ変更", "/system/helps/#{help.id}/edit"
  parent :system_helps
end

crumb :system_infos do
  link   "お知らせ管理", "/system/infos/"
  parent :system
end

crumb :system_infos_new do
  link   "新規お知らせ登録", "/system/infos/new"
  parent :system_infos
end

crumb :system_infos_edit do |info|
  link   "お知らせ変更", "/system/infos/#{info.id}/edit"
  parent :system_infos
end

crumb :system_trades do
  link   "問い合わせ履歴", "/system/trades/"
  parent :system
end

crumb :system_trades_show do |product, owner|
  link   "#{product.name} | #{owner.company} #{owner.name} 問い合わせ", "/system/trades/#{product.id}/#{owner.id}"
  parent :system_trades
end

crumb :system_something do |title|
  link   title
  parent :system
end
