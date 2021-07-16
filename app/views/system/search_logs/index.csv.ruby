%w[ID アクセス日時 IP ホスト名 utag ユーザID アカウント 会社名 ユーザ名 未ログイン
  出品会社 カテゴリ キーワード 検索ID 公開 タイトル
  リンク元 リファラ].to_csv +
@search_logs.sum do |lo|

  [
    lo.id, lo.created_at, lo.ip, lo.host, lo.utag, lo.user_id,
    lo.user&.account, lo.user&.company, lo.user&.name, (lo.nonlogin? ? "◯" : ""),

    lo.company.try(:company_remove_kabu),
    lo.category.try(:name),
    lo.keywords,
    lo.search_id,
    ("○" if lo.search.try(:publish)),
    lo.search.try(:name),

    URI.unescape(lo.link_source.to_s), URI.unescape(lo.referer.to_s),
  ].to_csv
end
