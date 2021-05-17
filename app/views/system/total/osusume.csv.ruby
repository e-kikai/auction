["", "詳細クリック回数",
  "", "", "", "", "", "",
  "", "", "", "", "", "", "",
  "", "", "", "",
  "", "", "", "",
  "詳細クリック ユーザ数", "", "", "", "", "", "", "",
  "詳細クリック IP数", "", "", "", "", "", "",
  "", "", "", "",
  "", "", "", "",
].to_csv +

["日付", "総数",
  "VBPR", "ウォッチオススメ", "入札オススメ", "入札してみませんか", "こちらもいかが", "上位カテゴリ新着",
  "フォロー新着",
  "まもなく終了", "工具新着", "機械新着", "こんなのも", "最近チェック", "閲覧履歴オススメ",
  "似たものサーチ結果", "おなじカテゴリ", "似た商品", "検索結果",
   "メール", "マシンライフ", "e-kikai", "検索エンジン"

  "総ログインユーザ数",
  "VBPR", "ウォッチオススメ", "入札オススメ", "入札してみませんか", "こちらもいかが", "上位カテゴリ新着",
  "フォロー新着",
  "総IP数",
  "まもなく終了", "工具新着", "機械新着", "こんなのも", "最近チェック", "閲覧履歴オススメ",
  "似たものサーチ結果", "おなじカテゴリ", "似た商品", "検索結果",
   "メール", "マシンライフ", "e-kikai", "検索エンジン"
].to_csv +

@rows.sum do |day|
  [day, @dl_counts[day],
    @vbpr_counts[day], @watch_counts[day], @bid_counts[day], @cart_counts[day], @nxt_counts[day], @often_counts[day],
    @follow_counts[day],
    @endo_counts[day], @tnew_counts[day], @mnew_counts[day], @zero_counts[day], @check_counts[day], @dlos_counts[day],
    @sca_counts[day], @nmr_counts[day], @to_nms_counts[day], @search_counts[day],
    @mail_counts[day], @ml_counts[day], @ekikai_counts[day], @google_counts[day],

    @dl_users[day],
    @vbpr_users[day], @watch_users[day], @bid_users[day], @cart_users[day], @nxt_users[day], @often_users[day],
    @follow_users[day],
    @dl_ips[day],
    @endo_ips[day], @tnew_ips[day], @mnew_ips[day], @zero_ips[day], @check_ips[day], @dlos_ips[day],
    @sca_ips[day], @nmr_ips[day], @to_nms_counts[day], @search_ips[day],
    @mail_ips[day], @ml_ips[day], @ekikai_ips[day], @google_ips[day],

  ].to_csv
end.to_s
