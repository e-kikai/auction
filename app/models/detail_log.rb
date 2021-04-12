# == Schema Information
#
# Table name: detail_logs
#
#  id         :bigint           not null, primary key
#  host       :string
#  ip         :string
#  r          :string           default(""), not null
#  referer    :string
#  ua         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_detail_logs_on_product_id  (product_id)
#  index_detail_logs_on_user_id     (user_id)
#

class DetailLog < ApplicationRecord
  require 'csv'
  require "open3"

  belongs_to :user,    required: false
  belongs_to :product, required: true

  counter_culture :product

  before_save :check_robot

  ROBOTS = /(google|yahoo|naver|ahrefs|msnbot|bot|crawl|amazonaws)/
  KWDS   = {
    "mail" => "メール", "top" => "トップページ", "dtl" => "詳細", "src" => "検索結果", "wtc" => "ウォッチリスト",
    "bid" => "入札",  "bds" => "入札一覧", "fin" => "落札一覧", "fls" => "フォローリスト",
    "cmp" => "出品会社",
    "lst" => "一覧", "flw" => "フォロー新着", "chk" => "最近チェック", "new" => "新着商品", "wek" => "週間",
    "oss" => "おすすめ", "nws" => "新着通知", "sca" => "同じカテゴリ", "bfn" => "入札完了", "bck" => "戻る",
    "win" => "入札通知", "los" => "高値更新", "csl" => "キャンセル", "suc" => "落札通知", "trd" => "取引通知",
    "rmd" => "リマインダ",

    # 表示形式
    "pnl" => "パネル表示", "lst" => "リスト表示",

    # 画像特徴ベクトル検索
    "nms" => "似たものサーチ", "nmr" => "似た商品",
    "cnw" => "カテゴリ別新着",

    # 問合せ
    "cnt" => "問合せ・取引",

    # Mailchimp
    "cmp" => "Mailchimp", "mailchimp" => "Mailchimp",

    # 外部サイト
    "machinelife" => "マシンライフ", "dst" => "デッドストック", "ekikai" => "e-kikai",

    # ブラウザ
    "reload" => "リロード", "back" => "履歴",
  }

  VBPR_BIAS     = {detail: 1, watch: 4, bid: 10}
  VBPR_CSV_FILE = "#{Rails.root}/tmp/vbpr/result.csv"
  VBPR_NPZ_FILE = "#{Rails.root}/tmp/vbpr/vectors.npz"
  VBPR_TEMP     = "#{Rails.root}/tmp/vbpr/temp.npy"

  def link_source
    DetailLog.link_source(r, referer)
  end

  def self.link_source(r, referer)
    if r.present?
      r.split("_").map { |kwd| DetailLog::KWDS[kwd] || kwd }.join(" | ")
    else
      case referer

      # 検索・SNS
      when /\/www\.google\.(com|co)/;               "Google"
      when /\/search\.yahoo\.co/;                   "Yahoo"
      when /bing\.com\//;                           "bing"
      when /baidu\.com\//;                          "百度"

      when /\/t\.co\//;                             "Twitter"
      when /facebook\.com\//;                       "FB"
      when /youtube\.com\//;                        "YouTube"
      when /googleads\.g\.doubleclick\.net/;        "広告"
      when /tpc\.googlesyndication\.com/;           "広告"
      when /\/www\.googleadservices\.com/;          "広告"
      # e-kikai
      when /\/www\.zenkiren\.net\//;                 "マシンライフ"
      when /\/www\.zenkiren\.org\//;                 "全機連"
      when /\/www\.e-kikai\.com\//;                  "e-kikai"
      when /\/www\.xn\-\-4bswgw9cs82at4b485i\.jp\//; "電子入札システム"
      when /\/www\.大阪機械団地\.jp\//;              "電子入札システム"
      when /\/www\.deadstocktool\.com\//;            "DST"

      # ものオクサイト内
      when /\/www\.mnok\.net\/myauction\/products/; "出品会社出品商品一覧"
      when /\/www\.mnok\.net\/(r=.*)?$/;            "トップページ"
      when /\/www\.mnok\.net\/products(\?)?/;       "検索結果"
      when /\/www\.mnok\.net\/products\/[0-9]/;     "詳細"
      when /\/www\.mnok\.net\/products\/[0-9]+\/nitamono/; "似たものサーチ"

      when /\/www\.mnok\.net\/myauction\/(\?)?/;    "マイ・オークション"
      when /\/www\.mnok\.net\/helps/;               "ヘルプ"
      when /\/www\.mnok\.net\/news/;                "新着商品"
      when /\/www\.mnok\.net\/searches/;            "お気に入り"

      when /\/www\.mnok\.net\/myauction\/watches/;  "ウォッチリスト"
      when /\/www\.mnok\.net\/myauction\/bids/;     "入札履歴"
      when /\/www\.mnok\.net\/myauction\/trade/;    "取引"
      when /\/www\.mnok\.net\/companies/;           "出品会社詳細"

      when /\/www\.mnok\.net(.*)$/;                 $1
      when /\/\/(.*?)(\/|$)/;                       $1
      else;                                         "(不明)"
      end
    end
  end

  ### VBPR処理用データ生成 ###
  def self.vbpr_calc(epochs = 50, limit=100)
    ### ログのあるを取得 ###
    img_ids      = ProductImage.distinct.select(:product_id)
    products     = Product.all # 削除されたものを除外
    @watches     = Watch.distinct.where(product_id: img_ids).where(product_id: products).pluck(:user_id, :product_id)
    @bids        = Bid.distinct.where(product_id: img_ids).where(product_id: products).pluck(:user_id, :product_id)
    @detail_logs = DetailLog.distinct.where.not(user_id: nil).where(product_id: img_ids).where(product_id: products).pluck(:user_id, :product_id)

    ### 現在出品中の商品(画像あり)を取得 ###
    @now_products = Product.status(Product::STATUS[:start]).where(id: img_ids).pluck(:id)

    ### バイアスを集計 ###
    bias_detail = 1
    bias_watch  = 4
    bias_dib    = 10

    @biases = @detail_logs.map { |lo| [[lo[0], lo[1]] , bias_detail] }.to_h
    @watches.each { |wa| @biases[[wa[0], wa[1]]] = (@biases[[wa[0], wa[1]]] || 0) + bias_watch }
    @bids.each    { |bi| @biases[[bi[0], bi[1]]] = (@biases[[bi[0], bi[1]]] || 0) + bias_dib }

    ### スパース行列に変換 ###
    user    = []
    product = []
    bias    = []

    @biases.each do |key, val|
      user    << key[0].to_i
      product << key[1].to_i
      bias    << val || 1
    end

    user_idx = user.uniq.map.with_index { |v, i| [v, i] }.to_h # ユーザインデックスhash
    user_key = user.map { |v| user_idx[v] } # ユーザインデックスに変換

    product_idx = product.uniq.map.with_index { |v, i| [v, i] }.to_h # 商品インデックスhash
    product_key = product.map { |v| product_idx[v] } # 商品インデックスに変換

    ### 現在出品中の商品のみインデックスhash ###
    now_product_idx = @now_products.map { |pid| [ pid, product_idx[pid] ] }.to_h

    ### 現在出品中、かつ、ログのない商品をインデックスに追加 ###
    plus_products_idx = (@now_products - product.uniq).map.with_index { |v, i| [v, (i + product.uniq.length)] }.to_h
    product_idx.merge! plus_products_idx

    ### JSON整形 ###
    data_json = {
      user_idx:    user_idx,
      user_key:    user_key,
      product_idx: product_idx,
      product_key: product_key,
      bias:        bias,

      now_product_idx:   now_product_idx,
      plus_products_idx: plus_products_idx,

      # 設定類
      bucket_name: Rails.application.secrets.aws_s3_bucket,
      csv_file:    VBPR_CSV_FILE,
      npz_file:    VBPR_NPZ_FILE,
      tempfile:    VBPR_TEMP
    }.to_json

    ### Pythonに処理を投げる ###
    cmd     = "python3 #{Rails.root}/lib/python/vbpr/vbpr_csv.py --epochs #{epochs} --limit #{limit}"
    o, e, s = Open3.capture3(cmd, stdin_data: data_json)
    logger.debug o
    logger.debug e
    logger.debug s
  end

  def self.vbpr_get(user_id)


  end

  private

  def check_robot
    host !~ ROBOTS && ip.present?
  end
end
