FactoryBot.define do
  factory :market do
    user { create :user }
    state { Market.states[:active] }
    market_type { Market.market_types[:categorical] }
    sequence(:title) { |n| "Market #{n}" }
    sequence(:ticker_base) { |n| "MKT#{n}" }
    rules { 'NO RULES!' }
    no_categories { true }
    skip_seed_cap { true }

    transient do
      shares []
      cover_name {}
    end

    after(:create) do |m, e|
      if e.cover_name
        market_cover_name = Dir.glob("spec/fixtures/market_covers/#{e.cover_name}.*").first

        m.market_cover.attach(io: File.open(market_cover_name), filename: market_cover_name)
      end

      e.shares.each do |currency, contracts|
        trx_args = { cause: m, reason: 'maintenance', market: m, currency: currency }
        MarketSharesTransaction.deposit!(contracts, trx_args)
      end

      def trx_args(args)
        { cause: m, reason: 'maintenance', market: m }.merge(args)
      end
    end
  end
end
