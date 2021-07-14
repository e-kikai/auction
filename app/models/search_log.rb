# == Schema Information
#
# Table name: search_logs
#
#  id                  :bigint           not null, primary key
#  host                :string
#  ip                  :string
#  keywords            :string
#  nonlogin            :boolean          default(TRUE)
#  page                :integer          default(1), not null
#  path                :string           default(""), not null
#  r                   :string           default(""), not null
#  referer             :string
#  ua                  :string
#  utag                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  category_id         :bigint
#  company_id          :integer
#  nitamono_product_id :bigint
#  search_id           :bigint
#  user_id             :bigint
#
# Indexes
#
#  index_search_logs_on_category_id  (category_id)
#  index_search_logs_on_search_id    (search_id)
#  index_search_logs_on_user_id      (user_id)
#

class SearchLog < ApplicationRecord
  belongs_to :user,     required: false
  belongs_to :category, required: false
  belongs_to :company,  class_name: "User",   required: false
  belongs_to :search,   required: false
  belongs_to :nitamono_product, class_name: "Product", required: false

  before_save :check_robot

  def link_source
    DetailLog.link_source(r, referer)
  end

  private

  def check_robot
    host =~ DetailLog::ROBOTS || ip.blank? ? false : true
  end
end
