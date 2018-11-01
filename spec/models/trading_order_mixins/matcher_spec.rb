require 'rails_helper'

RSpec.describe TradingOrderMixins::Matcher do
  let(:currency) { 'btc' }

  include_context 'trading context'

  it 'moves lower limit asks to the top of the queue' do
    [ask_price, ask_price + 2, ask_price - 2, ask_price - 1].each do |p|
      limit_ask(ask_quantity, p)
    end
    top_order = TradingOrder.ask_queue(contract).first
    expect(top_order.limit_price).to eq(ask_price - 2)
  end

  it 'moves higher limit bids to the top of the queue' do
    [bid_price, bid_price + 2, bid_price - 2, bid_price - 1].each do |p|
      limit_bid(bid_quantity, p)
    end
    top_order = TradingOrder.bid_queue(contract).first
    expect(top_order.limit_price).to eq(bid_price + 2)
  end

  it 'moves older asks to the top of the queue' do
    [ask_quantity - 2, ask_quantity - 3, ask_quantity].each do |q|
      limit_ask(q, ask_price)
    end
    top_order = TradingOrder.ask_queue(contract).first
    expect(top_order.requested_quantity).to eq(ask_quantity - 2)
  end

  it 'moves older bids to the top of the queue' do
    [bid_quantity + 3, bid_quantity - 3, bid_quantity - 2].each do |q|
      limit_bid(q, bid_price)
    end
    top_order = TradingOrder.bid_queue(contract).first
    expect(top_order.requested_quantity).to eq(bid_quantity + 3)
  end
end
