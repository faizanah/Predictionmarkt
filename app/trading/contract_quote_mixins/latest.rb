module ContractQuoteMixins
  module Latest
    def ask
      @ask ||= TradingOrder.ask_queue(contract).first
    end

    def bid
      @bid ||= TradingOrder.bid_queue(contract).first
    end

    def last_trade
      @last_trade ||= contract.trades.last
    end

    # Spread which includes the previous trade (if there are no current bids / asks)
    # Technically it look at the last_trade orders specifically but it does not
    # and it looks only at the closing odds
    def visible_spread_details
      v_ask_odds = ask&.limit_odds || last_trade&.odds
      v_bid_odds = bid&.limit_odds || last_trade&.odds
      [v_ask_odds, v_bid_odds, visible_spread_from_odds(v_ask_odds, v_bid_odds)]
    end

    def visible_spread_from_odds(v_ask_odds, v_bid_odds)
      return nil unless v_ask_odds && v_bid_odds
      v_spread = v_ask_odds - v_bid_odds
      return nil if v_spread.negative?
      v_spread
    end

    def visible_spread
      @visible_spread ||= visible_spread_details.last
    end

    # TODO: this look veeeeeeeery weird
    def sorted_odds
      Rails.cache.fetch "contract_quote:current_odds:#{contract.id}" do
        [ask, bid, last_trade].compact.map(&:odds).sort
      end
    end

    def odds(name)
      (name == 'ask' ? ask : bid)&.limit_odds
    end

    def latest_odds(name)
      odds(name) || last_trade&.odds
    end

    def price(name)
      (name == 'ask' ? ask : bid)&.limit_price
    end
  end
end
