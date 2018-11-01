FactoryBot.define do
  factory :trading_order do
    contract { create :contract }

    time_in_force { TradingOrder.time_in_forces[:gtc] }

    state { TradingOrder.states[:taker] }

    transient do
      odds {}
      shares_with_market_cap { false }
    end

    trait :market_ask do
      order_type { TradingOrder.order_types[:market_order] }
      operation { TradingOrder.operations[:ask] }
      time_in_force { TradingOrder.time_in_forces[:ioc] }
      user { create :user, shares: { contract => requested_quantity }, shares_with_market_cap: shares_with_market_cap }
    end

    trait :market_bid do
      order_type { TradingOrder.order_types[:market_order] }
      operation { TradingOrder.operations[:bid] }
      time_in_force { TradingOrder.time_in_forces[:ioc] }
      user { create :user, funds: Money.new(requested_amount, contract.currency) }
    end

    trait :limit_ask do
      order_type { TradingOrder.order_types[:limit_order] }
      operation { TradingOrder.operations[:ask] }
      limit_price { (odds ? odds * contract.settle_price : contract.tick * 5) }
      user { create :user, shares: { contract => requested_quantity }, shares_with_market_cap: shares_with_market_cap }
    end

    trait :limit_bid do
      order_type { TradingOrder.order_types[:limit_order] }
      operation { TradingOrder.operations[:bid] }
      limit_price { (odds ? odds * contract.settle_price : contract.tick * 5) }
      user { create :user, funds: Money.new(requested_quantity * limit_price, contract.currency) }
    end

    trait :service_ask do
      order_type { TradingOrder.order_types[:service_order] }
      operation { TradingOrder.operations[:ask] }
      user { User.service_user('factory-buyer') }
      time_in_force { TradingOrder.time_in_forces[:gtc] }
      requested_quantity { 123 }
      limit_price { contract.tick }
    end

    trait :service_bid do
      order_type { TradingOrder.order_types[:service_order] }
      operation { TradingOrder.operations[:bid] }
      user { User.service_user('factory-seller') }
      time_in_force { TradingOrder.time_in_forces[:gtc] }
      requested_quantity { 123 }
      limit_price { contract.tick }
    end
  end
end
