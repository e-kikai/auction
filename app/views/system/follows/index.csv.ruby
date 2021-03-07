%w|
  ID ユーザID アカウント 会社名 氏名
  フォロー会社ID フォロー会社名
  保存日時 削除日時
|.to_csv +
@follows.sum do |fo|
  [
    fo.id, fo.user_id, fo.user&.account, fo.user&.company, fo.user&.name,
    fo.to_user_id, fo.to_user&.company,
    fo.created_at, fo.soft_destroyed_at
  ].to_csv
end.to_s
