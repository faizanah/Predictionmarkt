module MaintenanceApi
  class Client
    CONFIG = MaintenanceApi::Base::CONFIG
    include HTTParty

    if Rails.env.payment?
      base_uri 'https://predictionmarkt.com/api/maintenance'
      headers 'Authorization' => "Bearer #{Rails.application.credentials.maintenance_api_key}"
    elsif Rails.env.development?
      base_uri 'http://localhost:4004/api/maintenance'
    end

    headers 'Content-Type' => 'application/json'
    format :json
    # debug_output $stdout

    def self.withdrawal_orders
      get('/withdrawal_orders').parsed_response.map do |o|
        OpenStruct.new(o)
      end
    end

    def self.update_withdrawal_order(order)
      body = { withdrawal_order: order.to_h }.to_json
      response = put("/withdrawal_orders/#{order.id}", body: body)
      raise(ApiException, response) unless response.success?
    end

    def self.create_wallet(address, currency)
      wallet = { state: 'unused', address: address, currency: currency }
      body = { wallet: wallet }.to_json
      response = post("/wallets", body: body)
      raise(ApiException, response) unless response.success?
      response
    end

    def self.unused_wallets_count
      response = get('/wallets/unused_count')
      raise(ApiException, response) unless response.success?
      response.parsed_response
    end
  end
end
