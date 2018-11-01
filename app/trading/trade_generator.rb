require 'fileutils'

# TODO: needs to be refactored
# Needs to take into account the normal trading activity vs the generated one
class TradeGenerator
  # TODO: https://github.com/jtescher/descriptive-statistics
  attr_accessor :contract

  def initialize(c)
    self.contract = c
    FileUtils.mkdir_p logger_dir
  end

  def logger_dir
    Rails.root.join('log/trade-generator')
  end

  def logger
    @trade_logger ||= Logger.new("#{logger_dir}/#{contract.market.to_param}.log")
  end

  def log(hash)
    log_hash = { outcome_id: contract.market_outcome.to_param,
                 outcome: contract.market_outcome.format_short_title,
                 currency: contract.currency }
    logger.info(log_hash.merge(hash).ai)
  end

  def outcome
    contract.market_outcome
  end

  def quote
    @quote ||= ContractQuote.new(contract)
  end

  def outcome_quote
    @outcome_quote ||= MarketOutcomeQuote.new(contract.market_outcome)
  end

  def maker_user
    @maker_user ||= User.service_user('maker')
  end

  def taker_user
    @taker_user ||= User.service_user('taker')
  end

  def last_trade
    @last_trade ||= contract.trades.where.not(trade_type: 'service').order('id asc').first
  end

  def outcome_interval
    outcome_max - outcome_min
  end

  def outcome_min
    outcome_quote.sorted_odds.min || outcome.odds
  end

  def outcome_max
    outcome_quote.sorted_odds.max || outcome.odds
  end

  def maximum_interval
    0.05
  end

  def interval_step
    0.02
  end

  def extend_min_interval(min_odds, max_odds)
    return 0 if max_odds - min_odds >= maximum_interval
    if outcome_interval >= maximum_interval &&
       (min_odds - (outcome_min + interval_step)) <= 0
      0
    else
      interval_step
    end
  end

  def extend_max_interval(min_odds, max_odds)
    return 0 if max_odds - min_odds >= maximum_interval
    if outcome_interval >= maximum_interval &&
       outcome_max - (max_odds + interval_step) <= 0
      0
    else
      interval_step
    end
  end

  # Get a realistic range of the odds where the trade could happen
  def extend_boundaries(min_odds, max_odds)
    [min_odds - extend_min_interval(min_odds, max_odds),
     max_odds + extend_max_interval(min_odds, max_odds)]
  end

  # Make sure that the new trade does not go above/below the existing orders
  # TODO: this can create an order with a price of the current ask or bid
  # it should happen only if there are multiple asks/bids
  def shrink_boundaries(min_odds, max_odds)
    min_odds = quote.bid.odds + 0.005 if quote.bid
    max_odds = quote.ask.odds - 0.005 if quote.ask
    if min_odds > max_odds
      [min_odds, min_odds]
    else
      [min_odds, max_odds]
    end
  end

  # Make sure boundaries do not go above contract limits
  # round to single percentage points
  def normalize_boundaries(min_odds, max_odds)
    min_odds = 0.01 if min_odds < 0.01
    max_odds = 0.99 if max_odds > 0.99
    [min_odds, max_odds].map { |o| o.round(2) }
  end

  def sorted_odds
    [quote.sorted_odds.min || outcome.odds, quote.sorted_odds.max || outcome.odds]
  end

  def target_boundaries
    min, max = sorted_odds
    min, max = extend_boundaries(min, max)
    min, max = shrink_boundaries(min, max)
    normalize_boundaries(min, max)
  end

  def target_price
    return @target_price if @target_price
    min_odds, max_odds = target_boundaries
    target_odds = (rand * (max_odds - min_odds) + min_odds).round(2)
    log(sorted_odds: sorted_odds, new_min_odds: min_odds, new_max_odds: max_odds, target_odds: target_odds)
    @target_price = target_odds * contract.settle_price
  end

  def quantity
    @quantity ||= (rand(50) + 1)
  end

  def order_args
    { limit_price: target_price,
      time_in_force: :gtc,
      contract: contract,
      state: 'processing',
      order_type: 'service_order',
      requested_quantity: quantity }
  end

  def perform
    maker_order = maker_user.trading_orders.bid.create!(order_args)
    taker_order = maker_user.trading_orders.ask.create!(order_args)
    Trade.process_orders!(maker_order, taker_order, 'service')
  end

  def self.seed(n = 10)
    contract_scope = Contract.active.where(currency: ApplicationCurrency.select(&:seedable?).map(&:code))
    Contract.where(id: contract_scope.pluck(:id).sample(n)).each do |c|
      new(c).perform
    end
  end
end
