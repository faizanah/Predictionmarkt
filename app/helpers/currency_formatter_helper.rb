module CurrencyFormatterHelper
  def normalize_money(money, args)
    unless money.is_a?(Money)
      raise "no currency specified" unless args[:currency]
      money = Money.new(money, args[:currency])
    end
    secure_rounded_money_pair(money, args)
  end

  def secure_rounded_money_pair(money, args)
    args[:usd_rounding] = 1 if args[:secure]
    maybe_rounded_money = args[:usd_rounding] ? rounded_money(money, args[:usd_rounding]) : money
    money = maybe_rounded_money if args[:secure]
    [money, maybe_rounded_money]
  end

  # usd_rounding is dollar amount to convert to
  def rounded_money(money, usd_rounding = 1)
    if ApplicationCurrency.get(money.currency.iso_code).exchangeable?
      round_to = 10**Money.from_amount(usd_rounding, 'USD').exchange_to(money.currency).fractional.exponent
      rounded_fraction = money.fractional.divmod(round_to).first * round_to
    end
    Money.new(rounded_fraction ? rounded_fraction : money, money.currency)
  end

  def format_exchanged_money(money, _args = {})
    return '' unless ApplicationCurrency.get(money.currency.iso_code).exchangeable?
    converted_amount = money.exchange_to('USD').format(rounded_infinite_precision: true)
    content_tag('span', converted_amount, class: 'format-money-converted')
  end

  def format_money(money, args = {})
    return '—' if args[:explicit_null] && money.nil?
    money, maybe_rounded_money = normalize_money(money, args)
    o = format_money_text(money, maybe_rounded_money, args)
    return o unless args[:exchange]
    o + format_exchanged_money(money, args)
  end

  def format_money_text(money, maybe_rounded_money, args)
    money_text = maybe_rounded_money.format
    if args[:max_length] && money_text.size > args[:max_length]
      money_text = money_text[0..(args[:max_length] - 1)] + '…'
    end
    money_text = money_text_with_additions(money_text, args)
    args[:no_wrapper] ? money_text : wrapped_money(money, money_text, args)
  end

  def money_text_with_additions(money_text, args)
    [args[:prepend], money_text, args[:append]].compact.join
  end

  def wrapped_money(money, money_text, args)
    content_tag :span, money_text, class: 'formatted-currency',
                                   data: { toggle: 'tooltip', placement: 'top', html: true },
                                   title: format_money_hint(money, args)
  end

  def format_money_hint(money, args)
    return nil if money.zero?
    return nil if args[:disable_tooltip]
    format_money(money.fractional.abs, currency: money.currency.iso_code,
                                       disable_tooltip: true,
                                       exchange: true)
  end

  def format_currency_name(currency, args = {})
    out = ApplicationCurrency.get(currency).caption
    out += " (#{currency.upcase})" if args[:code]
    out
  end

  def format_total(change)
    format_money(change.total, currency: change.currency, max_length: 16)
  end

  def format_total_balance(user)
    usds = Money.new(0, 'USD')
    user.last_transactions.each do |tr|
      next unless tr.ac.exchangeable?
      usds += Money.new(tr.total, tr.currency).exchange_to('usd')
    end
    usds.format(rounded_infinite_precision: true)
  end
end
