class FakeCoinmarketcap < FakeService
  get '/v1/ticker/' do
    json_response '10.json'
  end

  get '/currencies/:currency/historical-data/' do
    json_response "history/#{params['currency']}.json"
  end
end
