require 'rails_helper'

RSpec.describe PredictitRobot do
  include ActiveSupport::Testing::TimeHelpers
  include_context 'predictit api'

  let(:api) { Predictit::Api }
  let(:crawler) { Predictit::Crawler.new }
  let(:robot) { PredictitRobot.new }

  it "returns specific market from raw id" do
    expect(api.market_from_raw_id(3952)['ID']).to eq 3952
  end

  # TODO: proper tests

  it 'ingests both long-term and short-term markets' do
    travel_to Time.parse('2017-12-15') do
      robot.ingest_markets
      expect(Market.count).to eq 16
    end
  end

  it 'ingests only long-term markets' do
    travel_to Time.parse('2017-10-15') do
      robot.ingest_markets
      expect(Market.count).to eq 13
    end
  end
end
