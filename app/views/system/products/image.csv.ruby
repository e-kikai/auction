[
  "ID", "商品名", "画像URL"
].to_csv +
@products.sum do |pr|
  [
    pr.id, pr.name, pr.thumb_url
  ].to_csv
end
