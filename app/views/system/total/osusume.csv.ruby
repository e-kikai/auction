["", "詳細クリック回数",
  "", "", "", "", "", "",
  "", "", "", "", "", "", "", "",
  "", "", "", "",
  "", "", "", "",
  "トップ -> 詳細回数",
  "", "", "", "", "", "",
  "", "", "", "", "", "", "",

  "詳細 -> 詳細回数",
  "", "", "", "", "", "",
  "", "", "", "", "", "",

  "詳細クリック ユーザ数", "", "", "", "", "", "", "",
  "詳細クリック IP数", "", "", "", "", "", "", "",
  "", "", "", "",
  "", "", "", "",
].to_csv +

["日付", "総数",
  "VBPR", "ウォッチオススメ", "入札オススメ", "入札してみませんか", "こちらもいかが", "上位カテゴリ新着",
  "フォロー新着",
  "まもなく終了", "工具新着", "機械新着", "こんなのも", "最近チェック", "閲覧履歴オススメ", "売れ筋商品", "商品を見た人の売れ筋"
  "似たものサーチ結果", "おなじカテゴリ", "似た商品", "検索結果",
  "メール", "マシンライフ", "e-kikai", "検索エンジン",

  "総回数",
  "VBPR", "ウォッチオススメ", "入札オススメ", "入札してみませんか", "こちらもいかが", "上位カテゴリ新着",
  "フォロー新着",
  "まもなく終了", "工具新着", "機械新着", "こんなのも", "最近チェック", "閲覧履歴オススメ",

  "総回数",
  "VBPR", "ウォッチオススメ", "入札オススメ", "入札してみませんか", "こちらもいかが", "上位カテゴリ新着",
  "まもなく終了", "工具新着", "機械新着", "こんなのも", "最近チェック", "閲覧履歴オススメ",

  "総ログインユーザ数",
  "VBPR", "ウォッチオススメ", "入札オススメ", "入札してみませんか", "こちらもいかが", "上位カテゴリ新着",
  "フォロー新着",
  "総IP数",
  "まもなく終了", "工具新着", "機械新着", "こんなのも", "最近チェック", "閲覧履歴オススメ", "売れ筋商品"
  "似たものサーチ結果", "おなじカテゴリ", "似た商品", "検索結果",
   "メール", "マシンライフ", "e-kikai", "検索エンジン"
].to_csv +

@rows.sum do |day|
  [day, @dl_counts[day],
    @vbpr_counts[day], @watch_counts[day], @bid_counts[day], @cart_counts[day], @nxt_counts[day], @often_counts[day],
    @follow_counts[day],
    @endo_counts[day], @tnew_counts[day], @mnew_counts[day], @zero_counts[day], @check_counts[day], @dlos_counts[day], @pops_counts[day], @upop_counts[day],
    @to_nms_counts[day], @sca_counts[day], @nmr_counts[day], @search_counts[day],
    @mail_counts[day], @ml_counts[day], @ekikai_counts[day], @google_counts[day],

    @top_dl[day],
    @top_vbpr[day], @top_watch[day], @top_bid[day], @top_cart[day], @top_nxt[day], @top_often[day],
    @top_follow[day],
    @top_endo[day], @top_tnew[day], @top_mnew[day], @top_zero[day], @top_check[day], @top_dlos[day],

    @dtl_dl[day],
    @dtl_vbpr[day], @dtl_watch[day], @dtl_bid[day], @dtl_cart[day], @dtl_nxt[day], @dtl_often[day],
    @dtl_endo[day], @dtl_tnew[day], @dtl_mnew[day], @dtl_zero[day], @dtl_check[day], @dtl_dlos[day],

    @dl_users[day],
    @vbpr_users[day], @watch_users[day], @bid_users[day], @cart_users[day], @nxt_users[day], @often_users[day],
    @follow_users[day],
    @dl_ips[day],
    @endo_ips[day], @tnew_ips[day], @mnew_ips[day], @zero_ips[day], @check_ips[day], @dlos_ips[day], @pops_ips[day], @upop_ips[day],
    @to_nms_counts[day], @sca_ips[day], @nmr_ips[day], @search_ips[day],
    @mail_ips[day], @ml_ips[day], @ekikai_ips[day], @google_ips[day],
  ].to_csv
end.to_s
