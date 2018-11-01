class CoinmarketcapRobot < DataFeedRobot
  class CoinMarketCreator < DataFeedRobot
    attr_accessor :selection_options, :coin_info, :direction

    def initialize(a, b, c)
      self.selection_options = a
      self.coin_info = b
      self.direction = c
    end

    def skip?
      Market.where(ticker: ticker).take
    end

    def create_market
      service_user.markets.binary.create(ticker: ticker, market_spec: create_market_spec, close_date: limit_date)
    end

    private

      def create_market_spec
        MarketSpec::CoinPrice.create!(symbol: symbol, name: coin_info['name'], direction: direction,
                                      limit_price: limit_price, limit_date: limit_date)
      end

      def ticker
        date = limit_date.strftime("%Y%m%d")
        [symbol, date, direction].join(':')
      end

      def symbol
        coin_info['symbol']
      end

      def limit_price
        raw_price = limit_price_raw
        raw_price.round(limit_price_rounding(raw_price))
      end

      def limit_price_rounding(raw_price)
        if raw_price < 4
          2
        else
          round_limit = raw_price.to_i.to_s.size - 2
          round_limit.positive? ? -round_limit : 0
        end
      end

      def limit_price_raw
        return prices_max * selection_options['price_up'] if direction == 'UP'
        prices_min * selection_options['price_down']
      end

      def limit_date
        Time.now.end_of_quarter
      end

      def prices
        from = selection_options[:lookback_days].days.ago
        to = Time.now
        a, b = [from, to].map { |t| t.strftime("%Y%m%d") }
        Coinmarketcap.get_historical_price(coin_info['id'], a, b)
      end

      def prices_max
        prices.map { |a| a[:high] }.max
      end

      def prices_min
        prices.map { |a| a[:low] }.min
      end
  end

  def ingest_markets
    config[:selections].each do |name, selection_options|
      Coinmarketcap.coins(selection_options[:top_coins]).each do |coin_info|
        # Disabled up direction
        coin_creators = %w[DOWN].map { |d| CoinMarketCreator.new(selection_options, coin_info, d) }
        create_markets(coin_creators, selection_options)
      end
    end
  end

  private

    def create_markets(coin_creators, selection_options)
      return if coin_creators.first.skip?
      markets = coin_creators.map(&:create_market)
      markets.each { |m| assign_market_category(m, selection_options) }
      markets.each { |m| m.market_spec.attach_cover }
      seed_markets(markets)
    end

    def seed_markets(markets)
      markets.each do |market|
        market.active!
        market.available_currencies.each do |c|
          market.seed_ask_orders(market.yes_contract(c) => 0.5, market.no_contract(c) => 0.6)
          market.seed_bid_orders(market.yes_contract(c) => 0.4, market.no_contract(c) => 0.5)
          market.contracts.where(currency: c).each do |contract|
            TradeGenerator.new(contract).perform
          end
        end
      end
    end
end
