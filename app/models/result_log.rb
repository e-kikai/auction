class ResultLog < ApplicationRecord
  belongs_to :product, required: true
  belongs_to :bid,     required: false
end
