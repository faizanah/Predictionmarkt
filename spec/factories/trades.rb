FactoryBot.define do
  factory :trade do
    contract { create(:contract) }

    transient do
      odds {}
      limit_price { (odds ? odds * contract.settle_price : contract.tick) }
      requested_quantity { 312 }
    end

    trade_type { Trade.trade_types[:service] }
    state { Trade.states[:processing] }

    ask_order do
      create :trading_order, :service_ask, contract: contract,
                                           state: 'processing',
                                           limit_price: limit_price,
                                           requested_quantity: requested_quantity
    end

    bid_order do
      create :trading_order, :service_bid, contract: contract,
                                           state: 'processing',
                                           limit_price: limit_price,
                                           requested_quantity: requested_quantity
    end

    # TODO: fix this ugly thing
    after(:create) do |t, e|
      t.bo.reload.maker!
      t.ao.reload.maker!
    end
  end
end
