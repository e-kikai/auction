# == Schema Information
#
# Table name: detail_logs
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  product_id :bigint(8)
#  ip         :string
#  host       :string
#  ua         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  referer    :string
#  r          :string           default(""), not null
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

  private

  def check_robot
    host !~ ROBOTS && ip.present?
  end
end
