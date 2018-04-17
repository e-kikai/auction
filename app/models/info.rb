class Info < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  ### validates ###
  validates :title,    presence: true
  validates :content,  presence: true
  validates :target,   presence: true
  validates :start_at, presence: true

  ### enum ###
  enum target: { "ユーザ" => 0, "出品会社" => 100 }
end
