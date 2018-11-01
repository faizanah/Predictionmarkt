RSpec.shared_context 'trading set context' do
  let(:market) { create(:market, market_type: 'binary', shares: { currency => 100 }) }
  let(:max_sets) { 12 } # must be devisible by 2 and 3
  let(:max_money) { max_sets * market.settle_price(currency) }
  let(:contracts) { market.contracts.where(currency: currency) }
  let(:user_with_no_money) { create(:user) }
  let(:user_with_money) { create(:user, funds: Money.new(max_money, currency)) }
  let(:user_with_shares) { create(:user, shares: contracts.map { |c| [c, max_sets] }.to_h) }

  let(:user_with_money_and_shares) { create(:user, funds: Money.new(max_money, currency), shares: contracts.map { |c| [c, max_sets] }.to_h) }
end
