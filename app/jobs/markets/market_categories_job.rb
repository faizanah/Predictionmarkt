module Markets
  class MarketCategoriesJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      MarketCategory.update_generated
    end
  end
end
