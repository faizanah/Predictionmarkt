require 'rails_helper'

RSpec.describe TradeGenerator do
  one_currency do
    let(:market_outcome) { create :market_outcome, odds: 0.4 }
    let(:contract) { create :contract, currency: currency, market_outcome: market_outcome }

    it 'generates trades' do
      trade = TradeGenerator.new(contract).perform
      expect(trade.closed?).to eq true
    end

    it 'closes all the orders' do
      TradeGenerator.new(contract).perform
      expect(contract.trading_orders.count).to eq 2
      expect(contract.trading_orders.reload.closed.count).to eq 2
    end

    it 'generates trades within ask/bid boundaries' do
      create(:trading_order, :limit_ask, odds: 0.8, requested_quantity: 2, contract: contract)
      create(:trading_order, :limit_bid, odds: 0.6, requested_quantity: 2, contract: contract)
      10.times do
        trade = TradeGenerator.new(contract).perform
        expect(trade.odds).to be >= 0.6
        expect(trade.odds).to be <= 0.8
      end
    end

    it 'generates trades within ask/trade boundaries' do
      create(:trading_order, :limit_ask, odds: 0.8, requested_quantity: 2, contract: contract)
      create(:trade, odds: 0.6, contract: contract)
      10.times do
        trade = TradeGenerator.new(contract).perform
        expect(trade.odds).to be >= 0.6
        expect(trade.odds).to be <= 0.8
      end
    end

    it 'must recognize closed trades as an upper boundary for the generated trades' do
      create(:trade, odds: 0.8, contract: contract)
      create(:trading_order, :limit_bid, odds: 0.6, requested_quantity: 2, contract: contract)
      10.times do
        trade = TradeGenerator.new(contract).perform
        expect(trade.odds).to be >= 0.6
        expect(trade.odds).to be <= 0.8
      end
    end

    it 'must recognize closed trades as a lowerboundary for the generated trades' do
      create(:trade, odds: 0.6, contract: contract)
      create(:trading_order, :limit_ask, odds: 0.8, requested_quantity: 2, contract: contract)
      10.times do
        trade = TradeGenerator.new(contract).perform
        expect(trade.odds).to be >= 0.6
        expect(trade.odds).to be <= 0.8
      end
    end
  end
end
