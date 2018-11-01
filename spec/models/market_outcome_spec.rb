require 'rails_helper'

RSpec.describe MarketOutcome, type: :model do
  it 'creates composite tickers' do
    market = create(:market, ticker_base: 'MKT123')
    market_outcome = create(:market_outcome, market: market, ticker_base: 'OUT1')
    expect(market_outcome.ticker).to eq 'MKT123:OUT1'
  end

  it 'generates default outcomes for categorical markets' do
    market = create(:market, market_type: 'categorical')
    expect(market.market_outcomes.size).to eq 1
    expect(market.market_outcomes.last.fallback?).to eq true
    expect { described_class.add_default_outcomes(market) }.to change { market.market_outcomes.size }.by(0)
  end

  it 'generates default outcomes for binary markets' do
    market = create(:market, market_type: 'binary')
    expect(market.market_outcomes.size).to eq 2
    expect(market.market_outcomes.map(&:outcome_type).sort).to eq %w[no yes]
    expect { described_class.add_default_outcomes(market) }.to change { market.market_outcomes.size }.by(0)
  end

  it 'generates contracts for categorical markets' do
    market = create(:market, market_type: 'categorical')
    contract_currencies = market.market_outcomes.last.contracts.map(&:currency)
    expect(contract_currencies).to eq ApplicationCurrency.select(&:enabled?).map(&:code)
  end

  it 'updates the winner' do
    market = create(:market)
    market_outcome = create(:market_outcome, market: market)
    validate_winner(market, market_outcome, false)
    market_outcome.winner = true
    validate_winner(market, market_outcome, true)
  end

  # rubocop:disable Metrics/AbcSize
  def validate_winner(market, outcome, is_winner = true)
    expect(outcome.winner?).to eq is_winner
    actual_winner = market.reload.winner_outcome
    if is_winner
      expect(actual_winner).to eq outcome
      expect(market.closed?).to eq true
    else
      expect(actual_winner).not_to eq outcome
    end
  end
end
