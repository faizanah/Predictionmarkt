require 'rails_helper'

RSpec.describe Market, type: :model do
  it 'updates tickers' do
    market = create(:market)
    market.update_attributes(ticker_base: 'T42')
    expect(market.reload.ticker).to eq 'T42'
    market.market_outcomes.each do |outcome|
      expect(outcome.ticker.start_with?("T42")).to eq true
      outcome.contracts.each do |contract|
        expect(contract.ticker.start_with?("T42")).to eq true
      end
    end
  end
end
