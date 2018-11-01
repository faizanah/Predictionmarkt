require 'rails_helper'

RSpec.describe Services::Etherscanio do
  # include_context 'external currency services'

  before do
    WebMock.disable_net_connect!(allow: 'https://api.etherscan.io')
  end

  context 'Balance checking / updating' do
    let(:user) { create(:user, :with_wallets) }

    it 'returns normalized wallet balances' do
      wallet = user.wallets.receiving.eth.last!
      response = [:ok, [{ account: wallet.address, balance: "0.1231" }]]
      expected_response = [{ address: wallet.address, balance: "0.1231" }]
      allow(Etherscan::Account).to receive(:balancemulti).and_return(response)
      expect(described_class.balances(Wallet.receiving.eth)).to eq expected_response
    end

    it 'returns gas price' do
      expect(described_class.gas_price).to be_between(100_000_000, 10_000_000_000_000)
    end
  end
end
