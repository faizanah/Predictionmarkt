module PmktHelper
  def pmkt_config
    Rails.application.config_for(:pmkt).with_indifferent_access
  end

  def link_to_cause(object)
    text = object.reason.titleize
    case object.cause.class.to_s
    when 'TradingOrder'
      link_to text, my_trading_order_path(object.cause)
    when 'MarketSharesTransaction'
      link_to text, my_trading_set_path(object.cause)
    when 'Trade'
      order = object.cause.trading_order_by(current_user)
      link_to text, my_trading_order_path(order)
    else
      text
      # object.cause.class.to_s
    end
  end
end
