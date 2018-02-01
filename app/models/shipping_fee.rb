class ShippingFee < ApplicationRecord
  ADDRS = %w|北海道 青森県 秋田県 岩手県 山形県 宮城県 福島県 群馬県 栃木県 茨城県 埼玉県 千葉県 東京都 神奈川県 新潟県 富山県 石川県 福井県 山梨県 静岡県 長野県 岐阜県 愛知県 三重県 滋賀県 京都府 大阪府 奈良県 和歌山県 兵庫県 岡山県 広島県 鳥取県 島根県 山口県 香川県 徳島県 愛媛県 高知県 福岡県 佐賀県 長崎県 大分県 熊本県 宮崎県 鹿児島県 沖縄県|

  ### CSVインポート確認 ###
  def self.import(file, user)
    res = []
    CSV.foreach(file.path, { headers: false, encoding: Encoding::SJIS }).with_index do |row, i|
      if i == 0
        row.each.with_index do |la, j|
          next if j == 0

          l = ShippingLabel.find_or_initialize_by(user_id: user.id, shipping_no: j)
          l.attributes = {
            user_id:     user.id,
            shipping_no: j,
            name:        la,
          }
          l.save!
        end
      else
        addr_1 = ''
        row.each.with_index do |price, j|
          if j == 0
            addr_1 = price
          else
            next unless ADDRS.include?(addr_1)

            f = ShippingFee.find_or_initialize_by(user_id: user.id, addr_1: addr_1, shipping_no: j)
            f.attributes = {
              user_id:     user.id,
              addr_1:      addr_1,
              shipping_no: j,
              price:       price,
            }
            f.save!
          end 
        end
      end
    end
  end
end
