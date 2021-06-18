%w[ID アクセス日時 IP ホスト名 utag ユーザID アカウント 会社名 ユーザ名 商品ID 商品名 出品会社ID
  出品会社名 最高金額 入札数 リンク元 リファラ カテゴリID カテゴリ名 カテゴリ階層].to_csv +
@detail_logs.sum do |lo|

  [
    lo.id, lo.created_at, lo.ip, lo.host, lo.utag, lo.user_id,
    lo.user&.account, lo.user&.company, lo.user&.name,
    lo.product_id,
    lo.product ? lo.product.name : "× (削除された商品)",
    lo.product ? lo.product.user_id : "",
    lo.product ? lo.product.user.company : "",

    # lo.product ? number_to_currency(lo.product.max_price) : "",
    lo.product ? number_to_currency(lo.product.max_price_with_tax) : "",
    lo.product ? lo.product.bids_count : "",
    URI.unescape(lo.link_source.to_s), URI.unescape(lo.referer.to_s).scrub('♪'),

    lo.product ? lo.product.category_id : "",
    lo.product ? lo.product.category.name : "",
    lo.product ? lo.product.category.ancestor_names : "",
  ].to_csv
end
