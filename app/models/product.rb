# == Schema Information
#
# Table name: products
#
#  id                    :bigint           not null, primary key
#  accesory              :string           default("")
#  additional            :text             default(""), not null
#  addr_1                :string
#  addr_2                :string
#  auto_extension        :boolean          default("自動延長する"), not null
#  auto_resale           :integer          default(8)
#  auto_resale_date      :integer          default(7), not null
#  bids_count            :integer          default(0)
#  cancel                :text
#  code                  :string
#  commision             :boolean          default(FALSE)
#  delivery_date         :integer          default("未設定"), not null
#  description           :text
#  detail_logs_count     :integer          default(0), not null
#  dulation_end          :datetime
#  dulation_start        :datetime
#  early_termination     :boolean          default(FALSE), not null
#  ended_at              :datetime
#  fee                   :integer
#  hashtags              :text             default(""), not null
#  international         :boolean          default("海外発送不可"), not null
#  lower_price           :integer
#  machinelife_images    :text
#  maker                 :string           default(""), not null
#  max_price             :integer          default(0)
#  model                 :string           default(""), not null
#  name                  :string           default(""), not null
#  note                  :text
#  packing               :text             default(""), not null
#  prompt_dicision_price :integer
#  resaled               :integer
#  returns               :boolean          default("返品不可"), not null
#  returns_comment       :string
#  search_keywords       :text             default(""), not null
#  sell_type             :integer          default(0), not null
#  shipping_comment      :string
#  shipping_no           :integer
#  shipping_type         :integer
#  shipping_user         :integer          default("落札者"), not null
#  soft_destroyed_at     :datetime
#  star                  :integer
#  start_price           :integer
#  state                 :integer          default("中古"), not null
#  state_comment         :string
#  stock                 :integer
#  suspend               :datetime
#  template              :boolean          default(FALSE), not null
#  watches_count         :integer          default(0), not null
#  year                  :string           default(""), not null
#  youtube               :string           default(""), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  category_id           :bigint           not null
#  dst_id                :integer
#  machinelife_id        :integer
#  max_bid_id            :integer
#  user_id               :bigint           not null
#
# Indexes
#
#  index_products_on_category_id        (category_id)
#  index_products_on_soft_destroyed_at  (soft_destroyed_at)
#  index_products_on_user_id            (user_id)
#

