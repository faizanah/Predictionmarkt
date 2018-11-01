module ContractsHelper
  def contract_1d_dir(contract)
    old = contract.trades.where('created_at < ?', 1.day.ago).last
    new = contract.trades.last
    if old && new
      diff = (new.price - old.price).to_d / contract.settle_price
      pct = number_with_precision(diff * 100, precision: 2, strip_insignificant_zeros: true)
      icon = diff > 0 ? mi.trending_up : mi.trending_down
      pct = "#{icon.to_s} #{diff > 0 ? '+' : '-'} #{pct}%"
    else
      pct = "0%"
    end
    content_tag(:span, pct)
  end

  def shares_value(trx)
    price = trx.contract.quote.last_trade&.price
    price ||= trx.contract.market_outcome.odds_avg * trx.contract.settle_price
    format_money(trx.total * price, currency: trx.currency, max_length: 12, usd_rounding: 0.01)
  end
end
