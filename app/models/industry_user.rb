class IndustryUser < ApplicationRecord
  belongs_to :user
  belongs_to :industry
end
