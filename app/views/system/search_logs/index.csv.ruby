%w[ID アクセス日時 IP ホスト名 アカウント 会社・ユーザ名
  出品会社 カテゴリ キーワード 検索ID 公開 タイトル
  リンク元 リファラ].to_csv +
@search_logs.sum do |lo|

  [
    lo.id, lo.created_at, lo.ip, lo.host,
    lo.user.try(:account), "#{lo.user.try(:company)} #{lo.user.try(:name)}".strip,

    lo.company.try(:company_remove_kabu),
    lo.category.try(:name),
    lo.keywords,
    lo.search_id,
    ("○" if lo.search.try(:publish)),
    lo.search.try(:name),

    URI.unescape(lo.link_source), URI.unescape(lo.referer),
  ].to_csv
end
