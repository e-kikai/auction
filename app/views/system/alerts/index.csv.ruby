%w|
  ID ユーザID アカウント 会社名 氏名
  通知タイトル
  カテゴリID カテゴリ 出品会社ID 出品会社名 検索キーワード
  保存日時 削除日時
|.to_csv +
@alerts.sum do |al|
  [
    al.id, al.user_id, al.user&.account, al.user&.company, al.user&.name,
    al.name,
    al.category_id, al.category&.name, al.company_id, al.company&.company_remove_kabu, al.keywords,
    al.created_at, al.soft_destroyed_at
  ].to_csv
end.to_s
