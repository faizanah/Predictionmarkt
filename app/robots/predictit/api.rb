# Kind of a janky api that they provide, but you can find more here:
# https://predictit.freshdesk.com/support/solutions/articles/12000001878-does-predictit-make-market-data-available-via-an-api-

module Predictit
  class Api
    include HTTParty

    headers 'Content-Type' => 'application/json'
    base_uri 'https://www.predictit.org/api/marketdata/'
    format :json
    # debug_output $stdout

    def self.markets
      cache.fetch('all-markets') { get("/all")['Markets'] }
    end

    def self.market_from_raw_id(raw_id)
      markets.select { |m| m['ID'] == raw_id }.first
    end

    def self.market(market_id)
      get("/ticker/#{market_id}")
    end

    def self.contract(contract_id)
      market(contract_id)["Contracts"].select do |c|
        c["TickerSymbol"] == contract_id
      end.first
    end

    # list of groups and categories
    # https://www.npmjs.com/package/predict-it
    def self.group(group_id)
      get("/group/#{group_id}")['Markets']
    end

    def self.category(category_id)
      get("/category/#{category_id}")['Markets']
    end

    def self.cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new(expires_in: 30.minutes)
    end
  end
end
