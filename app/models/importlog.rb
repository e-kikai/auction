# == Schema Information
#
# Table name: importlogs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  product_id :integer
#  status     :integer
#  code       :string
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  url        :string
#

class Importlog < ApplicationRecord
  ### relations ###
  belongs_to :user,    required: true
  belongs_to :product, required: false

  ### enum ###
  enum status: { "info" => 0, "インポート開始" => 100, "インポート終了" => 200, "商品登録エラー" => 300, "画像登録エラー" => 400 }

end
