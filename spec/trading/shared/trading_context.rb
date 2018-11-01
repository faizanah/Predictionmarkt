RSpec.shared_context 'trading context' do
  let(:contract) { create :contract, currency: currency, tick: 1 }

  # Fractional money only
  let(:bid_quantity) { 100 }
  let(:bid_price) { 10 }
  let(:bid_money) { bid_quantity * bid_price }

  let(:ask_quantity) { 100 }
  let(:ask_price) { 10 }
  let(:ask_money) { ask_quantity * ask_price }

  let(:available_money) do
    if ApplicationCurrency.get(currency).exchangeable?
      Money.from_amount(10, 'USD').exchange_to(currency).fractional.round
    else
      Money.from_amount(10_000, currency).fractional
    end
  end

  let(:available_shares) { 1000 }

  let(:user_money) { Money.new(available_money, currency) }
  let(:user_with_no_money) { create(:user) }
  let(:user_with_money) { create(:user, funds: user_money) }
  let(:user_with_shares) { create(:user, shares: { contract => available_shares }) }

  let(:user_with_money_and_shares) { create(:user, funds: user_money, shares: { contract => available_shares }) }
end
