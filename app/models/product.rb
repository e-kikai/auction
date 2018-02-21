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
#  max_price              :integer          default(0)
#  bids_count             :integer          default(0)
#  max_bid_id             :integer
#  resale_count           :integer          default(0)
#  code                   :string
#  template               :boolean          default(FALSE), not null
#  machinelife_id         :integer
#  machinelife_images     :text
#  shipping_no            :integer
#  cancel                 :text
#  hashtags               :text
#

class Product < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  ### クラス定数 ###
  STATUS                 = { before: -1, start: 0, failure: 1, success: 2, cancel: 3 }
  MACHINELIFE_MEDIA_PASS = "http://www.zenkiren.net/media/machine/"
  CSV_MAX_COUNT          = 30
  NEW_MAX_COUNT          = 16 # 新着表示数

  TAX_RATE               = 8

  ### relations ###
  belongs_to :user,     required: true
  belongs_to :category, required: true
  belongs_to :max_bid,  class_name: "Bid", required: false

  # has_many   :product_images, -> { order(:order_no, :id) }
  has_many   :product_images
  # has_one    :top_image,      -> { order(:order_no, :id) }, class_name: "ProductImage"
  has_many   :bids
  has_many   :mylists
  has_many   :mylist_users, through: :mylists, source: :user
  has_many   :trades

  ### enum ###
  enum type:          { "オークションで出品" => 0, "定額で出品" => 100 }
  enum shipping_user: { "落札者" => 0, "出品者" => 100 }
  enum delivery_date: { "1〜2で発送" => 0, "3〜7で発送" => 100, "8日以降に発送" => 200 }
  enum state:         { "中古" => 0, "新品" => 100, "その他" => 200 }


  ### validates ###
  validates :name,        presence: true
  validates :start_price, presence: true, numericality: { only_integer: true, greater_than: 0 }
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
  validates :template,          inclusion: {in: [true, false]}

  validates :machinelife_id, uniqueness: { scope: [ :soft_destroyed_at ] }, allow_blank: true


  ### nest ###
  accepts_nested_attributes_for :product_images, allow_destroy: true


  ### SCOPE ###
  scope :with_keywords, -> keywords {
    if keywords.present?
      columns = [:name, :description, :state_comment, :returns_comment, :addr_1, :addr_2]
      where(keywords.split(/[[:space:]]/).reject(&:empty?).map {|keyword|
        columns.map { |a| arel_table[a].matches("%#{keyword}%") }.inject(:or)
      }.inject(:and))
    end
  }

  # scope :finished, -> finished {
  #   if finished.blank?
  #     where("dulation_end > ?", Time.now).where("template = ?", false)
  #   else
  #     where("dulation_end BETWEEN ? AND ?", Time.now-120.day, Time.now).where("template = ?", false)
  #   end
  # }

  scope :status, -> cond {
    case cond.to_i
    when STATUS[:before];  where("dulation_start > ? ", Time.now).order(:dulation_start) # 開始前
    when STATUS[:failure]; where("dulation_end BETWEEN ? AND ? AND max_bid_id IS NULL", Time.now-120.day, Time.now).order(dulation_end: :desc) # 未落札
    when STATUS[:success]; where("dulation_end BETWEEN ? AND ? AND max_bid_id IS NOT NULL", Time.now-120.day, Time.now).order(dulation_end: :desc) # 落札済み

    else;                  where("dulation_start <= ? AND dulation_end > ?", Time.now, Time.now).order(:dulation_end)  # 公開中
    end
  }

  scope :templates, -> {
    where("template = ?", true)
  }

  ### callback ###
  before_create :default_max_price

  ### インポート用getter setter ###
  attr_accessor :template_id, :template_name

  ### 現在の最高入札と入札金額を比較 ###
  def versus(bid)

    if prompt_dicision_price.present? && prompt_dicision_price <= bid.amount
      # 即決価格
      self.max_price = prompt_dicision_price
      self.max_bid   = bid
      self.dulation_end = Time.now
    elsif max_bid.blank?
      # 入札なしの場合
      self.max_price = start_price
      self.max_bid   = bid
    elsif max_bid.user == bid.user
      # 再入札(入札金額の変更)
      self.max_bid   = bid
    elsif bid.amount > max_bid.amount + bid_unit
      # 新しい入札の勝ち(入札単位以上)
      self.max_price = max_bid.amount + bid_unit
      self.max_bid   = bid
    elsif bid.amount > max_bid.amount
      # 新しい入札の勝ち(入札単位以下)
      self.max_price = bid.amount
      self.max_bid   = bid
    elsif max_bid.amount > bid.amount + bid_unit
      # 現在の入札の勝ち(入札単位以上)
      self.max_price = bid.amount + bid_unit
    else
      # その他(現在の入札の勝ち、入札単位以下)
      self.max_price = max_bid.amount
    end

    # 入札数インクリメント
    self.bids_count += 1

    # 自動延長処理
    if auto_extension && dulation_end <= (Time.now + 5.minute)
      self.dulation_end + 5.minute
    end

    save
  end

  ### 残り時間を取得 ###
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

  ### 現在金額の入札単位を取得 ###
  def bid_unit
    case
    when max_price < 1000;    10
    when max_price < 5000;   100
    when max_price < 10000;  250
    when max_price < 50000;  500
    else                    1000
    end
  end

  ### 開催中か ###
  def finished?
    dulation_end <= Time.now
  end

  ### (テンプレートから)商品情報をコピー ###
  def dup_init
    product = dup
    product.attributes = {name: "", start_price: nil, prompt_dicision_price: nil, dulation_start: nil, dulation_end: nil, category_id: nil, template: false, description: ("\n\n" + description.to_s)}

    product
  end

  ### CSVインポート確認 ###
  # def self.import_conf(file, category_id, template)
  def self.import_conf(file, user)
    res = []
    CSV.foreach(file.path, { headers: true, encoding: Encoding::SJIS }) do |row|
      # product = template.dup_init # テンプレートコピー

      template = user.products.templates.find_by(id: row[10]) || user.products.new
      product  = template.dup_init

      product.attributes =  {
        # category_id:           category_id,
        code:                  row[0],
        name:                  row[1],
        description:           row[2],

        category_id:           row[3],
        template_id:           row[10],
        template_name:         template.try(:name),

        dulation_start:        "#{row[4]} #{row[5]}",
        dulation_end:          "#{row[6]} #{row[7]}",
        start_price:           row[8],
        prompt_dicision_price: row[9],
        machinelife_id:        row[11],
        machinelife_images:    row[12],
      }

      product.valid?

      res << product

      break if res.count > CSV_MAX_COUNT
    end

    res
  end

  # def self.import(products, category_id, template, user_id)
  def self.import(products, user)
    # インポート開始
    Importlog.create(user_id: user.id, status: "インポート開始")

    products.each do |pr|
      begin
        # 商品情報
        # product = template.dup_init
        # product.attributes = (pr.merge(category_id: category_id, description: (pr[:description] + "\n\n" + template.description)))

        template = user.products.templates.find_by(id: pr[:template_id]) || user.products.new
        product  = template.dup_init
        product.attributes = (pr.merge(description: (pr[:description] + "\n\n" + template.description.to_s)))

        product.save!
      rescue => e
        Importlog.create(
          user_id: user.id,
          product: product,
          code:    product.code,
          message: e.message,
          status:  "商品登録エラー",
        )
      end

      # 画像情報
      product[:machinelife_images].split.each do |img_url|
        begin
          img = product.product_images.new
          img.remote_image_url = MACHINELIFE_MEDIA_PASS + img_url
          img.save!
        rescue => e
          Importlog.create(
            user_id: user.id,
            product: product,
            code:    product.code,
            url:     MACHINELIFE_MEDIA_PASS + img_url,
            message: e.message,
            status:  "画像登録エラー",
          )
        end
      end
    end

    # インポート終了
    Importlog.create(user_id: user.id, status: "インポート終了")
  end

  def self.status_label(cond)
    case cond.to_i
    when STATUS[:before];  "開始前の出品商品"
    when STATUS[:failure]; "出品終了(未落札)"
    when STATUS[:success]; "出品終了(落札済み)"
    else;                  "出品中"
    end
  end

  # 消費税計算
  def self.calc_tax(price)
    (price.to_i * TAX_RATE / 100).ceil
  end

  # 税込金額計算
  def self.calc_price_with_tax(price)
    price.to_i + self.calc_tax(price)
  end

  # 商品の消費税計算
  %w|start_price prompt_dicision_price max_price|.each do |price|
    define_method("#{price}_tax") do
      Product.calc_tax(send(price))
    end

    define_method("#{price}_with_tax") do
      Product.calc_price_with_tax(send(price))
    end
  end

  private

  def default_max_price
    self.max_price = start_price
  end

end
