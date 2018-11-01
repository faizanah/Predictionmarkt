SitemapGenerator::Interpreter.send :include, Market::NavigationHelper
SitemapGenerator::Interpreter.send :include, SeoHelper

SitemapGenerator::Sitemap.default_host = "https://predictionmarkt.com"
SitemapGenerator::Sitemap.public_path = "public/sitemaps"
SitemapGenerator::Sitemap.compress = :all_but_first

SitemapGenerator::Sitemap.create do
  add '/blog', changefreq: 'daily'
  add '/how'
  add '/about'

  MarketCategory.where(name: %w[Published Generated]).each do |root_category|
    root_category.descendants.each do |category|
      next unless category.visible
      add market_category_path(category, category.url_name), changefreq: 'daily', priority: 1
    end
  end

  Market.active.find_each do |market|
    add seo_market_path(market)
  end
end
