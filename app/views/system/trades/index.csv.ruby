render("/system/watches/product", product: nil).concat(
%w|
  ユーザID アカウント 会社名 氏名
  書込数 開始日時 最終更新
|).to_csv +
@threads_02.sum do |th|
  gro = [th.product_id, th.owner_id]
  render("/system/watches/product", product: th&.product).concat(
    [
      th.owner_id, th.owner&.account, th.owner&.company, th.owner&.name,
      @thread_counts_02[gro], @thread_starts_02[gro], th.created_at
    ]).to_csv
end.to_s
