%w[ID アクセス日時 IP ホスト名 utag ユーザID
  アカウント 会社名 ユーザ名 未ログイン
  リンク元 リファラ].to_csv +
@toppage_logs.sum do |lo|
  [
    lo.id, lo.created_at, lo.ip, lo.host, lo.utag, lo.user_id,
    lo.user&.account, lo.user&.company, lo.user&.name, (lo.nonlogin? ? "◯" : ""),

    URI.unescape(lo.link_source.to_s), URI.unescape(lo.referer.to_s),
  ].to_csv
end
