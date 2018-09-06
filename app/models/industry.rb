class Industry < ApplicationRecord
  soft_deletable

  has_many   :industry_users
  has_many   :users, through: :industry_users
end
