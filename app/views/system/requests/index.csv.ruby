header  = %w|ID utag ユーザID 会社名 氏名 アカウント 都道府県 商品名 詳細 送信日時|
columns = %w|
  requests.id users.utag users.id users.company users.name users.accuont users.addr_1
  requests.name requests.detail requests.created_at
|

CSV.generate do |row|
  row << header

  @requests.pluck(columns).each do |re|
    ### 整形 ###

    row << re
  end
end
