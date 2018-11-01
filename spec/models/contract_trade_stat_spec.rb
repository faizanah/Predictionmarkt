require 'rails_helper'

RSpec.describe ContractTradeStat, type: :model do
  include_context 'trading time context'

  let(:contract) { create(:contract) }

  it 'does not aggregate stats from the current hour' do
    1.times { TradeGenerator.new(contract).perform }
    ContractTradeStat.aggregate_hours
    expect(ContractTradeStat.count).to eq 0
  end

  it 'aggregates hourly stats from the previous hour' do
    travel(-1.hour) { 1.times { TradeGenerator.new(contract).perform } }
    ContractTradeStat.aggregate_hours
    expect(ContractTradeStat.count).to eq 1
    expect(ContractTradeStat.first.mean_odds).to eq contract.trades.first.odds
  end

  it 'aggregates daily stats from the previous day' do
    travel_to(first_hour) { 1.times { TradeGenerator.new(contract).perform } }
    travel_to(second_hour) { ContractTradeStat.aggregate_hours }
    ContractTradeStat.aggregate_days
    expect(ContractTradeStat.daily.count).to eq 1
    expect(ContractTradeStat.daily.first.mean_odds).to eq contract.trades.first.odds
  end

  it 'returns nil for empty market outcome stats' do
    stats = ContractTradeStat.market_outcome_stats(contract.market_outcome, 1.day.ago, :daily)
    expect(stats).to eq nil
  end

  it 'aggregates hourly market stats from the previous hour' do
    travel(-1.hour) { 1.times { TradeGenerator.new(contract).perform } }
    ContractTradeStat.aggregate_hours
    stats = ContractTradeStat.market_outcome_stats(contract.market_outcome, 1.hour.ago, :hourly)
    expect(stats[:mean_odds]).to eq contract.trades.first.odds
  end

  it 'aggregates daily market stats from the previous day' do
    travel_to(first_hour) { 3.times { TradeGenerator.new(contract).perform } }
    travel_to(second_hour) { ContractTradeStat.aggregate_hours }
    ContractTradeStat.aggregate_days
    stats = ContractTradeStat.market_outcome_stats(contract.market_outcome, 1.day.ago, :daily)
    expect(stats[:mean_odds]).to be_positive
  end

  context 'charting' do
    it 'returns no_data when there are no stats' do
      %w[60 D].each do |interval|
        udf_history = ContractTradeStat.udf_history(contract, 1.day.ago, 1.hour.ago, interval)
        expect(udf_history.stats.size).to eq 0
      end
    end

    context 'with 2 hours of prev day data' do
      before do
        travel_to(first_hour) { 3.times { TradeGenerator.new(contract).perform } }
        travel_to(second_hour) { ContractTradeStat.aggregate_hours }

        travel_to(second_hour) { 3.times { TradeGenerator.new(contract).perform } }
        travel_to(third_hour) { ContractTradeStat.aggregate_hours }

        ContractTradeStat.aggregate_days
      end

      it 'returns data when there are historical events' do
        udf_history = ContractTradeStat.udf_history(contract, first_hour, second_hour, '60')
        expect(udf_history.stats.first.interval_at).to eq(first_hour.beginning_of_hour)
      end

      it 'returns 2 datapoints from 2 hours' do
        udf_history = ContractTradeStat.udf_history(contract, first_hour, third_hour, '60')
        expect(udf_history.stats.size).to eq 2
      end

      it 'returns daily data when there are historical events' do
        udf_history = ContractTradeStat.udf_history(contract, first_hour, Time.now, 'D')
        expect(udf_history.stats.size).to eq 1
      end

      it 'returns no daily events in a short interval' do
        udf_history = ContractTradeStat.udf_history(contract, first_hour, second_hour, 'D')
        expect(udf_history.stats.empty?).to be true
      end
    end
  end
end
