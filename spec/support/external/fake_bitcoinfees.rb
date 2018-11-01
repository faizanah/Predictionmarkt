class FakeBitcoinfees < FakeService
  get '/api/v1/fees/recommended' do
    json_response 'recommended.json'
  end
end
