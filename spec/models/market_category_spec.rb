require 'rails_helper'

RSpec.describe MarketCategory, type: :model do
  before do
    MarketCategory.seed
    10.times { create(:trade, requested_quantity: 7) }
  end

  let(:mp) { MarketCategory.generated('Most Predicted') }
  let(:cs) { MarketCategory.generated('Closing Soon') }

  it 'attaches market covers' do
    with_covers = MarketCategory.with_attached_market_cover
    expect(with_covers.size).to be > 0
  end

  it 'updates the most predicted category' do
    lowest_trade = create(:trade, requested_quantity: 5)
    highest_trade = create(:trade, requested_quantity: 15)
    MarketCategory.update_most_predicted
    expect(mp.markets.size).to eq 10 # out of 12
    expect(mp.markets.include?(lowest_trade.market)).to eq false
    expect(mp.markets.include?(highest_trade.market)).to eq true
  end

  # TODO: add better tests
  it 'updates closing soon category and orders market by close date' do
    closing_contract = create(:contract, close_date: 2.days.from_now)
    not_closing_contract = create(:contract, close_date: 120.days.from_now)
    create(:trade, contract: closing_contract)
    create(:trade, contract: not_closing_contract)
    MarketCategory.update_closing_soon
    expect(cs.markets.first).to eq closing_contract.market
    expect(cs.markets.include?(not_closing_contract.market)).to eq false
  end
end
