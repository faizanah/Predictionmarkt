FactoryBot.define do
  factory :contract_transaction do
    contract { create :contract }
    user { create :user, shares: { contract => 20 } }

    total_change { 10 }

    reason { ContractTransaction.reasons[:trade] }

    # cause { create(:market_shares_transaction, :emission, market: contract.market, total_change: total_change, cause: user, currency: contract.currency) }
    cause { user }
  end
end
