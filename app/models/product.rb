# == Schema Information
#
# Table name: products
#
#  id                     :integer          not null, primary key
#  user_id                :integer          not null
#  category_id            :integer          not null
#  name                   :string           default(""), not null
#  description            :text
#  dulation_start         :datetime
#  dulation_end           :datetime
#  sell_type              :integer          default(0), not null
#  start_price            :integer
#  prompt_dicision_price  :integer
#  ended_at               :datetime
#  addr_1                 :string
#  addr_2                 :string
#  shipping_user          :integer          default("落札者"), not null
#  shipping_type          :integer
#  delivery               :string
#  shipping_cost          :integer
#  shipping_okinawa       :integer
#  shipping_hokkaido      :integer
#  shipping_island        :integer
#  international_shipping :string
#  delivery_date          :integer          default("1〜2で発送"), not null
#  state                  :integer          default("中古"), not null
#  state_comment          :string
#  returns                :boolean          default(FALSE), not null
#  returns_comment        :string
#  auto_extension         :boolean          default(FALSE), not null
#  early_termination      :boolean          default(FALSE), not null
#  auto_resale            :integer
#  resaled                :integer
#  lower_price            :integer
#  special_featured       :boolean          default(FALSE), not null
#  special_bold           :boolean          default(FALSE), not null
#  special_bgcolor        :boolean          default(FALSE), not null
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

  # has_many   :product_images, -> { order(:order_no, :id) }
  has_many   :product_images
  # has_one    :top_image,      -> { order(:order_no, :id) }, class_name: "ProductImage"
  has_many   :bids
  has_one    :top_bid,    -> { result_order }, class_name: "Bid"
  has_one    :second_bid, -> { result_order.second }, class_name: "Bid"
  has_many   :mylists
  has_many   :mylist_users, through: :mylists, source: :user

  enum type:          { "オークションで出品" => 0, "定額で出品" => 100 }
  enum shipping_user: { "落札者" => 0, "出品者" => 100 }
  enum delivery_date: { "1〜2で発送" => 0, "3〜7で発送" => 100, "8日以降に発送" => 200 }
  enum state:         { "中古" => 0, "新品" => 100, "その他" => 200 }

  validates :name,        presence: true
  validates :start_price, presence: true, numericality: { only_integer: true, greater_than: 1 }
  validates :prompt_dicision_price, numericality: { only_integer: true }, allow_blank: true

  # validates :type,          presence: true, inclusion: {in: Product.types.keys}
  # validates :shipping_user, presence: true, inclusion: {in: Product.shipping_users.keys}
  # validates :delivery_date, presence: true, inclusion: {in: Product.delivery_dates.keys}
  validates :state,         presence: true, inclusion: {in: Product.states.keys}

  validates :returns,           inclusion: {in: [true, false]}
  validates :auto_extension,    inclusion: {in: [true, false]}
  validates :early_termination, inclusion: {in: [true, false]}
  validates :special_featured,  inclusion: {in: [true, false]}
  validates :special_bold,      inclusion: {in: [true, false]}
  validates :special_bgcolor,   inclusion: {in: [true, false]}

  accepts_nested_attributes_for :product_images

  scope :with_keywords, -> keywords {
    if keywords.present?
      columns = [:name, :description, :state, :state_comment, :returns_comment, :addr_1, :addr_2]
      where(keywords.split(/[[:space:]]/).reject(&:empty?).map {|keyword|
        columns.map { |a| arel_table[a].matches("%#{keyword}%") }.inject(:or)
      }.inject(:and))
    end
  }

  scope :finished, -> finished {
    if finished.blank?
      where("dulation_end > ?", Time.now)
    else
      where("dulation_end BETWEEN ? AND ?", Time.now-120.day, Time.now)
    end
  }

  before_create :default_max_price

  def top_bid
    bids.result_order.first
  end

  def second_bid
    bids.result_order[1]
  end

  def set_max_price
    self.max_price = if top_bid.blank?
      start_price
    elsif second_bid.blank?
      start_price
    else

    end
  end

  # 残り時間を取得
  def remaining_time
    second = ((dulation_end.presence || Time.now) - Time.now).round
    if second >= (60 * 60 * 24)
      "#{(second / (60 * 60 * 24)).round}日"
    elsif second >= (60 * 60)
      "#{(second / (60 * 60)).round}時間"
    elsif second >= 60
      "#{(second / 60).round}分"
    elsif second > 0
      "#{second}秒"
    else
      "終了"
    end
  end

  # 現在金額の入札単位を取得
  def bid_unit
    case
    when max_price < 1000;    10
    when max_price < 5000;   100
    when max_price < 10000;  250
    when max_price < 50000;  500
    else                    1000
    end
  end

  private

  def default_max_price
    self.max_price = start_price
  end

end
