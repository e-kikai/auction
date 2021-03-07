if product.present?
  [
    product.id, product.name, product.dulation_start, product.dulation_end,
    product.start_price, product.prompt_dicision_price, product.lower_price,
    product.user_id, product.user&.company_remove_kabu,
    product.category_id, product.category&.name,
    product.bids_count, product.max_price,
    product.max_bid&.user_id,
    product.max_bid&.user&.account, product.max_bid&.user&.company, product.max_bid&.user&.name
  ]
else
  %w|
    商品ID 商品名 開始日時 終了日時
    開始価格 即売価格 最低落札価格
    出品会社ID 出品会社名
    カテゴリID カテゴリ名
    入札数 現在価格
    最高入札者ID
    最高入札者アカウント 最高入札者会社名 最高入札者氏名
  |
end