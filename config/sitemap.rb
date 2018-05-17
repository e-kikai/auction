# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.mnok.net"

SitemapGenerator::Sitemap.create do
  add '/', priority: 1.0, changefreq: 'daily'

  Product.status(Product::STATUS[:start]).pluck(:id).each do |id|
    add "/products/#{id}", priority: 1.0, changefreq: 'daily'
  end

  Help.where(target: 0).pluck(:uid).each do |uid|
    add "/helps/#{uid}", priority: 0.3, changefreq: 'daily'
  end
end
