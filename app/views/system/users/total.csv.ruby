%w|ID アカウント 会社名 ユーザ名 都道府県 出品 入札件数 落札件数 落札金額 ウォッチ数 お気いり数 フォロー数 ユーザ登録日時|.to_csv +
@user_ids.sum('') do |uid|
  us = @users.find { |u| u.id == uid } || next

  [us.id, us.account, us.company, us.name, us.addr_1, (us.seller? ? "◯" : "×"), @bids_count[us.id], @count_max_price[us.id], @sum_max_price[us.id], @watches_count[us.id], @searches_count[us.id], @follows_count[us.id], I18n.l(us.created_at, format: :full_date)].to_csv
end.to_s
