def trading_set_args(market)
  currency = market.available_currencies.first
  { currency: currency, operation: 'buy' }
end

def each_trading_set_param_combo(form_args = {})
  form = TradingSetForm.new(form_args)
  form.allowed_outcome_params.each do |key, values|
    values.each do |value|
      yield trading_set_args(form_args[:market]).merge(key => value)
    end
  end
end

def full_trading_set_path(market, args = {})
  new_market_trading_set_path(market, trading_set_args(market).merge(args))
end
