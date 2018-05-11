# == Schema Information
#
# Table name: toppage_logs
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  ip         :string
#  host       :string
#  referer    :string
#  ua         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ToppageLog < ApplicationRecord
  belongs_to :user, required: false

  before_save :check_robot

  private

  def check_robot
    host =~ DetailLog::ROBOTS || ip.blank? ? false : true
  end
end
