# rubocop:disable Performance/RedundantMerge
# Methods here require the following interface
# user_with_shares, user_with_money
# contract

def default_trading_order_args(args)
  { contract: contract }.merge(args)
end


def market_bid(amount, args = {})
  args = default_trading_order_args(args)
  args.merge!(requested_amount: amount)
  create(:trading_order, :market_bid, args)
end

def market_ask(quantity, args = {})
  args = default_trading_order_args(args)
  args.merge!(requested_quantity: quantity)
  puts contract.inspect
  create(:trading_order, :market_ask, args)
end

def limit_bid(quantity, price, args = {})
  args = default_trading_order_args(args)
  args.merge!(requested_quantity: quantity, limit_price: price)
  create(:trading_order, :limit_bid, args)
end

def limit_ask(quantity, price, args = {})
  args = default_trading_order_args(args)
  args.merge!(requested_quantity: quantity, limit_price: price)
  create(:trading_order, :limit_ask, args)
end

def validate_last_trade(quantity = nil, price = nil)
  validate_trade(Trade.last, quantity, price)
end

def validate_trade(trade, quantity = nil, price = nil)
  expect(trade.quantity).to eq quantity if quantity
  expect(trade.price).to eq price if price
  expect(trade.state).to eq 'closed'
end

def validate_order_states(orders = {})
  orders.each do |order, state|
    expect(order.reload.state).to eq state
  end
end
