module Maintenance
  class SitemapJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      SitemapGenerator::Interpreter.run
      SitemapGenerator::Sitemap.ping_search_engines
    end
  end
end
