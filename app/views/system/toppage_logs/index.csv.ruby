%w[ID アクセス日時 IP ホスト名 アカウント 会社・ユーザ名
  リンク元 リファラ].to_csv +
@toppage_logs.sum do |lo|

  [
    lo.id, lo.created_at, lo.ip, lo.host,
    lo.user.try(:account), "#{lo.user.try(:company)} #{lo.user.try(:name)}".strip,

    lo.product ? lo.product.bids_count : "",
    lo.link_source, URI.unescape(lo.referer),
  ].to_csv
end
