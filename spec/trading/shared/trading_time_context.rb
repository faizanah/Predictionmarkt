RSpec.shared_context 'trading time context' do
  include ActiveSupport::Testing::TimeHelpers

  let(:first_hour) { 1.day.ago.noon }
  let(:second_hour) { first_hour + 1.hour }
  let(:third_hour) { first_hour + 2.hours }

  def seed_trades_prev_day(markets)
    travel_to(first_hour) { seed_trades(Array.wrap(markets)) }
    travel_to(second_hour) { ContractTradeStat.aggregate_hours }
    ContractTradeStat.aggregate_days
  end

  def seed_trades(markets)
    markets.each do |market|
      market.reload.contracts.each do |contract|
        2.times { TradeGenerator.new(contract).perform }
      end
    end
    ContractTradeStat.aggregate_hours
  end
end
