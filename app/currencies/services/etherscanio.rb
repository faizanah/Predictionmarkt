require 'etherscan'
require 'eth'
require 'rlp'

# https://github.com/wuminzhe/etherscan/blob/master/lib/etherscan/api.rb
# TODO: add timeouts to this thing
module Services
  class Etherscanio

    if Rails.env.production? || Rails.env.payment?
      Etherscan.api_key = Rails.application.credentials.etherscan_api_key
    else
      Etherscan.api_key = Rails.application.config_for('creds-test')['etherscan_api_key']
    end

    Etherscan.chain = :mainnet
    Etherscan.logger = Rails.logger
    Etherscan::Call::CHAINS[:mainnet] = 'https://api.etherscan.io/api?'

    def self.balances(wallets)
      addresses = wallets.map(&:address)
      result = Etherscan::Account.balancemulti(addresses, 'latest')
      raise "eth balance check error: #{result}" unless result.first == :ok
      result[1].map(&:symbolize_keys).map do |r|
        { address: r[:account], balance: r[:balance] }
      end
    end

    def self.gas_price
      cache.fetch('etherscanio-gas-price') do
        result = Etherscan::Proxy.eth_gas_price
        raise "eth gas price check error: #{result}" unless result.first == :ok
        hex_price = result[1]
        big_endian_price = Eth::Utils.hex_to_bin(hex_price)
        RLP.big_endian_to_int(big_endian_price)
      end
    end

    # TODO
    def self.estimate_gas(to, value, gas); end

    def self.pushtx(txhex)
      result = Etherscan::Proxy.eth_send_raw_transaction(txhex)
      raise "eth transaction push failed: #{result}" unless result.first == :ok
      result[1]
    end

    def self.cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new(expires_in: 2.minutes)
    end
  end
end
