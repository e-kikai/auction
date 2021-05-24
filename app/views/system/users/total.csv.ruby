%w|ID アカウント 会社名 ユーザ名 都道府県 メールアドレス 出品
  入札件数 落札件数 落札金額 詳細閲覧 ウォッチ お気にいり フォロー ユーザ登録日時|.to_csv +
@user_ids.map do |uid|
  us = @users.find { |u| u.id == uid } || next

  [
    us.id, us.account, us.company, us.name, us.addr_1, us.email, (us.seller? ? "◯" : ""),
    @bids_count[us.id], @count_max_price[us.id], @sum_max_price[us.id],
    @detail_count[us.id], @watches_count[us.id], @searches_count[us.id],
    @follows_count[us.id], I18n.l(us.created_at, format: :full_date)
  ].to_csv
end.join.to_s
