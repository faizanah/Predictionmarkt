module CurrencyMenuHelper
  def trading_currency_menu(name)
    links = @market.available_currencies.map { |c| trading_currency_link(name, c) }
    currency_menu(currencies: links)
  end

  def trading_currency_link(market_action, name)
    p = market_action_params(currency: name.downcase)
    url = market_action_uri(market_action, p)
    [ApplicationCurrency.get(name), url]
  end

  def currency_menu(args = {})
    content = capture do
      concat currency_menu_toggle
      concat currency_menu_items(args)
    end
    menu_classes = ['mdc-menu-anchor', 'currency-menu', args[:menu_class]]
    content_tag('div', content, class: menu_classes.compact)
  end

  def currency_menu_toggle(currency = nil)
    link_text = capture do
      concat content_tag :span, "Currency: #{currency || params[:currency].upcase}"
      concat content_tag('i', '&#xE5C5;'.html_safe, class: 'material-icons')
    end
    menu_toggle('currency-menu', link_text)
  end

  def currency_menu_items(args)
    menu_items('currency-menu', currency_menu_links(args))
  end

  def currency_menu_links(args)
    args[:currencies].map do |ac, link|
      currency_menu_link_to(ac, link)
    end
  end

  def currency_menu_link_to(ac, url)
    active_link_to(ac.code, url)
  end

  def args_with_currency(args = {})
    code = args[:currency] || params[:currency]
    ac = ApplicationCurrency.get(code) if code
    ac ||= current_user&.preferred_ac
    ac ||= ApplicationCurrency.default
    args.merge(currency: ac.code)
  end
end
