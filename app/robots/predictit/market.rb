class Predictit::Market
  include Predictit::Market::Ingestion

  attr_accessor :blob, :market

  def initialize(market_json)
    self.blob = market_json
  end

  def open?
    @blob['Contracts'].first['Status'] == 'Open'
  end

  def close_date
    date_end = @blob['Contracts'].first['DateEnd']
    return nil if date_end == 'N/A'
    Time.parse(date_end)
  end

  def title
    blob['Name']
  end

  def ticker
    blob['TickerSymbol']
  end

  def market_type
    blob['Contracts'].size > 1 ? 'categorical' : 'binary'
  end

  def yes_odds
    blob['Contracts'].first['BestBuyYesCost']
  end

  protected

    def market_scope
      PredictitRobot.service_user.markets.where(external_id: @blob['ID'])
    end
end
