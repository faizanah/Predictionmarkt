module MarketOrder::FormHelper
  def order_type_link(name)
    p = market_action_params(type: name)
    active = params[:type] == name
    classes = ['order-type', "order-type-#{name}", 'ajaxable', 'mdc-tab']
    classes << 'active mdc-tab--active' if active

    content_tag 'div', name, class: classes,
                             data: { url: market_action_uri('trading_order', p) }
  end

  def market_action_params(new_params = {})
    default_params = @form.default_outcome_params
    current_params = params.permit(default_params.keys)
    default_params.merge(current_params).merge(new_params)
  end

  def market_action_uri(market_action, p)
    case market_action
    when 'trading_set'
      new_market_trading_set_path(@market, p)
    when 'trading_order'
      new_market_outcome_trading_order_path(@market_outcome, p)
    end
  end

  def trading_form_hidden_fields(f)
    capture do
      @form.uri_params.each do |param, value|
        concat f.input param, as: :hidden
        concat content_tag(:span, nil, id: "test_form_#{param}_#{value}") if Rails.env.test?
      end
    end
  end

  # TODO: split
  def market_operation_link(market_action, name)
    p = market_action_params(operation: name)
    url = market_action_uri(market_action, p)

    short_name = trading_matching_short_op(name)
    active = params[:operation] == name

    if @contract
      order = short_name == 'ask' ? @contract.quote.ask : @contract.quote.bid
      trade = @contract.quote.last_trade

      odds = order&.limit_odds || trade&.odds
      price = order&.limit_price || trade&.price
      count = order&.requested_quantity || trade&.quantity

      title_text = order ? "Available #{trading_matching_short_op(name)}" : 'Last trade'
    else
      title_text = 'Fixed price'
      odds = 1
      price = @market.settle_price(@form.currency)
      count = short_name == 'bid' ? @form.quantity_max : '∞'
    end

    odds_text = normalize_odds(odds)
    price_text_prepend = count ? "#{count} x " : nil

    price_text = format_money price, currency: @form.currency,
                                     no_wrapper: true,
                                     explicit_null: true,
                                     prepend: price_text_prepend

    wrapper_classes = ["market-operation-#{name}"]
    badge_args = { classes: 'market-operation-badge' }

    if active
      wrapper_classes << 'active'
    else
      badge_args[:disabled] = true
      wrapper_classes << 'ajaxable'
    end

    content_tag('div', class: wrapper_classes, data: { url: url }) do
      capture do
        # concat active_link_to content, url, active: { operation: name }
        concat content_tag('div', title_text, class: 'market-operation-header-title')
        concat content_tag('div', odds_text, class: 'market-operation-header-odds')
        concat content_tag('div', price_text, class: 'market-operation-header-price')
        concat trading_operation_badge(name, badge_args)
      end
    end
  end
end
