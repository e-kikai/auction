# == Schema Information
#
# Table name: products
#
#  id                    :bigint(8)        not null, primary key
#  user_id               :bigint(8)        not null
#  category_id           :bigint(8)        not null
#  name                  :string           default(""), not null
#  description           :text
#  dulation_start        :datetime
#  dulation_end          :datetime
#  sell_type             :integer          default(0), not null
#  start_price           :integer
#  prompt_dicision_price :integer
#  ended_at              :datetime
#  addr_1                :string
#  addr_2                :string
#  shipping_user         :integer          default("落札者"), not null
#  shipping_type         :integer
#  shipping_comment      :string
#  delivery_date         :integer          default("未設定"), not null
#  state                 :integer          default("中古"), not null
#  state_comment         :string
#  returns               :boolean          default("返品不可"), not null
#  returns_comment       :string
#  auto_extension        :boolean          default("自動延長する"), not null
#  early_termination     :boolean          default(FALSE), not null
#  auto_resale           :integer          default(8)
#  resaled               :integer
#  lower_price           :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  soft_destroyed_at     :datetime
#  max_price             :integer          default(0)
#  bids_count            :integer          default(0)
#  max_bid_id            :integer
#  fee                   :integer
#  code                  :string
#  template              :boolean          default(FALSE), not null
#  machinelife_id        :integer
#  machinelife_images    :text
#  shipping_no           :integer
#  cancel                :text
#  hashtags              :text             default(""), not null
#  star                  :integer
#  note                  :text
#  watches_count         :integer          default(0), not null
#  detail_logs_count     :integer          default(0), not null
#  additional            :text             default(""), not null
#  packing               :text             default(""), not null
#  youtube               :string           default(""), not null
#  international         :boolean          default("海外発送不可"), not null
#  search_keywords       :text             default(""), not null
#  auto_resale_date      :integer          default(7), not null
#

