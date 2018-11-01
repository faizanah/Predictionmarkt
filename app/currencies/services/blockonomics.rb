module Services
  class Blockonomics
    include HTTParty

    bearer = if Rails.env.production? || Rails.env.payment?
               Rails.application.credentials.blockonomics_api_key
             else
               Rails.application.config_for('creds-test')['blockonomics_api_key']
             end

    headers 'Authorization' => "Bearer #{bearer}"
    headers 'Content-Type' => 'application/json'
    base_uri 'https://www.blockonomics.co/api/'
    format :json
    debug_output $stdout
    # https://www.blockonomics.co/views/api.html#limits
    # You can query max 50 addresses at a time. 2 requests / min

    def self.balances(wallets)
      addresses = wallets.map(&:address).join(' ')
      response = post('/balance', body: { addr: addresses }.to_json)
      raise "btc balance check error: #{response.message}" unless response.code == 200
      response.parsed_response['response'].map(&:symbolize_keys).map do |r|
        { address: r[:addr], balance: r[:confirmed] }
      end
    end
  end
end
