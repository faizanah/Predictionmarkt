require 'rails_helper'

RSpec.describe ContractQuote do
  include_context 'trading time context'

  let(:contract) { create :contract }

  it 'presents an empty quote' do
    quote = ContractQuote.new(contract)
    expect(ContractQuote::Entity.represent(quote).as_json[:s]).to eq 'ok'
  end

  it 'presents a non-empty quote' do
    seed_trades_prev_day(contract.market)
    quote = ContractQuote.new(contract)
    expect(ContractQuote::Entity.represent(quote).as_json[:s]).to eq 'ok'
  end

  it 'shows the last trade' do
    seed_trades_prev_day(contract.market)
    quote = ContractQuote.new(contract)
    last_trade = Trade.where(contract: contract).order('id desc').first
    expect(quote.last_trade).to eq last_trade
  end

  # TODO: fix this shit
  it 'recognizes current odds ranges from previous trades' do
    create(:trade, odds: 0.8, contract: contract)
    create(:trading_order, :limit_bid, odds: 0.6, requested_quantity: 2, contract: contract)
    quote = ContractQuote.new(contract)
    expect(quote.sorted_odds.min).to eq 0.6
    expect(quote.sorted_odds.max).to eq 0.8
  end
end
