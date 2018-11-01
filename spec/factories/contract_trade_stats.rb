FactoryBot.define do
  factory :contract_trade_stat do
    contract { create :contract }
    interval { ContractTradeStat.states[:hourly] }
    interval_at { Time.now.start_of_hour }

    mean_odds { 0.3 }
    min_odds { 0.1 }
    max_odds { 0.8 }

    quantity { 10 }
    amount { contract.max * quantity * mean_odds }
  end
end