class Product < ApplicationRecord
  require 'csv'

  soft_deletable
  default_scope { without_soft_destroyed }

  ### クラス定数 ###
  STATUS                 = { before: -1, start: 0, failure: 1, success: 2, cancel: 3 }
  MACHINELIFE_URL        = "http://www.zenkiren.net"
  MACHINELIFE_CRAWL_URL  = "#{MACHINELIFE_URL}/system/ajax/e-kikai_crawled_get.php"
  MACHINELIFE_MEDIA_PASS = "#{MACHINELIFE_URL}/media/machine/"

  CSV_MAX_COUNT          = 30
  NEW_MAX_COUNT          = 16 # 新着表示数

  TAX_RATE               = 8
  FEE_RATE               = 10

  LIMIT_DAY              = Time.now - 120.day

  AUTO_RESALE_DAY        = 3.day
  AUTO_EXTENSION_MINUTE  = 5.minute

  REMINDER_MINUTE        = 15.minute

  ### relations ###
  belongs_to :user,     required: true
  belongs_to :category, required: true
  belongs_to :max_bid,  class_name: "Bid", required: false

  has_many   :product_images, -> { order(:id) }, inverse_of: :product
  # has_many   :product_images
  # has_one    :top_image,      -> { order(:order_no, :id) }, class_name: "ProductImage"
  has_many   :bids
  has_many   :bid_users, -> { distinct }, through: :bids, source: :user
  has_many   :watches
  has_many   :watch_users, through: :watches, source: :user
  has_many   :trades
  has_many   :detail_logs

  ### enum ###
  enum shipping_user:  { "落札者" => 0, "出品者" => 100, "店頭引取り" => 500 }
  enum delivery_date:  { "未設定" => 0, "1〜2日で発送" => 100, "3〜7日で発送" => 200, "8日以降に発送" => 300 }
  enum state:          { "中古" => 0, "未使用品" => 50, "新品" => 100, "その他" => 200 }
  enum international:  { "海外発送不可" => false, "海外発送可" => true }
  enum returns:        { "返品不可" => false, "返品可" => true }
  enum auto_extension: { "自動延長しない" => false, "自動延長する" => true }

  ### validates ###
  validates :name,        presence: true
  validates :start_price, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :prompt_dicision_price, numericality: { only_integer: true }, allow_blank: true

  # validates :shipping_user, presence: true, inclusion: {in: Product.shipping_users.keys}
  validates :delivery_date, presence: true, inclusion: {in: Product.delivery_dates.keys}
  validates :state,         presence: true, inclusion: {in: Product.states.keys}

  validates :dulation_start, presence: true
  validates :dulation_end,   presence: true

  # validates :returns,           inclusion: {in: [true, false]}
  # validates :auto_extension,    inclusion: {in: [true, false]}
  validates :early_termination, inclusion: {in: [true, false]}
  validates :template,          inclusion: {in: [true, false]}

  validates :machinelife_id, uniqueness: { scope: [ :soft_destroyed_at, :cancel ] }, allow_blank: true
  validates :star,           numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 } , allow_blank: true

  ### nest ###
  accepts_nested_attributes_for :product_images, allow_destroy: true


  ### SCOPE ###
  scope :with_keywords, -> keywords {
    if keywords.present?
      res = self
      keywords.split(/[[:space:]]/).reject(&:empty?).each do |keyword|
        res = res.where("search_keywords LIKE ?", "%#{keyword}%")
      end

      res
    end
  }

  scope :finished, -> {
    # where("dulation_end BETWEEN ? AND ?", LIMIT_DAY, Time.now).order(dulation_end: :desc)
    where("dulation_end < ?", Time.now).where(template: false).order(dulation_end: :desc)
  }

  scope :status, -> cond {
    case cond.to_i
    when STATUS[:before];  where("dulation_start > ? ", Time.now).order(:dulation_start) # 開始前
    when STATUS[:failure]; finished.where(max_bid_id: nil, cancel: nil) # 未落札
    when STATUS[:success]; finished.where(cancel: nil).where.not(max_bid_id: nil) # 落札済み
    when STATUS[:cancel];  finished.where.not(cancel: nil) # 未落札
    else;                  where(template: false).where("dulation_start <= ? AND dulation_end > ?", Time.now, Time.now).order(:dulation_end)  # 公開中

    end
  }

  scope :templates, -> {
    where(template: true)
  }

  scope :populars, -> products {
    res = Product.status(STATUS[:start]).includes(:product_images)
      .except(:order).order("((bids_count + 1) * (watches_count + 1)) DESC", :dulation_end)

    if products.class.name == "Product"
      res.where(category_id: products.category.subtree_ids).where.not(id: products.id)
    else
      res.where(category_id: products.except(:order).select(:category_id))
        .where.not(id: products.except(:order).select(:id))
    end

  }

  ### callback ###
  before_save :default_max_price
  before_save :youtube_id
  before_save :make_search_keywords

  ### インポート用getter setter ###
  attr_accessor :template_id, :template_name

  ### サムネイル画像URL ###
  def thumb_url
    product_images.first.try(:image).try(:thumb).try(:url) || ProductImage::NOIMAGE_THUMB
  end

  ### 現在の最高入札と入札金額を比較 ###
  def versus(bid)
    # 自動延長処理
    if auto_extension && dulation_end <= (Time.now + AUTO_EXTENSION_MINUTE)
      self.dulation_end += AUTO_EXTENSION_MINUTE
    end

    if prompt_dicision_price.present? && prompt_dicision_price <= bid.amount
      # 即決価格
      self.max_price = prompt_dicision_price
      self.max_bid   = bid
      self.dulation_end = Time.now
    elsif lower_price.present? && lower_price > bid.amount # 最低落札価格(落札はされない)
      self.max_price = bid.amount
    elsif max_bid.blank? # (有効)入札なしの場合
      if lower_price.present?
        self.max_price = lower_price
      else
        self.max_price = start_price
      end
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

  ### 開始前か ###
  def before?
    dulation_start > Time.now
  end

  ### 終了後か ###
  def finished?
    dulation_end <= Time.now
  end

  def cancel?
    finished? && cancel.present?
  end

  ### 現状の表示 ###
  def status
    case
    when cancel?;                       "キャンセル"
    when dulation_start > Time.now;     "開始前"
    when finished? && max_bid.present?; "終了(落札済)"
    when finished? && max_bid.blank?;   "終了(未落札)"
    else                                "出品中"
    end
  end

  ## 手数料計算 ###
  def fee_calc
    (max_price * FEE_RATE / 100).floor
  end

  ### (テンプレートから)商品情報をコピー ###
  def dup_init(template=false)
    product = dup
    product.attributes = if template
      # {name: "", start_price: nil, prompt_dicision_price: nil, dulation_start: nil, dulation_end: nil, category_id: nil, template: false, description: ("\n\n" + description.to_s)}
      {name: "", start_price: nil, prompt_dicision_price: nil, dulation_start: nil, dulation_end: nil, category_id: nil, template: false, description: ""}
    else
      product_images.each do |pi|
        product.product_images.new.remote_image_url = pi.image.url
      end

      {dulation_start: nil, dulation_end: nil, template: false}
    end

    product
  end

  ### 星評価表示 ###
  def star_view
    "★"  * star.to_i
  end


  ### CSVインポート確認 ###
  # def self.import_conf(file, category_id, template)
  def self.import_conf(file, user)
    res = []
    CSV.foreach(file.path, { headers: true, encoding: Encoding::SJIS }) do |row|
      # product = template.dup_init # テンプレートコピー

      template = user.products.templates.find_by(id: row[12]) || user.products.new
      product  = template.dup_init

      product.attributes =  {
        # category_id:           category_id,
        code:                  row[0],
        name:                  row[1],
        description:           row[2],

        category_id:           row[3],
        template_id:           row[12],
        template_name:         template.try(:name),

        dulation_start:        "#{row[4]} #{row[5]}",
        dulation_end:          "#{row[6]} #{row[7]}",
        start_price:           row[8],
        lower_price:           row[9],
        prompt_dicision_price: row[10],
        hashtags:              row[11],
        machinelife_id:        row[13],
        machinelife_images:    row[14],
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
        template = user.products.templates.find_by(id: pr[:template_id]) || user.products.new
        product  = template.dup_init

        product.attributes = pr
        # product.attributes = (pr.merge(description: (pr[:description] + "\n\n" + template.description.to_s)))

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
      product[:machinelife_images].to_s.split.each do |img_url|
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
    when STATUS[:before];  "開始前の商品"
    when STATUS[:failure]; "出品終了分 - 未落札 (再出品)"
    when STATUS[:success]; "出品終了分 - 落札済"
    when STATUS[:cancel];  "出品キャンセル分"
    else;                  "出品中"
    end
  end

  # 消費税計算
  def self.calc_tax(price)
    (price.to_i * TAX_RATE / 100).floor
  end

  # 税込金額計算
  def self.calc_price_with_tax(price)
    price.to_i + self.calc_tax(price)
  end

  # 商品の消費税計算
  %w|start_price prompt_dicision_price max_price lower_price fee|.each do |price|
    define_method("#{price}_tax") do
      Product.calc_tax(send(price))
    end

    define_method("#{price}_with_tax") do
      Product.calc_price_with_tax(send(price))
    end
  end

  # 定期処理
  def self.scheduling
    # 落札確認
    Product.status(STATUS[:success]).where(fee: nil).includes(max_bid: [:user]).each do |pr|
      pr.update(fee: pr.fee_calc)

      BidMailer.success_user(pr.max_bid.user, pr).deliver
      BidMailer.success_company(pr).deliver
    end

    # 自動再出品
    Product.status(STATUS[:failure]).where(auto_resale: 1..Float::INFINITY).each do |pr|
      pr.update(
        dulation_end: pr.dulation_end + pr.auto_resale_date.day,
        auto_resale:  pr.auto_resale -= (pr.auto_resale < 100 ? 1 : 0),
      )
    end

    # ウォッチアラート
    time = Time.now + REMINDER_MINUTE
    Product.status(STATUS[:start]).where(dulation_end: (time.beginning_of_minute..time.end_of_minute)).includes(watches: [:user]).each do |pr|
      pr.watches.each do |wa|
        BidMailer.reminder(wa.user, pr).deliver
      end
    end

    ### TODO ###
    # 新着アラート
  end

  def make_search_keywords
    categories = category.path.map { |ca| ca.name }.join(" ")
    self.search_keywords = "#{name} #{categories} #{user.company} #{state} #{state_comment} #{addr_1} #{addr_2} #{hashtags}".strip
    self
  end

  private

  def default_max_price
    self.max_price = start_price if max_bid_id.blank?
  end

  def youtube_id
    if youtube =~ /([\w\-]{11})/
      self.youtube = $1
    end
  end

end
