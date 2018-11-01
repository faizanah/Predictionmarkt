require 'rails_helper'

RSpec.describe 'Trading Scenarios: limit orders', type: :feature do
  let(:currency) { 'btc' }

  include_context 'trading context'

  it 'selects matching closing price for limit bid' do
    limit_ask(ask_quantity, ask_price)
    limit_bid(bid_quantity, bid_price)
    validate_last_trade(bid_quantity)
  end

  it 'selects matching closing price for limit ask' do
    limit_bid(bid_quantity, bid_price)
    limit_ask(ask_quantity, ask_price)
    validate_last_trade(ask_quantity)
  end

  it 'selects lower closing price for limit bid' do
    limit_ask(ask_quantity, ask_price)
    limit_ask(ask_quantity, ask_price - 2)
    limit_ask(ask_quantity, ask_price + 2)
    limit_bid(bid_quantity, bid_price)
    validate_last_trade(bid_quantity, ask_price - 2)
  end

  it 'selects higher closing price for limit ask' do
    limit_bid(bid_quantity, bid_price)
    limit_bid(bid_quantity, bid_price - 2)
    limit_bid(bid_quantity, bid_price + 2)
    limit_ask(ask_quantity, ask_price)
    validate_last_trade(ask_quantity, bid_price + 2)
  end

  it 'bid fills with lowest prices' do
    limit_ask(ask_quantity, ask_price)
    limit_ask(1, ask_price + 2)
    limit_ask(1, ask_price - 2)
    limit_ask(2, ask_price + 1)

    bid = limit_bid(bid_quantity, bid_price)
    expect(bid.trades.size).to eq 2
  end

  it 'selects oldest maker' do
    oldest_maker = limit_ask(ask_quantity, ask_price)
    limit_ask(ask_quantity, ask_price)
    limit_bid(bid_quantity, bid_price)
    expect(Trade.last.ask_order).to eq oldest_maker
  end

  it 'closes / maker: limit ask (full); taker: limit bid (partial)' do
    ask = limit_ask(ask_quantity - 1, ask_price)
    bid = limit_bid(bid_quantity, bid_price)
    validate_last_trade(ask_quantity - 1, ask_price)
    validate_order_states(bid => 'maker', ask => 'closed')
  end

  it 'closes / maker: limit ask (partial); taker: limit bid (full)' do
    ask = limit_ask(ask_quantity, ask_price)
    bid = limit_bid(bid_quantity - 1, bid_price)
    validate_last_trade(bid_quantity - 1, ask_price)
    validate_order_states(bid => 'closed', ask => 'maker')
  end

  it 'closes / maker: limit bid (full); taker: limit ask (partial)' do
    bid = limit_bid(bid_quantity - 1, bid_price)
    ask = limit_ask(ask_quantity, ask_price)
    validate_last_trade(bid_quantity - 1, bid_price)
    validate_order_states(bid => 'closed', ask => 'maker')
  end

  it 'closes / maker: limit bid (partial); taker: limit ask (full)' do
    bid = limit_bid(bid_quantity, bid_price)
    ask = limit_ask(ask_quantity - 1, ask_price)
    validate_last_trade(ask_quantity - 1, ask_price)
    validate_order_states(bid => 'maker', ask => 'closed')
  end

  it 'closes / maker: 2 limit bids (full); taker: limit ask (full)' do
    bid1 = limit_bid(bid_quantity / 2, bid_price)
    bid2 = limit_bid(bid_quantity / 2, bid_price)
    ask = limit_ask(ask_quantity, ask_price)
    validate_order_states(bid1 => 'closed', bid2 => 'closed', ask => 'closed')
    validate_trade(bid1.trades.first, bid_quantity / 2, bid_price)
    validate_trade(bid2.trades.first, bid_quantity / 2, bid_price)
  end

  it 'closes / maker: 2 limit bids (full, partial); taker: limit ask (full)' do
    bid1 = limit_bid(bid_quantity / 2, bid_price)
    bid2 = limit_bid(bid_quantity * 2, bid_price)
    ask = limit_ask(ask_quantity, ask_price)
    validate_order_states(bid1 => 'closed', bid2 => 'maker', ask => 'closed')
    validate_trade(bid1.trades.first, bid_quantity / 2, bid_price)
    validate_trade(bid1.trades.first, bid_quantity / 2, bid_price)
  end

  it 'closes / maker: 2 limit bids (full, full); taker: limit ask (partial)' do
    bid1 = limit_bid(bid_quantity / 3, bid_price)
    bid2 = limit_bid(bid_quantity / 3, bid_price)
    ask = limit_ask(ask_quantity, ask_price)
    validate_order_states(bid1 => 'closed', bid2 => 'closed', ask => 'maker')
    validate_trade(bid1.trades.first, bid_quantity / 3, bid_price)
    validate_trade(bid2.trades.first, bid_quantity / 3, bid_price)
  end

  it 'closes / maker: 2 limit asks (full); taker: limit bid (full)' do
    ask1 = limit_ask(ask_quantity / 2, ask_price)
    ask2 = limit_ask(ask_quantity / 2, ask_price)
    bid = limit_bid(bid_quantity, bid_price)
    validate_order_states(ask1 => 'closed', ask2 => 'closed', bid => 'closed')
    validate_trade(ask1.trades.first, ask_quantity / 2, ask_price)
    validate_trade(ask2.trades.first, ask_quantity / 2, ask_price)
  end

  it 'closes / maker: 2 limit asks (full, partial); taker: limit bid (full)' do
    ask1 = limit_ask(ask_quantity / 2, ask_price)
    ask2 = limit_ask(ask_quantity * 2, ask_price)
    bid = limit_bid(bid_quantity, bid_price)
    validate_order_states(ask1 => 'closed', ask2 => 'maker', bid => 'closed')
    validate_trade(ask1.trades.first, ask_quantity / 2, ask_price)
    validate_trade(ask2.trades.first, ask_quantity / 2, ask_price)
    expect(bid.filled_quantity).to eq(bid_quantity)
  end

  it 'closes / maker: 2 limit asks (full, full); taker: limit bid (partial)' do
    ask1 = limit_ask(ask_quantity / 3, ask_price)
    ask2 = limit_ask(ask_quantity / 3, ask_price)
    bid = limit_bid(bid_quantity, bid_price)
    validate_order_states(ask1 => 'closed', ask2 => 'closed', bid => 'maker')
    validate_trade(ask1.trades.first, ask_quantity / 3, ask_price)
    validate_trade(ask2.trades.first, ask_quantity / 3, ask_price)
    expect(bid.filled_quantity).to eq(ask_quantity / 3 * 2)
  end
end
