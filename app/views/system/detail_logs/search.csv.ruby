head = if @user.present?
  [
    ["ユーザID", @user.id],
    ["会社名", @user.company],
    ["氏名", @user.name],
    ["アカウント", @user.account],
    ["都道府県", "#{@user.addr_1}"],
    ["業種", @user.industries.map { |ind| ind.name }.join(" | ")],
    ["出品", @user.seller? ? "○" : ""],
    ["案内メール", @user.allow_mail? ? "○" : ""],
    ["登録日時", @user.created_at],
    ["IP", "#{@user.last_sign_in_ip} | #{@user.current_sign_in_ip}"],
    []
  ].sum {|row| row.to_csv }
elsif params[:user_id].present?
  [
    ["IP", params[:user_id]],
    []
  ].sum {|row| row.to_csv }
else
  ""
end

labels = %w[アクセス日時 アクション]
labels += %w[IP ユーザID ユーザ名] if @user.blank?
labels += %w[IP推測] if @user.present?
labels += %w[商品ID 商品名 詳細 現在価格 入札数 入札金額 ページ数 リンク元]

head +
labels.to_csv +
@relogs.sum do |lo|
  res = [
    lo[:created_at],
    lo[:klass][0]
  ]

  res += if @user.blank?
    [
      lo[:ip],
      lo[:user_id],
      lo[:user_name],
    ]
  else
    [ lo[:ip_guess] ? "○" : "", ]
  end

  res += [
    lo[:product_id],
    lo[:product_name],
    lo[:con].join(' | '),

    lo[:max_price],
    lo[:bids_count],
    lo[:amount],
    lo[:page],
    lo[:ref],
  ]

  res.to_csv
end
