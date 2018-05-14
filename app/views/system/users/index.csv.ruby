["ID", "ユーザ名", "会社名", "メールアドレス"].to_csv +
@users.sum do |us|
  [us.id, us.name, us.company, us.email].to_csv
end.to_s
