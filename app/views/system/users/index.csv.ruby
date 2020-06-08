["ID", "ユーザ名", "会社名", "メールアドレス", "出品会社"].to_csv +
@users.sum do |us|
  [us.id, us.name, us.company, us.email, (us.seller? ? :company : :user)].to_csv
end.to_s
