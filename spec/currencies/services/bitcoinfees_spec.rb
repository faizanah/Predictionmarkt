require 'rails_helper'

RSpec.describe Services::Bitcoinfees do
  # https://bitcoinfees.earn.com/api/v1/fees/recommended
  before do
    WebMock.disable_net_connect!(allow: 'https://bitcoinfees.earn.com')
  end

  # TODO: disable cache
  it 'checks bitcoin / eth fees' do
    fee = described_class.best_fee
    expect(fee.positive?).to eq true
  end
end
