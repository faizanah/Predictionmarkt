FactoryBot.define do
  factory :market_outcome do
    sequence(:title) { |n| "Will market outcome #{n} happen? (long title)" }
    sequence(:short_title) { |n| "Market outcome #{n}" }
    sequence(:ticker_base) { |n| "OUT#{n}" }
    outcome_type { MarketOutcome.outcome_types[:category] }

    market { create :market }
  end
end
