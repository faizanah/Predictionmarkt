RSpec.shared_context 'external currency services' do
  include_context 'MaintenanceApi::Client'

  before do
    stub_request(:any, Regexp.new("https://api.etherscan.io/.*")).to_rack(FakeEtherscan)
    stub_request(:any, Regexp.new("https://bitcoinfees.earn.com/.*")).to_rack(FakeBitcoinfees)
    # Localhost is needed for withdrawal order api calls
    WebMock.disable_net_connect!(allow: 'https://blockchain.info', allow_localhost: true)
  end
end
