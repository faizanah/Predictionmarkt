module Services
  class Bitcoinfees
    include HTTParty
    headers 'Content-Type' => 'application/json'
    base_uri 'https://bitcoinfees.earn.com/api/v1/fees/'
    format :json
    # debug_output $stdout
    # https://bitcoinfees.earn.com/api

    # TODO: add caching
    def self.best_fee
      cache.fetch('bitcoinfees-best-bee') do
        response = get('/recommended')
        raise "bitcoinfees check error: #{response.message}" unless response.code == 200
        fee = (response.parsed_response['hourFee'] * 0.9).to_i
        raise "weird fee: #{fee}" unless fee.positive? && fee < 1000
        fee
      end
    end

    def self.cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new(expires_in: 30.minutes)
    end
  end
end
