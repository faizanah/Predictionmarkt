FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{n}_#{Faker::Internet.email}" }
    password 'RohDo4veif6voh2r'

    transient do
      funds { [] }
      shares {}
      shares_with_market_cap { false }
      create_wallets false
      default_amount { 1000 }
    end

    trait :with_wallets do
      after(:create) do |u|
        create_unused_wallets
        u.assign_wallets
      end
    end

    trait :with_all_currencies do
      funds do
        ApplicationCurrency.map { |ac| Money.new(default_amount, ac.code) }
      end
    end

    before(:create) do |u, evaluator|
      u.skip_confirmation!
    end

    after(:create) do |u, evaluator|
      def trx_args(u, args)
        { user: u, cause: u, reason: 'trading_set' }.merge(args)
      end

      Array.wrap(evaluator.funds).each do |money|
        if evaluator.create_wallets
          create(:wallet, amount: money, currency: money.currency.iso_code, user: u)
        else
          CurrencyTransaction.deposit!(money.fractional, trx_args(u, currency: money.currency.iso_code))
        end
      end
      evaluator.shares&.each do |contract, shares_count|
        if evaluator.shares_with_market_cap
          u.deposit_shares_with_market_cap(contract, shares_count)
        else
          ContractTransaction.deposit!(shares_count, trx_args(u, contract: contract))
        end
      end
    end
  end
end
