# == Schema Information
#
# Table name: products
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  category_id            :integer
#  name                   :string
#  description            :text
#  dulation_start         :datetime
#  dulation_end           :datetime
#  type                   :integer
#  start_price            :integer
#  prompt_dicision_price  :integer
#  ended_at               :datetime
#  addr_1                 :string
#  addr_2                 :string
#  shipping_user          :integer
#  shipping_type          :integer
#  delivery               :string
#  shipping_cost          :integer
#  shipping_okinawa       :integer
#  shipping_hokkaido      :integer
#  shipping_island        :integer
#  international_shipping :string
#  delivery_date          :integer
#  state                  :integer
#  state_comment          :string
#  returns                :boolean
#  returns_comment        :string
#  auto_extension         :boolean
#  early_termination      :boolean
#  auto_resale            :integer
#  resaled                :integer
#  lower_price            :integer
#  special_featured       :boolean
#  special_bold           :boolean
#  special_bgcolor        :boolean
#  special_icon           :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  soft_destroyed_at      :datetime
#

class Product < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :user,     required: true
  belongs_to :category, required: true

  has_many   :product_images, -> { order(:order_no, :id) }
  has_one    :top_image,      -> { order(:order_no, :id) }, class_name: "ProductImage"
  has_many   :bids
  has_one    :top_bid,    -> { result_order }, class_name: "Bid"
  has_one    :second_bid, -> { result_order.second }, class_name: "Bid"
  has_many   :mylists
  has_many   :mylist_users, through: :mylists, source: :user

  validates :name,      presence: true
  validates :start_price, presence: true
  validates :start_price, numericality: { only_integer: true }
  validates :prompt_dicision_price, numericality: { only_integer: true }

  enum type:          { "オークションで出品" => 0, "定額で出品" => 100 }
  enum shipping_user: { "落札者" => 0, "出品者" => 100 }
  enum delivery_date: { "1〜2で発送" => 0, "3〜7で発送" => 100, "8日以降に発送" => 200 }
  enum state:         { "中古" => 0, "新品" => 100, "その他" => 200 }

  scope :with_keywords, -> keywords {
    if keywords.present?
      columns = [:name, :description, :state, :state_comment, :returns_comment, :addr_1, :addr_2]
      where(keywords.split(/[[:space:]]/).reject(&:empty?).map {|keyword|
        columns.map { |a| arel_table[a].matches("%#{keyword}%") }.inject(:or)
      }.inject(:and))
    end
  }

  def top_price

  end

end
