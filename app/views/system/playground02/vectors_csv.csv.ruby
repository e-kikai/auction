%w|ID 商品名 最低価格 ウォッチ数(商品名合算)|.to_csv +
@populars.sum do |pr|
  [pr.id, pr.name, pr.start_price_with_tax, pr.count].to_csv
end


header = %w|ID  商品名 最低価格 画像ファイル名 カテゴリID カテゴリ名|

columns = %w|products.id products.name products.start_price |

CSV.generate do |row|
  row << header

  @detail_logs.reorder("detail_logs.id").in_batches(of: 2000) do |los|
    los.pluck(columns).each do |lo|
      ### 整形 ###
      hitoyama_idx = columns.find_index("products.hitoyama")
      name_idx     = columns.find_index("products.name")
      lo[hitoyama_idx] = case
      when lo[hitoyama_idx] == true;        "○"
      when lo[name_idx] =~ /一山|1山|雑品/; "□"
      else;                                 ""
      end

      r_idx   = columns.find_index("detail_logs.r")
      ref_idx = columns.find_index("detail_logs.referer")

      ls = DetailLog.link_source_base(lo[r_idx], lo[ref_idx])
      lo[columns.find_index("1")]   = URI.unescape(ls).scrub('♪')
      lo[ref_idx] = URI.unescape(lo[ref_idx]).scrub('♪')

      row << lo
    end
  end
end

# res