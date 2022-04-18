header  = %w|id start top_image|

CSV.generate do |row|
  row << header

  @products.each do |pr|
    ### 整形 ###
    row << [pr.id, (pr.start? ? 1 : nil), pr&.product_images&.first&.image&.path]
  end
end
