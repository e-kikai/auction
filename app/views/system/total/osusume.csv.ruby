["", "詳細クリック回数",
  "", "", "", "", "", "",
  "", "", "", "", "", "",
  "詳細クリック ユーザ数", "", "", "", "", "", "",
  "詳細クリック IP数", "", "", "", "", "", ""].to_csv +

["日付", "総数",
  "VBPR", "ウォッチオススメ", "入札オススメ", "入札してみませんか", "こちらもいかが", "上位カテゴリ新着",
  "まもなく終了", "工具新着", "機械新着", "こんなのも", "最近チェック", "閲覧履歴オススメ",

  "総ログインユーザ数",
  "VBPR", "ウォッチオススメ", "入札オススメ", "入札してみませんか", "こちらもいかが", "上位カテゴリ新着",
  "総IP数",
  "まもなく終了", "工具新着", "機械新着", "こんなのも", "最近チェック", "閲覧履歴オススメ"].to_csv +

@rows.sum do |day|
  [day, @dl_counts[day],
    @vbpr_counts[day], @watch_counts[day], @bid_counts[day], @cart_counts[day], @nxt_counts[day], @often_counts[day],
    @endo_counts[day], @tnew_counts[day], @mnew_counts[day], @zero_counts[day], @check_counts[day], @dlos_counts[day],

    @dl_users[day],
    @vbpr_users[day], @watch_users[day], @bid_users[day], @cart_users[day], @nxt_users[day], @often_users[day],
    @dl_ips[day],
    @endo_ips[day], @tnew_ips[day], @mnew_ips[day], @zero_ips[day], @check_ips[day], @dlos_ips[day],
  ].to_csv
end.to_s
