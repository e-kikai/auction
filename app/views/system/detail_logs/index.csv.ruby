%w[ID アクセス日時 IP ホスト名 アカウント 会社・ユーザ名 商品ID 商品名 最高金額 リンク元 リファラ].to_csv +
@detail_logs.sum do |lo|

  linked = if lo.r.present?
    lo.r.split("_").map { |kwd| DetailLog::KWDS[kwd] || kwd }.join(" | ")
  elsif lo.referer =~ /https\:\/\/google\.com/
    "Google"
  elsif lo.referer =~ /https\:\/\/www\.facebook\.com/
    "facebook"
  elsif lo.referer =~ /https\:\/\/t\.co/
    "Twitter"
  elsif lo.referer =~ /http\:\/\/search\.yahoo\.co\.jp/
    "Yahoo"
  elsif lo.referer =~ /https\:\/\/www\.bing\.com/
    "bing"
  else
    "その他不明"
  end

  [
    lo.id, lo.created_at, lo.ip, lo.host,
    lo.user.try(:account), "#{lo.user.try(:company)} #{lo.user.try(:name)}".strip,
    lo.product_id,
    lo.product ? lo.product.name : "× (削除された商品)",
    lo.product ? number_to_currency(lo.product.max_price) : "",
    linked, lo.referer
  ].to_csv
end
