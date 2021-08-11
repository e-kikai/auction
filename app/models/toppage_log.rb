# == Schema Information
#
# Table name: toppage_logs
#
#  id         :bigint           not null, primary key
#  host       :string
#  ip         :string
#  nonlogin   :boolean          default(TRUE)
#  r          :string           default(""), not null
#  referer    :string
#  ua         :string
#  utag       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_toppage_logs_on_user_id  (user_id)
#

class ToppageLog < ApplicationRecord
  belongs_to :user, required: false

  before_save :check_robot

  def link_source
    DetailLog.link_source(r, referer)
  end

  private

  def check_robot
    # host =~ DetailLog::ROBOTS || ip.blank? ? false : true
    throw(:abort) unless DetailLog.check_robot(host, ip)
  end
end
