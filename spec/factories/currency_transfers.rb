FactoryBot.define do
  factory :currency_transfer do
    user { create :user, :with_wallets }

    state { CurrencyTransfer.states[:requested] }
    reason { CurrencyTransfer.reasons[:withdrawal] }

    currency { Wallet.currencies[:eth] }

    receiving_address { generate_address(currency) }

    total_change { -1000 }
    # currency_transaction { create :currency_transaction, user: user, reason: reason, currency: currency, total_change: total_change }
    trait :deposit do
      total_change { 1000 }
      reason { CurrencyTransfer.reasons[:deposit] }
      state { CurrencyTransfer.states[:finished] }
    end
  end
end
