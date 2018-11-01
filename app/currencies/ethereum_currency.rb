require 'eth'

class EthereumCurrency < ApplicationCurrency
  delegate :balances, to: 'Services::Etherscanio'
  include Transactions::Ethereum
  include Formatters::Ethereum

  def creds_to_key(creds)
    Eth::Key.new(priv: creds.decrypted_private_key)
  end

  def generate_key
    key = Eth::Key.new
    raise unless Eth::Utils.valid_address? key.address
    { address: key.address, private_key: key.private_hex, public_key: key.public_hex }
  end
end
