# == Schema Information
#
# Table name: search_logs
#
#  id          :bigint(8)        not null, primary key
#  user_id     :bigint(8)
#  category_id :bigint(8)
#  company_id  :integer
#  keywords    :string
#  search_id   :bigint(8)
#  ip          :string
#  host        :string
#  referer     :string
#  ua          :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SearchLog < ApplicationRecord
  belongs_to :user,     required: false
  belongs_to :category, required: false
  belongs_to :company,  class_name: "User", required: false
  belongs_to :search,   required: false

  before_save :check_robot

  private

  def check_robot
    host =~ DetailLog::ROBOTS || ip.blank? ? false : true
  end
end
