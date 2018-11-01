shared_context "coinmarketcap api" do # needs to start server in the background
  before do
    stub_request(:any, Regexp.new("https://.*coinmarketcap.com/.*")).to_rack(FakeCoinmarketcap)
  end
end
