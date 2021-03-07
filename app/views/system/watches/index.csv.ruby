%w|ID ユーザID アカウント 会社名 氏名 保存日時 削除日時|
  .concat(render("/system/watches/product", product: nil)).to_csv +
@watches.sum do |wa|
  [wa.id, wa.user_id, wa.user&.account, wa.user&.company, wa.user&.name,
    wa.created_at, wa.soft_destroyed_at]
    .concat(render("/system/watches/product", product: wa&.product)).to_csv
end.to_s
