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
    "pnl" => "パネル表示", "lst" => "リスト表示",
    "cmp" => "Mailchimp",
    "machinelife" => "マシンライフ", "dst" => "デッドストック", "ekikai" => "e-kikai",
  }

  def link_source
    DetailLog.link_source(r, referer)
  end

  def self.link_source(r, referer)
    if r.present?
      r.split("_").map { |kwd| DetailLog::KWDS[kwd] || kwd }.join(" | ")
    else
      case referer
      when /\/www\.google\.(com|co)/;               "Google"
      when /\/search\.yahoo\.co/;                   "Yahoo"
      when /\/t\.co\//;                             "Twitter"
      when /bing\.com\//;                           "bing"
      when /\/www\.facebook\.com\//;                "Facebook"
      when /\/www\.youtube\.com\//;                 "YouTube"

      when /\/www\.zenkiren\.net\//;                "マシンライフ"
      when /\/www\.zenkiren\.org\//;                "全機連"
      when /\/www\.e-kikai\.com\//;                 "e-kikai"
      when /\/www\.xn\-\-4bswgw9cs82at4b485i\.jp\//; "電子入札システム"
      when /\/www\.大阪機械団地\.jp\//;              "電子入札システム"
      when /\/www\.deadstocktool\.com\//;           "デッドストック"

      when /\/www\.mnok\.net\/myauction\/products/; "出品会社出品商品一覧"
      when /\/www\.mnok\.net(.*)$/;                 $1
      when /\/\/(.*?)(\/|$)/;                       $1
      else;                                         "(不明)"
      end
    end
  end

  private

  def check_robot
    host !~ ROBOTS && ip.present?
  end
end
