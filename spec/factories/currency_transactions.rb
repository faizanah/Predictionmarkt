FactoryBot.define do
  factory :currency_transaction do
    reason { CurrencyTransaction.reasons[:deposit] }
    currency { Wallet.currencies[:eth] }
    user { create :user }
    cause { create(:currency_transfer, :deposit, user: user) }
    total_change { cause.total_change }
  end
end
