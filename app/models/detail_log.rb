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
    "flw" => "フォロー新着", "chk" => "最近チェック", "new" => "新着商品", "wek" => "週間",
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
    # "cmp" => "Mailchimp",
    "mailchimp" => "Mailchimp",

    # 外部サイト
    "machinelife" => "マシンライフ", "dst" => "デッドストック", "ekikai" => "e-kikai",
    # ブラウザ
    "reload" => "リロード", "back" => "履歴",

    # オススメ枠
    "vos" => "VBPR", "bos" => "BPR",
    "waos" => "ウォッチオススメ", "bios" => "入札履歴オススメ", "dlos" => "閲覧履歴オススメ",
    "crt"  => "入札してみませんか", "nxt" => "こちらもいかが", "endo" => "まもなく終了", "zer" => "こんなのも",
    "onew" => "上位カテゴリ新着", "tnew" => "工具新着", "mnew" => "機械新着", "mos" => "機械新着",

  }

  VBPR_BIAS      = {detail: 1, watch: 4, bid: 10}
  VBPR_CSV_FILE  = "#{Rails.root}/tmp/vbpr/vbpr_result.csv"
  BPR_CSV_FILE   = "#{Rails.root}/tmp/vbpr/bpr_result.csv"
  VBPR_NPZ_FILE  = "#{Rails.root}/tmp/vbpr/vectors.npz"
  VBPR_TEMP      = "#{Rails.root}/tmp/vbpr/temp.npy"
  VBPR_RANGE     = (Date.today - 1.year)..Date.today
  VBPR_LIMIT     = 100
  VBPR_EPOCHS    = 51
  VBPR_VIEWLIMIT = 16

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

  def self.vbpr_get(user_id, limit=VBPR_VIEWLIMIT, bpr=false)
    ### CSVからレコメンド情報を取得 ###
    csv_file = bpr ? BPR_CSV_FILE : VBPR_CSV_FILE
    product_ids = CSV.foreach(csv_file, headers: true).with_object([]) do |row, ids|
      ids << row['product_id'] if row['user_id'].to_i == user_id.to_i
    end

    ### データ取得とソートおよびlimit ###
    Product.includes(:product_images).where(id: product_ids).sort_by{ |pr| product_ids.index(pr.id) }.take(limit)
  rescue
    Product.none
  end

  private

  def check_robot
    host !~ ROBOTS && ip.present?
  end
end
