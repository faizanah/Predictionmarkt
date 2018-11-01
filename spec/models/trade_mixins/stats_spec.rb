require 'rails_helper'

describe TradeMixins::Stats do
  it 'calculates moving average' do
    expect(Trade.weighted_average([[10, 1], [20, 1]])).to eq 15
    expect(Trade.weighted_average([[100, 2], [1000, 1]])).to eq 400
    expect(Trade.weighted_average([[100, 1], [1000, 2]])).to eq 700
  end
end
