require 'rails_helper'

RSpec.describe Market, type: :model do
  it 'generates contracts' do
    contract = create(:contract)
    expect(contract.market.available_currencies.size).to be > 1
    expect(contract.market_outcome.reload.contracts.size).to eq 1
    contract.market.reload.generate_contracts
    expect(contract.market_outcome.contracts.size).to be > 1
  end

  context 'while rebalancing odds' do
    context 'of a binary market' do
      let(:market) { create(:market, market_type: 'binary') }

      it 'does not touch the odds if not necessary' do
        update_the_odds(market, [0.3, 0.7])
        validate_the_odds(market, [0.3, 0.7])
      end

      it 'keeps the sum equal to 1' do
        update_the_odds(market, [0.7, 0.7])
        validate_the_odds(market, [0.5, 0.5])
      end

      it 'updates the odds proportionally' do
        update_the_odds(market, [0.8, 0.4])
        validate_the_odds(market, [0.6667, 0.3333])
      end
    end
  end

  context 'inactive binary market' do
    let(:market) { create(:market, market_type: 'binary', state: 'pending', skip_seed_cap: false) }

    it 'starts trading with all the currencies ' do
      expect(market.available_currencies).to eq ApplicationCurrency.select(&:enabled?).map(&:code)
    end

    it 'has no seed capital when becomes when inactive' do
      market.available_currencies.each do |c|
        expect(market.market_cap(c).zero?).to eq true
      end
    end

    it 'emits seed capital when becomes active' do
      market.active!
      min_amount = Money.from_amount(4, 'USD')
      ApplicationCurrency.select(&:seedable?).each do |ac|
        expect(market.market_cap(ac.code).exchange_to('USD')).to be > min_amount
      end
    end
  end

  # TODO
  it 'sends mail when changing states' do
    market = create(:market, state: 'active')
    market.closed!
  end

  context 'while settling the markets' do
    let(:currency) { 'eth' }
    let(:market) { create(:market, market_type: :binary, skip_seed_cap: true) }
    let(:loser_outcome) { market.market_outcomes.first }
    let(:winner_outcome) { market.market_outcomes.last }
    let(:loser_contract) { loser_outcome.contracts.where(currency: currency).first! }
    let(:winner_contract) { winner_outcome.contracts.where(currency: currency).first! }

    it 'settles all the contracts' do
      winner_user = create(:user, shares: { winner_contract => 10 }, shares_with_market_cap: true)
      loser_user = create(:user, shares: { loser_contract => 10 }, shares_with_market_cap: true)
      market.process_winner_outcome!(winner_outcome)
      validate_balance(winner_user => 0, loser_user => 0)
      market.settle!
      expect(winner_user.shares(winner_contract)).to eq 0
      validate_balance(winner_user => 10, loser_user => 0)
    end

    it 'settles all the contracts with trading orders open' do
      ask = create(:trading_order, :limit_ask, contract: winner_contract, shares_with_market_cap: true,
                                               requested_quantity: 3, odds: 0.5)
      create(:trading_order, :limit_bid, contract: winner_contract, requested_quantity: 1, odds: 0.5)
      market.process_winner_outcome!(winner_outcome)
      market.settle!
      expect(ask.reload.cancelled?).to eq true
    end

    def validate_balance(user_shares = {})
      user_shares.each do |user, total_shares|
        expect(user.reload.balance(currency).fractional).to eq total_shares * winner_contract.settle_price
      end
    end
  end

  def update_the_odds(market, odds)
    market.market_outcomes.order('id').each_with_index do |mo, i|
      mo.reload.update_attributes!(odds: odds[i])
    end
    market.reload.rebalance_odds!
  end

  def validate_the_odds(market, odds)
    expect(market.market_outcomes.order('id').reload.map(&:odds)).to eq odds
  end
end
