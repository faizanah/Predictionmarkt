module MarketOrder::ButtonsHelper
  def market_order_button(url, classes = nil)
    link_to 'Trade', url, class: [classes, 'btn-table-action']
  end

  def trade_outcome_button(outcome, args = {})
    url_args = args_with_currency(args)
    url = new_market_outcome_trading_order_path(outcome, url_args)
    market_order_button(url)
  end

  def trade_set_button(market, args = {})
    url_args = args_with_currency(args)
    url = new_market_trading_set_path(market, url_args)
    market_order_button(url, 'btn-table-action--secondary')
  end

  def cancel_trading_order_button(order, args = {})
    link_to 'Cancel', my_trading_order_path(order), method: :delete,
                                                    data: { confirm: 'Cancel?' },
                                                    class: args[:class] || 'btn-table-action'
  end

  def trading_order_state(order, args = {})
    content_tag('button', order.state, class: args[:class] || 'btn-table-state', disabled: args[:disabled])
  end
end
