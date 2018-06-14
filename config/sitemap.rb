# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.mnok.net"

SitemapGenerator::Sitemap.create do
  add '/', priority: 1.0, changefreq: 'daily'

  ### 商品詳細 ###
  Product.status(Product::STATUS[:start]).pluck(:id).each do |id|
    add "/products/#{id}", priority: 1.0, changefreq: 'daily'
  end

  ### カテゴリ ###
  Category.all.select(:id).each do |ca|
    if ca.products.exists?
      add "/products?category_id=#{ca.id}", priority: 0.6, changefreq: 'daily'
    end
  end

  ### 出品会社 ###
  User.companies.select(:id).each do |co|
    if co.products.exists?
      add "/products?company_id=#{co.id}", priority: 0.4, changefreq: 'daily'
    end
  end

  ### ヘルプページ ###
  Help.where(target: 0).pluck(:uid).each do |uid|
    add "/helps/#{uid}", priority: 0.3, changefreq: 'daily'
  end
end
