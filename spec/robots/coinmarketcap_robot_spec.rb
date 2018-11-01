require 'rails_helper'

RSpec.describe CoinmarketcapRobot do
  include ActiveSupport::Testing::TimeHelpers
  include_context 'coinmarketcap api'

  let(:robot) { CoinmarketcapRobot.new }

  before do
    MarketCategory.seed
  end

  it 'ingests both long-term and short-term markets' do
    travel_to Time.parse('2018-04-02') do
      robot.ingest_markets
      btc_market = Market.where(ticker: 'BTC:20180630:DOWN').take
      expect(btc_market.market_spec.symbol).to eq 'BTC'
      expect(btc_market.market_spec.limit_price.positive?).to eq true
      expect(btc_market.market_spec.date.to_s(:db)).to eq '2018-06-30'
    end
  end
end
