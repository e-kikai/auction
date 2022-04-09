header  = %w|送信日時 商品名 詳細|
columns = %w|requests.created_at requests.name requests.detail|

CSV.generate do |row|
  row << header

  @requests.pluck(columns).each do |re|
    ### 整形 ###

    row << re
  end
end
