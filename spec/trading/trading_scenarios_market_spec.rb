require 'rails_helper'

RSpec.describe 'Trading Scenarios: market orders', type: :feature do
  let(:currency) { 'eth' }

  include_context 'trading context'

  it 'selects matching settlement price for market bid' do
    limit_ask(ask_quantity, ask_price)
    market_bid(bid_money)
    validate_last_trade(bid_quantity)
  end

  it 'selects matching settlement price for market ask' do
    limit_bid(bid_quantity, bid_price)
    market_ask(ask_money)
    validate_last_trade(bid_quantity)
  end

  it 'selects lower settlement price' do
    limit_ask(ask_quantity, ask_price)
    limit_ask(ask_quantity, ask_price + 2)
    market_bid(bid_money)
    validate_last_trade(bid_quantity, ask_price)
  end

  it 'selects oldest maker' do
    oldest_maker = limit_ask(ask_quantity, ask_price)
    limit_ask(ask_quantity, ask_price)
    market_bid(bid_money)
    expect(Trade.last.ask_order).to eq oldest_maker
  end

  it 'settles / maker: limit ask (full); taker: market bid (partial)' do
    ask = limit_ask(ask_quantity - 1, ask_price)
    bid = market_bid(bid_money)
    validate_last_trade(ask_quantity - 1, ask_price)
    validate_order_states(bid => 'closed', ask => 'closed')
  end

  it 'settles / maker: limit ask (partial); taker: market bid (full)' do
    ask = limit_ask(ask_quantity, ask_price)
    bid = market_bid(bid_money - 1)
    validate_last_trade(bid_quantity - 1, ask_price)
    validate_order_states(bid => 'closed', ask => 'maker')
  end

  it 'settles / maker: limit bid (full); taker: market ask (partial)' do
    bid = limit_bid(bid_quantity - 1, bid_price)
    ask = market_ask(ask_money)
    validate_last_trade(bid_quantity - 1, ask_price)
    validate_order_states(bid => 'closed', ask => 'closed')
  end

  it 'settles / maker: limit bid (partial); taker: market ask (full)' do
    bid = limit_bid(bid_quantity, bid_price)
    ask = market_ask(ask_quantity - 1)
    validate_last_trade(ask_quantity - 1, bid_price)
    validate_order_states(bid => 'maker', ask => 'closed')
  end

  it 'settles / maker: 2 limit bids (full); taker: market ask (full)' do
    bid1 = limit_bid(bid_quantity / 2, bid_price)
    bid2 = limit_bid(bid_quantity / 2, bid_price)
    ask = market_ask(ask_money)
    validate_order_states(bid1 => 'closed', bid2 => 'closed', ask => 'closed')
    validate_trade(bid1.trades.first, bid_quantity / 2, bid_price)
    validate_trade(bid2.trades.first, bid_quantity / 2, bid_price)
  end

  it 'settles / maker: 2 limit bids (full, partial); taker: market ask (full)' do
    bid1 = limit_bid(bid_quantity / 2, bid_price)
    bid2 = limit_bid(bid_quantity * 2, bid_price)
    ask = market_ask(ask_quantity)
    validate_order_states(bid1 => 'closed', bid2 => 'maker', ask => 'closed')
    validate_trade(bid1.trades.first, bid_quantity / 2, bid_price)
    validate_trade(bid2.trades.first, bid_quantity / 2, bid_price)
  end

  it 'settles / maker: 2 limit bids (full, full); taker: market ask (partial)' do
    bid1 = limit_bid(bid_quantity / 3, bid_price)
    bid2 = limit_bid(bid_quantity / 3, bid_price)
    ask = market_ask(ask_money)
    validate_order_states(bid1 => 'closed', bid2 => 'closed', ask => 'closed')
    validate_trade(bid1.trades.first, bid_quantity / 3, bid_price)
    validate_trade(bid2.trades.first, bid_quantity / 3, bid_price)
  end

  it 'settles / maker: 2 limit asks (full); taker: market bid (full)' do
    ask1 = limit_ask(ask_quantity / 2, ask_price)
    ask2 = limit_ask(ask_quantity / 2, ask_price)
    bid = market_bid(bid_money)
    validate_order_states(ask1 => 'closed', ask2 => 'closed', bid => 'closed')
    validate_trade(ask1.trades.first, ask_quantity / 2, ask_price)
    validate_trade(ask2.trades.first, ask_quantity / 2, ask_price)
  end

  it 'settles / maker: 2 limit asks (full, partial); taker: market bid (full)' do
    ask1 = limit_ask(ask_quantity / 2, ask_price)
    ask2 = limit_ask(ask_quantity * 2, ask_price)
    bid = market_bid(bid_money)
    validate_order_states(ask1 => 'closed', ask2 => 'maker', bid => 'closed')
    validate_trade(ask1.trades.first, ask_quantity / 2, ask_price)
    validate_trade(ask2.trades.first, ask_quantity / 2, ask_price)
    expect(bid.filled_quantity).to eq(bid_quantity)
  end

  it 'settles / maker: 2 limit asks (full, full); taker: market bid (partial)' do
    ask1 = limit_ask(ask_quantity / 3, ask_price)
    ask2 = limit_ask(ask_quantity / 3, ask_price)
    bid = market_bid(bid_money)
    validate_order_states(ask1 => 'closed', ask2 => 'closed', bid => 'closed')
    validate_trade(ask1.trades.first, ask_quantity / 3, ask_price)
    validate_trade(ask2.trades.first, ask_quantity / 3, ask_price)
    expect(bid.filled_quantity).to eq(ask_quantity / 3 * 2)
  end
end
