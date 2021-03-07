%w|
  ID ユーザID アカウント 会社名 氏名
  検索条件名
  カテゴリID カテゴリ 出品会社ID 出品会社名 検索キーワード
  公開 利用数
  保存日時 削除日時
|.to_csv +
@searches.sum do |se|
  [
    se.id, se.user_id, se.user&.account, se.user&.company, se.user&.name,
    se.name,
    se.category_id, se.category&.name, se.company_id, se.company&.company_remove_kabu, se.keywords,
    ('○' if se.publish), @search_log_counts[se.id],
    se.created_at, se.soft_destroyed_at
  ].to_csv
end.to_s
