["", "検索回数", "", "検索人数", "",
  "詳細クリック回数", "", "", "",
  "詳細クリック人数", "", "", "",
  "似たものサーチ コンバージョン", "", "", ""].to_csv +
["日付", "総数", "似サ", "総人数", "似サ",
  "総回数", "似サ結果", "同カテゴリ", "似た商品",
  "総人数", "似サ結果", "同カテゴリ", "似た商品",
  "ウォッチ", "入札数", "落札数", "落札金額"].to_csv +
@rows.sum do |day|
  [day, @search_log_counts[day], @nms_counts[day], @search_user_counts[day], @nms_user_counts[day],
    @detail_log_counts[day], @nms_counts[day], @sca_counts[day], @nmr_counts[day],
    @detail_user_counts[day], @nms_user_counts[day], @sca_user_counts[day], @nmr_user_counts[day],
    @watches[day], @bids[day], @max_bid_counts[day], @max_bid_prices[day]
  ].to_csv
end.to_s