class Product < ApplicationRecord
  require 'csv'
  require "open3"

  include ImageVector # 画像特徴ベクトル関係

  soft_deletable
  default_scope { without_soft_destroyed }

  ### クラス定数 ###
  STATUS                 = { before: -1, start: 0, failure: 1, success: 2, cancel: 3, mix: 4 }
  MACHINELIFE_URL        = "https://www.zenkiren.net"
  MACHINELIFE_CRAWL_URL  = "https://www.zenkiren.net/system/ajax/e-kikai_crawled_get.php"
  MACHINELIFE_MEDIA_PASS = "https://s3-ap-northeast-1.amazonaws.com/machinelife/machine/public/media/machine/"

  CSV_MAX_COUNT          = 30
  NEW_MAX_COUNT          = 16 # 新着表示数

  TAX_RATE               = 8
  FEE_RATE               = 10

  LIMIT_DAY              = Time.now - 120.day

  AUTO_RESALE_DAY        = 3.day
  AUTO_EXTENSION_MINUTE  = 5.minute

  REMINDER_MINUTE        = 15.minute

  NEWS_DAYS  = 1.day # 新着期間
  NEWS_LIMIT = 6     # 新着表示件数

  NEWS_PAGE_DAYS   = 7.day

  TWITTER_INTERVAL = 6.hours

  OR_MARKER  = "[[xxxxorxxx]]"

  # 画像特徴ベクトル関連
  UTILS_PATH   = "/var/www/yoshida/utils"
  VECTORS_PATH = "#{UTILS_PATH}/static/image_vectors"
  S3_VECTORS_PATH = "vectors"
  ZERO_NARRAY  =  Numo::SFloat.zeros(1)
  VECTOR_CACHE = "vector"

  VECTORS_LIMIT   = 30

  SORT_SELECTOR = {
    "出品 : 新着"   => "dulation_start asc",
    "出品 : 古い"   => "dulation_start desc",
    "価格 : 安い"   => "max_price asc",
    "価格 : 高い"   => "max_price desc",
    "即売 : 安い"   => "prompt_dicision_price asc",
    "即売 : 高い"   => "prompt_dicision_price desc",
    "入札 : 多い"   => 'bids_count desc',
    "入札 : 少ない" => "bids_count asc",
    "残り時間"      => "dulation_end asc",
  }

  VIEW_SELECTOR = ["panel", "list"]


  ### relations ###
  belongs_to :user,     required: true
  belongs_to :category, required: true
  belongs_to :max_bid,  class_name: "Bid",  required: false
  belongs_to :owner,    class_name: "User", required: false

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

  validate :check_price

  ### nest ###
  accepts_nested_attributes_for :product_images, allow_destroy: true


  ### SCOPE ###
  scope :with_keywords, -> keywords {
    keywords = keywords.to_s.normalize_charwidth.strip

    if keywords.present?
      res = self

      ors = []
      keywords.gsub(/[[:space:]]*[\|｜]+[[:space:]]*/, OR_MARKER).split(/[[:space:]]/).reject(&:empty?).each do |keyword|
        res = case
        when keyword.include?(OR_MARKER)
          res.where("search_keywords SIMILAR TO ?", "%(#{keyword.gsub(OR_MARKER, "|")})%")
        when keyword =~ /^\-(.*)/
          res.where("search_keywords NOT LIKE ?", "%#{$1}%")
        else
          res.where("search_keywords LIKE ?", "%#{keyword}%")
        end
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
    when STATUS[:cancel];  finished.where.not(cancel: nil) # キャンセル
    when STATUS[:mix];     where(cancel: nil, template: false).where("(dulation_start <= ? AND dulation_end > ?) OR (dulation_end < ? AND max_bid_id IS NOT NULL)", Time.now, Time.now, Time.now).order(dulation_start: :desc) # 出品中と落札済み
    else;                  where(template: false).where("dulation_start <= ? AND dulation_end > ?", Time.now, Time.now).order(:dulation_end)  # 公開中
    end
  }

  scope :templates, -> {
    where(template: true)
  }

  scope :osusume, -> (command, ip="", user_id=nil) {
    ### 事前に整形 ###
    prs   = includes(:product_images)
    s_prs = prs.status(Product::STATUS[:start])

    if user_id.present?
      watch_prs = Product.joins(:watches).group(:id).where(watches: {user_id: user_id, soft_destroyed_at: nil})
      bid_prs   = Product.joins(:bids).group(:id).where(bids: {user_id: user_id, soft_destroyed_at: nil})
      dl_where  = {user_id: user_id} # 詳細履歴取得キー
    else
      watch_prs = Product.none
      bid_prs   = Product.none
      dl_where  = {ip: ip}
    end

    case command

    ### ユーザ共通 ###
    when "end" # まもなく終了
      s_prs.reorder(:dulation_end)
    when "news_tool" # 工具新着
      s_prs.where(category_id: Category.find_by(id: 1)&.subtree_ids).reorder(dulation_start: :desc)
    when "news_machine" # 機械新着
      s_prs.where(category_id: Category.find_by(id: 107)&.subtree_ids).reorder(dulation_start: :desc)
    when "zero" # こんなのもあります(閲覧数少)
      s_prs.joins(:detail_logs).group(:id).reorder("count(detail_logs.id), random()")

    when "detail_log" #最近チェックした商品
      prs.joins(:detail_logs).group(:id).where(detail_logs: dl_where).reorder("max(detail_logs.id) DESC")

    when "dl_osusume" #閲覧履歴に基づくオススメ
      dl_prs   = joins(:detail_logs).group(:id).where(detail_logs: dl_where)
      dl_names = dl_prs.reorder("max(detail_logs.id) DESC").limit(10)
        .pluck(:name).map(&:split).flatten.uniq.push('__blank__').join("|")

      s_prs.where("name ~ ?", dl_names).where.not(id: dl_prs).reorder("random()")

    ### ログインユーザ ###
    when "watch_osusume" # ウォッチおすすめ
      watch_names = watch_prs.reorder("max(watches.id) DESC").limit(10)
        .pluck(:name).map(&:split).flatten.uniq.push('__blank__').join("|")

      s_prs.where("products.name ~ ?", watch_names)
        .where.not(id: watch_prs).where.not(id: bid_prs).reorder("random()")

    when "bid_osusume" # 入札履歴に基づくオススメ
      bid_names = bid_prs.reorder("max(bids.id) DESC").limit(10)
        .pluck(:name).map(&:split).flatten.uniq.push('__blank__').join("|")

      s_prs.where("products.name ~ ?", bid_names)
        .where.not(id: watch_prs).where.not(id: bid_prs).reorder("random()")
    when "cart" # 入札してみませんか？
      cat_pids = DetailLog.where(user_id: user_id).group(:product_id)
        .order("count(id) DESC").limit(10).select(:product_id)

      s_prs.where(id: watch_prs).or(s_prs.where(id: cat_pids)).where.not(id: bid_prs).reorder(dulation_end: :asc)
    when "next" # こちらもいかがでしょう？
      next_name = Product.where(id: watch_prs).or(Product.where(id: bid_prs))
        .finished.where.not(max_bid_id: Bid.where(user_id: user_id))
        .pluck(:name).map(&:split).flatten.uniq.push('__blank__').join("|")

      s_prs.where("products.name ~ ?", next_name)
        .where.not(id: watch_prs).where.not(id: bid_prs).reorder("random()")
    when "follows" # フォローした出品会社の新着商品
      s_prs.where(user_id: Follow.where(user_id: user_id).select(:to_user_id)).reorder(dulation_start: :desc)

    when "often" # よくアクセスするカテゴリの新着
      ca_ids = Product.joins(:detail_logs).where(detail_logs: {user_id: user_id, created_at: DetailLog::VBPR_RANGE})
        .group(:category_id).reorder("count(*) DESC").limit(5).select("category_id")
      s_prs.where(category_id: ca_ids)

    when "pops" # 売れ筋商品
      temp = Product.unscoped.joins(:watches).group(:name).select("name, count(watches.id) as count")
      s_prs.joins("INNER JOIN (#{temp.to_sql}) as pr2 ON products.name = pr2.name")
        .reorder("pr2.count DESC, products.dulation_end ASC")
    else
      none
    end
  }


  ### オススメ枠のタイトル・ログキー・アイコン・アイコンカラー取得 ###
  def self.osusume_titles(command)
    case command.to_s

    ### 共通 ###
    when "end";          ["まもなく終了",                    :endo, :time,     "#a94442"]
    when "news_tool";    ["工具新着",                        :tnew, :wrench,   :lightseagreen]
    when "news_machine"; ["機械新着",                        :mnew, :cog,      "#3c763d"]
    when "zero";         ["こんなのもあります",              :zer,  "zoom-in", "#8a6d3b"]
    when "detail_log";   ["最近チェックした商品",            :chk,  :ok,       "#000080"]
    when "dl_osusume";   ["閲覧履歴に基づくオススメ",        :dlos, :gift,     :lightseagreen]

    ### ログインユーザ ###
    when "v";             ["あなたへのオススメ",             :vos,  :camera,   :mediumpurple]
    when "b";             ["閲覧傾向からのオススメ",         :bos,  :gift,     :lightseagreen]
    when "watch_osusume"; ["ウォッチに基づくオススメ",       :waos, :star,     "#FF0"]
    when "bid_osusume";   ["入札履歴に基づくオススメ",       :bios, :pencil,   :darkorange]
    when "cart";          ["入札してみませんか？",           :crt,  :flash,    :deeppink]
    when "next";          ["こちらもいかがでしょう？",       :nxt,  :flag,     :olivedrab]
    # when "follows";       ["フォローした出品会社の新着商品", :flw,  :heart]
    when "often";         ["よくアクセスするカテゴリの新着", :onew, :wrench,   "#337ab7"]
    when "upop";          ["この商品を見た人の売れ筋商品",   :upop, :usd,      :goldenrod]

    else;                 ["",                               "",    "",     ""]
    end
  end

  ### 売れ筋商品 ###
  # scope :pops, -> (price=0..Float::INFINITY) {
  #   wa = Product.unscoped.joins(:watches).group(:name).select("name, count(watches.id) as count")
  #   s_prs.includes(:product_images).status(Product::STATUS[:start])
  #     .joins("INNER JOIN (#{wa.to_sql}) as pr2 ON products.name = pr2.name")
  #     .where(start_price_with_tax: price).reorder("pr2.count DESC, products.dulation_end ASC")
  # }

  ### 関連商品(おなじカテゴリの商品) ###
  scope :related_products, -> prs {
    res = if prs.class.name == "Product"
      where(category_id: prs.category.subtree_ids).where.not(id: prs.id)
    else
      where(category_id: prs.except(:order).select(:category_id)).where.not(id: prs.except(:order).select(:id))
    end

    res.status(STATUS[:start]).includes(:product_images)
  }

  # おすすめ順に並べる
  scope :populars, -> {
    except(:order).order("((bids_count + 1) * (watches_count + 1)) DESC", :dulation_end)
  }

  # 新着情報
  scope :news, -> {
    where(dulation_start: (Time.now - NEWS_DAYS)..Time.now)
  }

  scope :news_day, -> day {
    where(dulation_start: day.to_date.beginning_of_day..day.to_date.end_of_day)
  }

  # 新着情報(週)
  scope :news_week, -> day {
    where(dulation_start: (day.to_date - 6.day).beginning_of_day..day.to_date.end_of_day)
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

  ### トップ画像の有無 ###
  def top_image?
    product_images.first.present?
  end

  ### 現在の最高入札と入札金額を比較 ###
  def versus(bid)
    # 自動延長処理
    if auto_extension && dulation_end <= (Time.now + AUTO_EXTENSION_MINUTE)
      self.dulation_end += AUTO_EXTENSION_MINUTE
    end

    if prompt_dicision_price.present? && prompt_dicision_price <= bid.amount
      # 即売価格
      self.max_price = prompt_dicision_price
      self.max_bid   = bid
      self.dulation_end = Time.now

    elsif lower_price.present? && lower_price > bid.amount
      # 最低落札価格(落札はされない)
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
  def remaining_second
    ((dulation_end.presence || Time.now) - Time.now).round
  end

  def remaining_time
    second = remaining_second
    if second >= (60 * 60 * 24)
      "#{(second / (60 * 60 * 24)).round}日"
    elsif second >= (60 * 60)
      "#{(second / (60 * 60)).round}時間"
    elsif second >= 60
      "#{(second / 60).round}分"
    elsif second > 0
      "#{second}秒"
    else
      "入札終了"
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

  def start?
    dulation_end && dulation_start <= Time.now && dulation_end > Time.now
  end

  ### 終了後か ###
  def finished?
    dulation_end && dulation_end <= Time.now
  end

  def success?
    dulation_end <= Time.now && max_bid_id.present?
  end

  ### ユーザが落札者か? ###
  def trade_success?(user)
    success? && max_bid.user_id == user.try(:id)
  end

  ### キャンセルされたか ###
  def cancel?
    finished? && cancel.present?
  end

  ### 現状の表示 ###
  def status
    case
    when cancel?;                       "キャンセル"
    when dulation_start.blank?;         "-"
    when dulation_start > Time.now;     "開始前"
    when finished? && max_bid.present?; "終了(落札済)"
    when finished? && max_bid.blank?;   "終了(未落札)"
    else                                "出品中"
    end
  end

  ### 取引用(対人)状況 ###
  def trade_status(user)
    case
    when user.blank?;               "ログインしていません"
    when dulation_start.blank?;     "-"
    when cancel?;                   "キャンセル"
    when dulation_start > Time.now; "開始前"
    when finished?
      if    max_bid.blank?;             "終了(未落札)"
      elsif max_bid.user_id == user.id; "落札"
      else                              "終了(未落札)"
      end
    when max_bid.try(:user_id) == user.id; "出品中 :: 現在最高入札"
    else                                   "出品中"
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
  def self.calc_tax(price, day = Date.today)
    # (price.to_i * TAX_RATE / 100).floor
    (price.to_i * Product.tax_rate(day) / 100).floor
  end

  # 税込金額計算
  def self.calc_price_with_tax(price, day = Date.today)
    # price.to_i + self.calc_tax(price)
    price.to_i + self.calc_tax(price, day)
  end

  # 商品の消費税計算
  %w|start_price prompt_dicision_price max_price lower_price fee|.each do |price|
    define_method("#{price}_tax") do
      # Product.calc_tax(send(price))
      Product.calc_tax(send(price), dulation_end)
    end

    define_method("#{price}_with_tax") do
      # Product.calc_price_with_tax(send(price))
      Product.calc_price_with_tax(send(price), dulation_end)
    end
  end

  # 定期処理
  def self.scheduling
    # ウォッチアラート
    time = Time.now + REMINDER_MINUTE
    Product.status(STATUS[:start]).where(dulation_end: (time.beginning_of_minute..time.end_of_minute)).includes(watches: [:user]).each do |pr|
      pr.watches.each do |wa|
        BidMailer.reminder(wa.user, pr).deliver
      end
    end

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
  end

  def make_search_keywords
    categories = category.path.map { |ca| ca.name }.join(" ")
    self.search_keywords = "#{name} #{categories} #{user.company} #{state} #{state_comment} #{addr_1} #{addr_2} #{hashtags} #{description} #{additional}".strip
    self.search_keywords = "#{search_keywords} 即売価格" if prompt_dicision_price.present?
    self
  end

  ### 即売のみ ###
  def prompt_dicision?
    prompt_dicision_price.present? && max_price.to_i >= prompt_dicision_price.to_i
  end

  # 閲覧ユニークユーザ数カウント
  def unique_user_count
    detail_logs.count('DISTINCT ip')
  end

  ### 税率 ###
  def self.tax_rate(day = Date.today)
    day ||= Date.today
    d = day.to_date

    case
    when d >= "2021/04/01".to_date;  0 # 税込価格
    when d >= "2019/10/01".to_date; 10
    else;                            8
    end
  end

  ### 画像特徴ベクトルを抽出 ###
  def process_vector
    bucket = Product.s3_bucket # S3バケット取得

    vector_key = "#{S3_VECTORS_PATH}/vector_#{id}.npy" # ベクトルを保存するS3パス
    image      = product_images.first                  # ベクトル変換する画像ファイルパス

    if image.blank?  # 画像の有無チェック
      errors.add(:base, '商品に画像が登録されていません') and return false
    elsif bucket.object(vector_key).exists? # ベクトルファイルの存否を確認
      errors.add(:base, 'ベクトルファイルがすでに存在します') and return false
    end

    # logger.debug "*** 2 : #{vector_key}"

    filename    = image.image_identifier
    image_id    = image.id
    image_key   = "uploads/product_image/image/#{image_id}/#{filename}"

    image_path  = "#{UTILS_PATH}/static/img/#{filename}"
    vector_path = "#{VECTORS_PATH}/#{filename}.npy"

    # logger.debug "*** 3 : #{image_key}"

    bucket.object(image_key).download_file(image_path) # S3より画像ファイルの取得

    # プロセス
    cmd = "cd #{UTILS_PATH} && python3 process_images.py --image_files=\"#{image_path}\";"
    # logger.debug "*** 4 : #{cmd}"
    o, e, s = Open3.capture3(cmd)
    # logger.debug o
    # logger.debug e
    # logger.debug s

    # logger.debug "*** 5 : #{vector_path}"

    bucket.object(vector_key).upload_file(vector_path) # ベクトルファイルアップロード

    File.delete(vector_path, image_path) # 不要になった画像ファイル、ベクトルファイルの削除

    self
  rescue
    logger.debug "*** X : rescue"
    return
  end

  ### この商品のベクトルを取得 ###
  def get_vector
    return nil unless top_image? # 画像の有無チェック

    vectors = Rails.cache.read(VECTOR_CACHE) || {} # キャッシュからベクトル群を取得
    bucket  = Product.s3_bucket # S3バケット取得

    ### ターゲットベクトル取得 ###
    if vectors[id].present? # キャッシュからベクトル取得
      vectors[id]
    elsif bucket.object("#{S3_VECTORS_PATH}/vector_#{id}.npy").exists? # アップロードファイルからベクトル取得
      str = bucket.object("#{S3_VECTORS_PATH}/vector_#{id}.npy").get.body.read
      Npy.load_string(str)
    else # ない場合
      nil
    end
  end

  ### 商品から似たものサーチ ###
  def nitamono(limit=Product::VECTORS_LIMIT)
    Product.status(STATUS[:start]).nitamono_search(self.get_vector, limit)
  end

  ### 画像ファイルから検索(途中) ###
  def self.nitamono_by_image(image, limit=Product::VECTORS_LIMIT)

    ### 画像ファイルからベクトルを取得 ###

    Product.status(STATUS[:start]).nitamono_search(target, limit)
  end

  ### 似たものでソート ###
  def self.nitamono_sort(product_id, page=1)
    target = Product.unscoped.find(product_id).get_vector

    self.nitamono_search(target, 25, page, true)
  rescue
    Product.none
  end

  ### 画像特徴ベクトル検索処理 ###
  def self.nitamono_search(target, limit=nil, page=1, mine=false)
    return Product.none if target.nil?

    vectors = Rails.cache.read(VECTOR_CACHE) || {} # キャッシュからベクトル群を取得
    bucket = Product.s3_bucket # S3バケット取得
    update_flag = false

    logger.debug "update_flag :: #{update_flag}"

    ### 各ベクトル比較 ###
    # pids = status(STATUS[:start]).pluck(:id).uniq # 検索対象(出品中)の商品ID取得
    pids = pluck(:id).uniq # 検索対象(出品中)の商品ID取得

    sorts = pids.map do |pid|
      ### ベクトルの取得 ###
      pr_narray = if vectors[pid].present? && vectors[pid] != ZERO_NARRAY # 既存
        vectors[pid]
      else # 新規(ファイルからベクトル取得して追加)
        update_flag = true
        vectors[pid] = if bucket.object("#{S3_VECTORS_PATH}/vector_#{pid}.npy").exists?

          str = bucket.object("#{S3_VECTORS_PATH}/vector_#{pid}.npy").get.body.read
          Npy.load_string(str) rescue ZERO_NARRAY
        else
          ZERO_NARRAY
        end

        vectors[pid]
      end

      # ベクトル比較
      if pr_narray == ZERO_NARRAY || pr_narray.nil? # ベクトルなし
        nil
      else
        sub = pr_narray - target
        res = (sub * sub).sum

        (res > 0 || mine == true) ? [pid, res]  : nil
      end
    end.compact.sort_by { |v| v[1] }

    ### 件数フィルタリング ###
    limit = limit.to_i
    page = page.to_i
    page = 1 if page < 1

    sorts = sorts.slice(limit * (page - 1), limit) if limit > 0

    sorts = sorts.to_h

    # ベクトルキャシュ更新
    Rails.cache.write(VECTOR_CACHE, vectors) if update_flag == true

    # 結果を返す
    where(id: sorts.keys).sort_by { |pr| sorts[pr.id] }

  end

  private

  # 現在価格を初期化
  def default_max_price
    # self.max_price = start_price if max_price < start_price
    self.max_price = start_price if bids_count == 0 && start_price_changed?
  end

  # YoutubeID変換
  def youtube_id
    if youtube =~ /([\w\-]{11})/
      self.youtube = $1
    end
  end

  def self.ransackable_scopes(auth_object = nil)
    %i(news_day news_week)
  end

  def check_price
    if prompt_dicision_price.present? && prompt_dicision_price < start_price
      errors.add(:prompt_dicision_price, ": 即売価格は開始価格以上に設定してください")
    end

    if lower_price.present? && prompt_dicision_price.present? && prompt_dicision_price < lower_price
      errors.add(:lower_price, ": 即売価格は最低入札価格以上に設定してください")
    end
  end

  ### S3リソース設定 ###
  def self.s3_resource
    Aws::S3::Resource.new(
      access_key_id:     Rails.application.secrets.aws_access_key_id,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region:            'ap-northeast-1', # Tokyo
    )
  end

  ### S3バケット取得 ###
  def self.s3_bucket
    s3_resource.bucket(Rails.application.secrets.aws_s3_bucket)
  end


end
