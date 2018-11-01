class FakeEtherscan < FakeService
  ACTIONS = %w[eth_gasPrice eth_sendRawTransaction].freeze
  get '/api' do
    unknown_request unless ACTIONS.include?(params['action']) && params['module'] == 'proxy'
    send(params['action'])
  end

  private

    # rubocop:disable Naming/MethodName
    def eth_gasPrice
      json_response 'gas_price.json'
    end

    def eth_sendRawTransaction
      content_type :json
      status 500
      '{"error": "FakeEtherscan"}'
    end
end
