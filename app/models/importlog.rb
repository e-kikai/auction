# == Schema Information
#
# Table name: importlogs
#
#  id         :bigint           not null, primary key
#  code       :string
#  message    :text
#  status     :integer
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_importlogs_on_product_id  (product_id)
#  index_importlogs_on_user_id     (user_id)
#

class Importlog < ApplicationRecord
  ### relations ###
  belongs_to :user,    required: true
  belongs_to :product, required: false

  ### enum ###
  enum status: { "info" => 0, "インポート開始" => 100, "インポート終了" => 200, "商品登録エラー" => 300, "画像登録エラー" => 400 }

end
