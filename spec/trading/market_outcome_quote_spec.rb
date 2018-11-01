require 'rails_helper'

RSpec.describe MarketOutcomeQuote do
  include_context 'trading time context'

  let(:contract) { create :contract }
  let(:market_outcome) { contract.market_outcome }

  before do
    contract.market.reload.generate_contracts
  end

  it 'shows the last trade' do
    seed_trades_prev_day(contract.market)
    quote = MarketOutcomeQuote.new(market_outcome)
    last_trade = Trade.where(market_outcome: market_outcome).order('id desc').first
    expect(quote.last_trade).to eq last_trade
  end

  # TODO: seems to be broken sporadically. Update: yes it is. Update: still broken.
  it 'shows the current low and high odds' do
    seed_trades_prev_day(contract.market)
    quote = MarketOutcomeQuote.new(market_outcome)
    low = quote.sorted_odds.min
    high = quote.sorted_odds.max
    expect(high > low).to eq true
  end
end
