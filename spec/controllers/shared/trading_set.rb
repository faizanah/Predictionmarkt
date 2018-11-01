shared_examples "rendering all trading set operations1" do
  it 'allows all trading sets operations for an active market' do
    market = create(:market, state: 'active')
    each_trading_set_param_combo(market: market) do |set_args|
      get 'new', params: { market_id: market }.merge(set_args)
      expect(response).to be_successful
    end
  end
end
