module Predictit::Selector

  protected

    def select_markets(group_id, selector)
      predictit_markets = Predictit::Api.group(group_id).map do |json|
        Predictit::Market.new(json)
      end
      filter_markets(predictit_markets, selector)[0, selector['limit']]
    end

  private

    def filter_markets(predictit_markets, selector)
      predictit_markets.select do |m|
        m.open? &&
          market_match_regexp(m, selector) &&
          market_match_close_date(m, selector)
      end
    end

    def market_match_regexp(m, selector)
      return true unless selector['regexp']
      Regexp.new(selector['regexp']).match(m.title)
    end

    def market_match_close_date(m, selector)
      return true unless m.close_date
      min_date = selector['min_close_date_days'].days.from_now
      max_date = selector['max_close_date_days'].days.from_now
      m.close_date.between?(min_date, max_date)
    end
end
