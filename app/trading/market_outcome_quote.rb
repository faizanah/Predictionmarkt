class MarketOutcomeQuote
  include FormatterHelper
  include CurrencyFormatterHelper
  attr_accessor :market_outcome, :cache

  def initialize(o)
    self.market_outcome = o
  end

  def contracts
    market_outcome.contracts
  end

  def today_volume
    raise
  end

  def todays_trades
    raise
  end

  def ticker
    market_outcome.ticker
  end

  def short_name
    market_outcome.format_short_title
  end

  def description
    market_outcome.title
  end

  def odds(name)
    name == 'ask' ? ask_odds : bid_odds
  end

  def sorted_odds_cache_key
    "market_outcome_quote:current_odds:#{market_outcome.id}:#{market_outcome.trading_orders.last&.id}"
  end

  def sorted_odds
    Rails.cache.fetch sorted_odds_cache_key do
      [ask, bid, last_trades].flatten.compact.map(&:odds).sort
    end
  end

  def ask
    @ask ||= contracts.map { |c| TradingOrder.ask_queue(c).first }.compact.sort_by(&:odds).first
  end

  def bid
    @bid ||= contracts.map { |c| TradingOrder.bid_queue(c).first }.compact.sort_by(&:odds).last
  end

  def ask_odds
    ask&.limit_odds
  end

  def bid_odds
    bid&.limit_odds
  end

  def prev_close_odds
    stat = contract.contract_trade_stats.daily.last
    return nil unless stat&.yesterday?
  end

  def last_trades
    @last_trades ||= contracts.map { |c| c.trades.last }.compact
  end

  def last_trade
    @last_trade ||= market_outcome.trades.last
  end

  def last_trade_odds
    last_trade&.odds
  end

  def today_start_at
    Time.current.beginning_of_day
  end

  def today_trades
    market_outcome.trades.where('created_at > ?', today_start_at).order('id')
  end

  def today_open_odds
    today_trades.first&.odds
  end

  def today_high
    today_trades.sort_by(&:odds).last
  end

  def today_high_odds
    today_high&.odds
  end

  def today_low
    today_trades.sort_by(&:odds).first
  end

  def today_low_odds
    today_low&.odds
  end

  def today_change_odds
    return nil unless today_open_odds
    last_trade_odds - today_open_odds
  end

  def today_change_percent
    return nil unless today_change_odds
    (today_change_odds / today_open_odds) * 100
  end
end
