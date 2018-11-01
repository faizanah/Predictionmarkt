class FakePredictit < FakeService
  get '/api/marketdata/all' do
    json_response 'all.json'
  end

  get '/api/marketdata/group/:group_id' do
    json_response 'all.json'
  end
end
