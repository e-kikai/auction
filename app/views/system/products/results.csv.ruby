[
  "ID", "商品名", "出品会社ID", "出品会社名", "登録日時", "開始日時", "終了日時",
  "開始価格", "最低落札価格", "即売価格", "現状",
  "最高価格", "最高入札者",
  "入札数", "閲覧数", "ウォッチ数",
  "カテゴリID", "カテゴリ名", "カテゴリ階層"].to_csv +
@products.sum do |pr|
  [
    pr.id, pr.name, pr.user_id, pr.user.company, pr.created_at, pr.dulation_start, pr.dulation_end,
    # pr.start_price, pr.lower_price, pr.prompt_dicision_price, pr.status,
    # pr.max_price, pr.max_bid.try(:user).try(:account),
    pr.start_price_with_tax, pr.lower_price_with_tax, pr.prompt_dicision_price_with_tax, pr.status,
    pr.max_price_with_tax, pr.max_bid&.user&.account,
    pr.bids_count, pr.detail_logs_count, pr.watches_count,
    pr.category_id, pr.category.name, pr.category.ancestor_names
  ].to_csv
end
