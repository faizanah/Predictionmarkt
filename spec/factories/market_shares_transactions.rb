FactoryBot.define do
  factory :market_shares_transaction do
    market { create(:market) }
    currency { 'eth' }

    trait :emission do
      reason { MarketSharesTransaction.reasons[:emission] }
    end
  end
end
