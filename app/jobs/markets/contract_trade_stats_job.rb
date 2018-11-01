module Markets
  class ContractTradeStatsJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      ContractTradeStat.aggregate_hours
      ContractTradeStat.aggregate_days
    end
  end
end
