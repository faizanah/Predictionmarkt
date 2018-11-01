# TODO: remove unnecessaary stuff
module ContractQuoteMixins
  module Today
    def today_volume
      Money.new(todays_trades.sum(:amount), contract.currency).fractional
    end

    def todays_trades
      contract.trades.where("created_at > ?", Time.current.beginning_of_day)
    end

    def today_start_at
      Time.current.beginning_of_day
    end

    def today_trades
      contract.trades.where('created_at > ?', today_start_at).order('id')
    end

    def today_open_price
      today_trades.first&.price
    end

    def today_open_odds
      today_trades.first&.odds
    end

    def today_high
      today_trades.sort_by(&:price).last
    end

    def today_high_price
      today_high&.price
    end

    def today_high_odds
      today_high&.odds
    end

    def today_low
      today_trades.sort_by(&:price).first
    end

    def today_low_price
      today_low&.price
    end

    def today_low_odds
      today_low&.odds
    end

    def today_change_price
      return nil unless today_open_price
      last_trade_price - today_open_price
    end

    def today_change_odds
      return nil unless today_open_odds
      last_trade_odds - today_open_odds
    end

    def today_change_percent
      return nil unless today_change_price
      (today_change_price / today_open_price) * 100
    end
  end
end
