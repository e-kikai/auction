# == Schema Information
#
# Table name: detail_logs
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  product_id :integer
#  ip         :string
#  host       :string
#  ua         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  referer    :string
#

class DetailLog < ApplicationRecord
  belongs_to :user,    required: false
  belongs_to :product, required: true
  counter_culture :product

  before_save :check_robot

  ROBOTS = /(google|yahoo|naver|ahrefs|msnbot|bot|crawl|amazonaws)/

  private

  def check_robot
    host !~ ROBOTS && ip.present?
  end
end
