require 'feature_helper'

describe 'Basic anonymous features' do
  include_context 'trading context'

  let(:currency) { 'eth' }
  let(:market) { contract.market }
  let(:market_outcome) { contract.market_outcome }

  context 'viewing markets' do
    before do
      MarketCategory.seed
      market.market_categories << MarketCategory.where(name: 'Featured').first
    end

    it "browses markets" do
      visit root_path
      expect(page).to have_content(market.title)
      snap('anonymous', 'markets')
      click_on(market.title)
      expect(page).to have_content('RULES')
      snap('anonymous', 'show-market')
    end
  end

  context 'viewing trading sets/orders details' do
    it "sees the trading order details" do
      visit new_market_outcome_trading_order_path(market_outcome)
      expect(page).to have_content(market.title)
      snap('anonymous', 'show-trading-order')
    end

    it "sees the trading set as well" do
      visit new_market_trading_set_path(market)
      expect(page).to have_content(market.title)
      snap('anonymous', 'show-trading-set')
    end
  end
end
