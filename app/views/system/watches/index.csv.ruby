%w|ID utag ユーザID アカウント 会社名 氏名 未ログイン 保存日時 削除日時 リンク元 リファラ|
  .concat(render("/system/watches/product", product: nil)).to_csv +
@watches.sum do |wa|
  [wa.id, wa.utag, wa.user_id, wa.user&.account, wa.user&.company, wa.user&.name, (wa.nonlogin? ? "◯" : ""),
    wa.created_at, wa.soft_destroyed_at,
    URI.unescape(wa.link_source.to_s), URI.unescape(wa.referer.to_s),
  ].concat(render("/system/watches/product", product: wa&.product)).to_csv
end.to_s
