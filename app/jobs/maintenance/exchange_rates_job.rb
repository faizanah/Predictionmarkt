module Maintenance
  class ExchangeRatesJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      ExchangeRates.update_rates
    end
  end
end
