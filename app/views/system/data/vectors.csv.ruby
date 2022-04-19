header  = %w|id start image_id top_image|

CSV.generate do |row|
  row << header

  @products.each do |pr|
    ### 整形 ###
    row << [pr.id, (pr.start? ? 1 : nil), pr&.product_images&.first&.id, pr&.product_images&.first&.image&.identifier]
  end
end
