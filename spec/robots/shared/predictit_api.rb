shared_context "predictit api" do # needs to start server in the background
  before do
    stub_request(:any, Regexp.new("https://www.predictit.org/.*")).to_rack(FakePredictit)
  end
end
