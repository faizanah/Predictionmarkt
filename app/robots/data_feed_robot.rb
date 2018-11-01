class DataFeedRobot

  module Config
    def service_name
      self.class.name.sub('Robot', '').downcase
    end

    def config
      @config ||= Rails.application.config_for(:data_feeds)[service_name].with_indifferent_access
    end

    def service_user
      User.service_user(service_name)
    end
  end

  include Config
  extend Config

  protected

    def assign_market_category(market, options)
      market_category = MarketCategory.where(name: options['market_category']).first
      raise "can't find market category" unless market_category
      market_category.markets << market unless market.market_categories.include?(market_category)
    end
end
