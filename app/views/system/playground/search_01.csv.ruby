["ID". "product_image_id", "filename"].to_csv +
@products.sum do |pr|
  if pr.product_images.blank?
    [
      pr.id, "", ""
    ].to_csv
  else
    [
      pr.id, pr.product_images.first.id, pr.product_images.first.image_identifier
    ].to_csv
  end
end
