header  = %w|id image_id top_image|

CSV.generate do |row|
  row << header

  @products.each do |pr|
    ### 整形 ###
    news = pr.start? && pr.product_nitamonos.blank? ? true : false

    row << [
      pr.id,
      (news ? pr&.product_images&.first&.id : nil),
      (news ? pr&.product_images&.first&.image&.identifier : nil)
    ]
  end
end
