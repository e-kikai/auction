prawn_document do |pdf|
  @companies.each do |co|
    month_products = co.products.where(dulation_end: @date.beginning_of_month..@date.end_of_month)
    fee_products   = month_products.where.not(fee: nil).order(:dulation_end)

    # count        = month_products.count
    # success      = fee_products.length
    price        = fee_products.sum(&:max_price)
    fee          = fee_products.sum(&:fee)
    fee_tax      = fee_products.sum(&:fee_tax)
    fee_with_tax = fee_products.sum(&:fee_with_tax)

    next if fee_products.blank?

    ### 請求書 ###
    pdf.start_new_page layout: :portrait, margin: [10.mm, 24.mm]
    pdf.font "vendor/assets/fonts/ipaexm.ttf"

    pdf.default_leading 2

    # # pdf.stroke_axis
    #
    pdf.text "#{co.zip} #{co.addr_1} #{co.addr_2} #{co.addr_3}", size: 12
    pdf.move_down 5.mm
    pdf.text "#{co.company} 御中", size: 20
    pdf.stroke_line [0, 258.mm], [90.mm, 258.mm]

    pdf.move_down 15.mm

    # ヘッダ
    pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
    pdf.text "ものづくりオークション #{@date.strftime("%Y年%-m月")} 販売分", size: 14

    # 手数料
    pdf.text_box "手数料請求金額", size: 14, at: [12.mm, (228.5).mm]
    pdf.text_box "#{number_to_currency(fee_with_tax)} (税込)", size: 20, at: [60.mm, 230.mm]
    pdf.stroke_line [54.mm, 222.mm], [124.mm, 222.mm]

    # フッタ群
    pdf.font "vendor/assets/fonts/ipaexm.ttf"
    pdf.bounding_box([0, 132.mm], width: 178.mm, height: 60.mm) do
      # pdf.stroke_bounds

      pdf.default_leading 6

      pdf.text "別紙明細の通り、上記手数料請求金額をいただきます。", size: 12
      pdf.text "平成#{@date.strftime("%Y").to_i - 1988}年#{@date.next_month(1).strftime("%-m月")}20日までにご入金下さい。", size: 16
      pdf.text ""
      # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
      pdf.text "〇〇〇〇 〇〇支店", size: 12

      pdf.font "vendor/assets/fonts/ipaexm.ttf"
      pdf.text "当座預金 0000000", size: 12
      pdf.text "口座名称 xxxxxxxxxxxxx", size: 12
      pdf.text "略称 xxxxxxxxxxxxx", size: 12
      pdf.text "", size: 12
      # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
      pdf.text "お願い:お振り込みいただく場合は、振込手数料は貴社でご負担下さい。", size: 12
    end

    pdf.bounding_box([0.mm, 50.mm], width: 170.mm, height: 42.mm) do
      # pdf.stroke_bounds

      pdf.default_leading 8

      # pdf.text "以上", size: 12, align: :right
      # pdf.text "平成　　年　　月　　日", size: 12, align: :right
      pdf.text "平成#{Time.now.strftime("%Y").to_i - 1988}年 #{Time.now.strftime("%-m月 %-d日")}", size: 12, align: :right
      pdf.text "ものづくりオークション委員会", size: 14, align: :right
      pdf.text "〒578-0965 住所 東大阪市本庄西2丁目5番10号 大阪機械卸業団地協同組合", size: 12, align: :right
      pdf.text "TEL 06-6747-7521　FAX 06-6747-7525", size: 12, align: :right
    end

    ### 明細 ####
    pdf.start_new_page layout: :portrait, margin: [10.mm, 10.mm]

    pdf.default_leading 2

    pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"
    pdf.text "ものづくりオークション #{co.company} 様 #{@date.strftime("%Y年%-m月")} 落札商品明細"

    pdf.font "vendor/assets/fonts/ipaexm.ttf"
    arr = [%w|No. 管理番号 商品名 開始価格 落札金額 落札日時 手数料|] +
    fee_products.map.with_index do |pr, i|
      [(i+1), pr.code, pr.name, number_with_delimiter(pr.start_price), number_with_delimiter(pr.max_price),
        I18n.l(pr.dulation_end, format: :date_time), number_with_delimiter(pr.fee),]
    end + [
      [ {content: "", colspan: 3}, {content: "手数料合計", colspan: 2}, {content: number_to_currency(fee), colspan: 2},],
      [ {content: "", colspan: 3}, {content: "消費税(#{Product::TAX_RATE}%)", colspan: 2}, {content: number_to_currency(fee_tax), colspan: 2},],
      [ {content: "", colspan: 3}, {content: "請求金額", colspan: 2}, {content: number_to_currency(fee_with_tax), colspan: 2},],
    ]

    pdf.table arr, {
      header: true,
    } do |t|
      t.cells.style(size: 10)

      t.columns(0).style(width: 28,  align: :right)
      t.columns(1).style(width: 66, align: :left)
      t.columns(2).style(width: 190, align: :left)
      t.columns(3).style(width: 60, align: :right)
      t.columns(4).style(width: 60, align: :right)
      t.columns(5).style(width: 74, align: :left)
      t.columns(6).style(width: 60, align: :right)

      t.row(0).style(align: :center)

      t.row(-1).columns(0).border_width = 0
      t.row(-2).columns(0).border_width = 0
      t.row(-3).columns(0).border_width = 0

      t.row(-1).columns([3, 5]).style(align: :right, size: 12)
      t.row(-2).columns([3, 5]).style(align: :right, size: 12)
      t.row(-3).columns([3, 5]).style(align: :right, size: 12, weight: :bold)
    end
  end
end
