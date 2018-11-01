FactoryBot.define do
  factory :contract do
    transient do
      close_date { nil }
    end

    market { create :market, close_date: close_date }

    market_outcome { create(:market_outcome, market: market) }

    state { Contract.states[:active] }
    currency { Wallet.currencies[:eth] }

    sequence(:ticker_base) { |n| "TB#{n}#{currency}" }
  end
end
