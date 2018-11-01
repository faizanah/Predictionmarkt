FactoryBot.define do
  factory :wallet_transaction do
    transient do
      currency 'eth'
      user { create(:user, :with_wallets) }
    end

    wallet { create(:wallet, currency: currency, user: user) }
    total_change { 100 }

    before(:create) do |wallet_tx|
      wallet_tx.wallet.processing!
    end
  end
end
