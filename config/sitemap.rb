# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.mnok.net"

SitemapGenerator::Sitemap.create do
  add '/', priority: 1.0, changefreq: 'daily'
  add '/lp/index.html', priority: 0.7, changefreq: 'monthly' #LP

  ### 商品詳細 ###
  Product.status(Product::STATUS[:start]).pluck(:id).each do |id|
    add "/products/#{id}", priority: 0.9, changefreq: 'daily'
  end

  ### 落札済み ###
  Product.status(Product::STATUS[:success]).pluck(:id).each do |id|
    add "/products/#{id}", priority: 0.6, changefreq: 'daily'
  end

  ### 未落札 ###
  # Product.status(Product::STATUS[:failure]).pluck(:id).each do |id|
  #   add "/products/#{id}", priority: 0.5, changefreq: 'daily'
  # end

  ### トップ特集 ###
  # Search.where(publish: true).each do |id|
  #   add "/searches/#{id}", priority: 0.3, changefreq: 'daily'
  # end

  ### 新着商品 ###
  add "/news", priority: 0.7, changefreq: 'daily'

  ### カテゴリ ###
  Category.all.select(:id).each do |ca|
    if ca.products.exists?
      add "/products?category_id=#{ca.id}", priority: 0.7, changefreq: 'daily'
      add "/products?category_id=#{ca.id}&success=start", priority: 0.8, changefreq: 'daily'
    end

    add "/products?category_id=#{ca.id}&success=success", priority: 0.6, changefreq: 'daily'
  end

  ### 出品会社 ###
  User.companies.select(:id).each do |co|
    if co.products.exists?
      add "/products?company_id=#{co.id}", priority: 0.6, changefreq: 'daily'
      add "/products?company_id=#{co.id}&success=start", priority: 0.7, changefreq: 'daily'
    end
    add "/products?company_id=#{co.id}&success=success", priority: 0.6, changefreq: 'daily'

  end

  ### ヘルプページ ###
  Help.where(target: 0).pluck(:uid).each do |uid|
    add "/helps/#{uid}", priority: 0.3, changefreq: 'daily'
  end

  ### 売れ筋 ###
  add "/pops",       priority: 0.75, changefreq: 'daily'
  add "/pops/1000",  priority: 0.75, changefreq: 'daily'
  add "/pops/2000",  priority: 0.75, changefreq: 'daily'
  add "/pops/3000",  priority: 0.75, changefreq: 'daily'
  add "/pops/4000",  priority: 0.75, changefreq: 'daily'
  add "/pops/5000",  priority: 0.75, changefreq: 'daily'
  add "/pops/6000m", priority: 0.75, changefreq: 'daily'
end
