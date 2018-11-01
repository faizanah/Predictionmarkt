module MarketOrder::StatusHelper
  # TODO: display market ask orders
  def trading_order_progress(order, args = {})
    bar = content_tag(:div, mdc_linear_slider(order.progress), class: 'trading-order-progress-bar')
    progress_info_text = trading_order_progress_text(order, args)
    info = content_tag(:div, progress_info_text, class: 'trading-order-progress-info')
    content_tag(:span, bar + info, class: 'trading-progress')
  end

  def trading_order_progress_text(order, args)
    progress_info = if order.market_order? && order.bid?
                      if args[:shares_only]
                        order.filled_quantity
                      else
                        order.progress_info.map { |m| format_money(m, currency: order.currency) }
                      end
                    else
                      order.progress_info
                    end
    Array.wrap(progress_info).join(' / ').html_safe
  end

  # TODO: move to decorators or something
  def trading_order_human_state(order)
    return 'open' if order.maker?
    order.state
  end
end
