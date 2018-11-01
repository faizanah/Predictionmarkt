require 'rails_helper'

RSpec.describe Services::Blockonomics do
  before do
    WebMock.disable_net_connect!(allow: 'https://www.blockonomics.co')
  end

  it 'returns normalized wallet balances' do
    wallet = create(:wallet, :real, currency: 'btc')
    balance = described_class.balances([wallet]).first
    expect(balance[:address]).to eq wallet.address
    expect(balance[:balance]).to eq wallet.balance
  end

  it 'returns zero balance' do
    wallet1 = create(:wallet, currency: 'btc')
    wallet2 = create(:wallet, currency: 'btc')
    balances = described_class.balances([wallet1, wallet2])
    expect(balances.size).to eq 2
    balances.each { |b| expect(b[:balance]).to eq 0 }
  end
end
