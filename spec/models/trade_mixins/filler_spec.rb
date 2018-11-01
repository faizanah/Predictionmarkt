require 'rails_helper'

# TODO: tests service trades
RSpec.describe TradeMixins::Filler do
  one_currency do
    include_context 'trading context'

    let(:ask) { limit_ask(ask_quantity, ask_price, state: 'processing') }
    let(:bid) { market_bid(bid_money, state: 'processing') }

    it 'assigns ask and bid orders properly' do
      [[ask, bid], [bid, ask]].each do |a, b|
        t = Trade.from_orders(a, b)
        expect(t.ask_order).to eq ask
        expect(t.bid_order).to eq bid
        expect(t.valid?).to eq true
      end
    end

    it 'fails if both orders are not supplied' do
      [[ask, ask], [nil, bid], [ask, nil]].each do |a, b|
        t = Trade.from_orders(a, b)
        expect(t.valid?).to eq false
      end
    end

    it 'handles equal price and quantity' do
      t = Trade.from_orders!(ask, bid)
      expect(t.quantity).to eq bid_quantity
      expect(t.price).to eq bid_price
    end

    it 'handles different price and quantity' do
      ask2 = limit_ask(ask_quantity - 1, ask_price - 1, state: 'paused')
      t = Trade.process_orders!(ask2, bid)
      expect(t.quantity).to eq(ask_quantity - 1)
      expect(t.price).to eq(ask_price - 1)
    end

    it 'transitions through the state changes' do
      t = Trade.from_orders(ask, bid)
      expect(t.state).to eq 'processing'
      t.save
      expect(t.state).to eq 'closed'
    end

    it 'fails to process orders from different contracts' do
      wrong_bid =  market_bid(bid_money, state: 'processing', contract: create(:contract))
      t = Trade.from_orders(ask, wrong_bid)
      expect(t.valid?).to eq false
      expect(t.save).to eq false
    end
  end
end
