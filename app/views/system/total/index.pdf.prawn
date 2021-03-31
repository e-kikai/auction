prawn_document do |pdf|
  @companies.each do |co|
    month_products = co.products.where(cancel: nil, dulation_end: @rstart..@rend)
    fee_products   = month_products.where.not(fee: nil).order(:dulation_end)

    # count        = month_products.count
    # success      = fee_products.length
    price        = fee_products.sum(&:max_price)
    # fee          = fee_products.sum(&:fee)
    # fee_tax      = fee_products.sum(&:fee_tax)
    # fee_with_tax = fee_products.sum(&:fee_with_tax)
    fee          = price * Product::FEE_RATE / 100
    fee_tax      = Product.calc_tax(fee, @date)
    fee_with_tax = fee + fee_tax

    next if fee_products.blank?

    ### 請求書 ###
    pdf.start_new_page layout: :portrait, margin: [10.mm, 20.mm]
    pdf.font "vendor/assets/fonts/ipaexm.ttf"

    pdf.default_leading 2

    # # pdf.stroke_axis
    #
    pdf.text "〒 #{co.zip}", size: 12
    pdf.text "#{co.addr_1} #{co.addr_2} #{co.addr_3}".normalize_charwidth, size: 12
    pdf.move_down 5.mm
    pdf.text "#{co.company} 御中", size: 12
    pdf.stroke_line [0, 255.mm], [90.mm, 255.mm]

    pdf.move_down 25.mm

    # ヘッダ
    pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
    pdf.text "ものづくりオークション #{@date.strftime("%Y年%-m月")} 販売分", size: 14

    # システム使用料
    pdf.text_box "システム使用料 請求金額", size: 14, at: [12.mm, (218.5).mm]
    pdf.text_box "#{number_to_currency(fee_with_tax)} (税込)", size: 20, at: [80.mm, 220.mm]
    pdf.stroke_line [74.mm, 212.mm], [154.mm, 212.mm]

    pdf.font "vendor/assets/fonts/ipaexm.ttf"
    pdf.bounding_box([0.mm, 190.mm], width: 170.mm, height: 42.mm) do
      # pdf.stroke_bounds

      pdf.default_leading 8

      # pdf.text "以上", size: 12, align: :right
      # pdf.text "平成#{Time.now.strftime("%Y").to_i - 1988}年 #{Time.now.strftime("%-m月 %-d日")}", size: 12, align: :right
      pdf.text Time.now.strftime("%Y年 %-m月 %-d日"), size: 12, align: :right
      pdf.text "ものづくりオークション委員会", size: 14, align: :right
      pdf.text "〒578-0965 住所 東大阪市本庄西2丁目5番10号 大阪機械卸業団地協同組合", size: 12, align: :right
      pdf.text "TEL 06-6747-7521　FAX 06-6747-7525", size: 12, align: :right
    end

    # フッタ群
    pdf.bounding_box([0, 120.mm], width: 178.mm, height: 80.mm) do
      # pdf.stroke_bounds

      pdf.default_leading 6

      pdf.text "別紙明細の通り、上記システム使用料請求金額をいただきます。", size: 12
      # pdf.text "平成#{@date.next_month(1).strftime("%Y").to_i - 1988}年#{@date.next_month(1).strftime("%-m月")}20日までにご入金下さい。", size: 16
      pdf.text "#{@date.next_month(1).strftime("%Y年%-m月")}20日までにご入金下さい。", size: 16
      pdf.text ""
      # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
      pdf.text "ゆうちょ銀行", size: 12
      pdf.text "店名 四○八 (読み ヨンゼロハチ)", size: 12
      pdf.text "店番 408 預金種類 普通預金", size: 12
      pdf.font "vendor/assets/fonts/ipaexm.ttf"
      pdf.text "口座番号 4999155", size: 12
      pdf.text "口座名称 ものづくりオークション委員会", size: 12
      pdf.text "(略称) モノヅクリオークションイインカイ", size: 12
      pdf.text "", size: 12
      # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
      pdf.text "お願い:お振り込みいただく場合は、振込手数料は貴社でご負担下さい。", size: 12
    end

    ### 明細 ####
    pdf.start_new_page layout: :portrait, margin: [10.mm, 10.mm]

    pdf.default_leading 2

    pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
    pdf.text "ものづくりオークション #{co.company} 様 #{@date.strftime("%Y年%-m月")} 落札商品明細"

    pdf.font "vendor/assets/fonts/ipaexm.ttf"
    arr = [%w|No. 管理番号 商品名 開始価格 落札日時 落札金額|] +
    fee_products.map.with_index do |pr, i|
      [(i+1), pr.code, pr.name, number_with_delimiter(pr.start_price),
        I18n.l(pr.dulation_end, format: :date_time), number_with_delimiter(pr.max_price)]
      # [(i+1), pr.code, pr.name, number_with_delimiter(pr.start_price_with_tax),
      #     I18n.l(pr.dulation_end, format: :date_time), number_with_delimiter(pr.max_price_with_tax)]
      end + [
      [ {content: "", colspan: 2}, {content: "落札金額合計", colspan: 2}, {content: number_to_currency(price), colspan: 2},],
      [ {content: "", colspan: 2}, {content: "システム使用料", colspan: 2}, {content: number_to_currency(fee), colspan: 2},],
      # [ {content: "", colspan: 2}, {content: "消費税 (#{Product::TAX_RATE}%)", colspan: 2}, {content: number_to_currency(fee_tax), colspan: 2},],
      [ {content: "", colspan: 2}, {content: "消費税 (#{Product.tax_rate(@date)}%)", colspan: 2}, {content: number_to_currency(fee_tax), colspan: 2},],

      [ {content: "", colspan: 2}, {content: "請求金額", colspan: 2}, {content: number_to_currency(fee_with_tax), colspan: 2},],
    ]

    pdf.table arr, {
      header: true,
    } do |t|
      t.cells.style(size: 10)

      t.columns(0).style(width: 38,  align: :right)
      t.columns(1).style(width: 66,  align: :left)
      t.columns(2).style(width: 220, align: :left)
      t.columns(3).style(width: 70,  align: :right)
      t.columns(4).style(width: 74,  align: :right)
      t.columns(5).style(width: 70,  align: :right)
      # t.columns(6).style(width: 60, align: :right)

      t.row(0).style(align: :center)

      t.row(-1).columns(0).border_width = 0
      t.row(-2).columns(0).border_width = 0
      t.row(-3).columns(0).border_width = 0
      t.row(-4).columns(0).border_width = 0

      t.row(-1).columns([2, 4]).style(align: :right, size: 12)
      t.row(-2).columns([2, 4]).style(align: :right, size: 12)
      t.row(-3).columns([2, 4]).style(align: :right, size: 12)
      t.row(-4).columns([2, 4]).style(align: :right, size: 12)
    end

    ### 領収証 ####
    pdf.start_new_page layout: :portrait, margin: [10.mm, 10.mm]

    pdf.default_leading 2

    pdf.font "vendor/assets/fonts/ipaexm.ttf"
    [277.mm, 128.5.mm].each.with_index do |v, i|
      pdf.bounding_box([0, v], width: 190.mm, height: 128.5.mm) do
        pdf.stroke_bounds

        pdf.text_box "#{co.company} 御中", size: 16, at: [10.mm, 110.mm]
        pdf.text_box "領収証 #{i == 1 ? " (控)" : ""}", size: 26, at: [0.mm, 95.mm], align: :center
        pdf.text_box "下記の通り、領収いたしました。", size: 12, at: [2.mm, 87.mm]
        pdf.text_box "記", size: 12, at: [2.mm, 80.mm], align: :center

        arr = [
          # ["システム使用料(税抜)", "消費税(#{Product::TAX_RATE}%)", "合計請求金額"],
          ["システム使用料(税抜)", "消費税(#{Product.tax_rate(@date)}%)", "合計請求金額"],
          [number_to_currency(fee), number_to_currency(fee_tax), number_to_currency(fee_with_tax)]
        ]

        pdf.move_down 55.mm
        pdf.table arr, {
          header: true, position: 3.mm
        } do |t|
          t.cells.style(size: 16)

          t.columns(0).style(width: 67.mm, align: :right)
          t.columns(1).style(width: 45.mm, align: :right)
          t.columns(2).style(width: 72.mm, align: :right)

          t.row(0).style(align: :center, size: 12)
          t.row(1).style(align: :right, size: 16, height: 15.mm, padding: 4.mm)

        end

        pdf.move_down 4.mm

        arr = [
          [{:content => "内訳", :rowspan => 2}, "", "現金"],
          ["", "小切手"],
        ]
        pdf.table arr, {
          header: true, position: 3.mm
        } do |t|
          t.cells.style(align: :center, valign: :middle, size: 12)

          t.columns(0).style(width: 17.mm, padding: [6.mm, 0])
          t.columns(1).style(width: 8.mm)
          t.columns(2).style(width: 26.mm)
        end

        pdf.text "以上", size: 12, align: :right
        # pdf.text "平成　　年　　月　　日", size: 12, align: :right
        pdf.text "　　　　年　　月　　日", size: 12, align: :right
        pdf.text "ものづくりオークション委員会", size: 12, align: :right
      end
    end

  end
end
