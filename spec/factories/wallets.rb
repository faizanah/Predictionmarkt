FactoryBot.define do
  factory :wallet do
    user
    currency { Wallet.currencies[:eth] }

    address { generate_address(currency) }
    state { Wallet.states[:unused] }

    transient do
      amount 0
    end

    after(:create) do |wallet, evaluator|
      next if evaluator.amount == 0
      create(:wallet, currency: wallet.currency) # new unused wallet
      money = if evaluator.amount.is_a?(Money)
                evaluator.amount
              else
                Money.from_amount(evaluator.amount, wallet.currency)
              end
      wallet.update_balance(money)
    end

    trait :real do
      address { full_wallet_creds(currency)['address'] }
      amount { full_wallet_money(currency) }
    end
  end

  def full_wallet_creds(currency)
    full_wallet_config['creds'][currency.to_s]
  end

  def full_wallet_money(currency)
    Money.new(full_wallet_config['amounts'][currency.to_s], currency)
  end

  def full_wallet_config
    @full_wallet_config ||= Rails.application.config_for(:currencies)['real_full_wallets']
  end
end
