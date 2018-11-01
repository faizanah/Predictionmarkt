FactoryBot.define do
  factory :withdrawal_order do
    transient do
      withdraw_amount 100
      currency 'eth'
      user { create(:user, funds: Money.from_amount(withdraw_amount * 2, currency)) }
    end

    state { WithdrawalOrder.states[:pending] }
    residual_wallet { create(:wallet, state: 'receiving') }

    currency_transfer do
      create :currency_transfer, total_change: -withdraw_amount, user: user, currency: currency
    end

    from_wallet_ids do
      wallets = Array.new(2) do
        create(:wallet, amount: withdraw_amount / 2, currency: currency_transfer.currency)
      end
      wallets.map(&:id)
    end
  end
end
