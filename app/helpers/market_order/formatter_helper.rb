module MarketOrder::FormatterHelper
  def quote_summary(shares, odds, args = {})
    prefix = "#{shares} &times; "
    prefix += '~' if args[:avg]
    format_odds(odds, prefix: prefix.html_safe)
  end

  # returns an array [ask_odds, bid_odds, spread_odds]
  # TODO not used
  def contract_spread_info(contract)
    ask_order = contract.quote.ask
    bid_order = contract.quote.bid
    trade = contract.quote.last_trade
    ask_odds = ask_order&.limit_odds || trade.odds
    bid_odds = bid_order&.limit_odds || trade.odds
    [ask_odds, bid_odds, 0]
  end

  def trading_matching_short_op(name)
    short_trading_op(name) == 'ask' ? 'bid' : 'ask'
  end

  def short_trading_op(name)
    case name
    when 'ask', 'sell', 'liquidation'
      'ask'
    when 'bid', 'buy', 'emission'
      'bid'
    else
      raise "unknown trading op #{name}"
    end
  end

  def long_trading_op(name)
    short_trading_op(name) == 'ask' ? 'sell' : 'buy'
  end

  def trading_operation_badge(order_or_operation, args = {})
    name = order_or_operation.is_a?(TradingOrder) ? order_or_operation.operation : order_or_operation
    badge_id = order_or_operation.is_a?(TradingOrder) ? "trading_order_badge_#{order_or_operation.to_param}" : nil
    classes = Array.wrap(args[:classes] || [])
    classes << (args[:disabled] ? 'badge-disabled' : "badge-#{long_trading_op(name)}")
    content_tag('span', long_trading_op(name), class: classes, disabled: args[:disabled], id: badge_id)
  end

  # TODO: Move
  def market_settle_amount
    format_money(@market.settle_price(params[:currency]), currency: params[:currency])
  end
end
