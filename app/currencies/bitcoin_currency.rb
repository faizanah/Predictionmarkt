require 'bitcoin'

class BitcoinCurrency < ApplicationCurrency
  include Transactions::Bitcoin
  include Formatters::Bitcoin

  delegate :balances, to: 'Services::Blockonomics'

  def creds_to_key(creds)
    Bitcoin::Key.new(creds.decrypted_private_key, creds.public_key)
  end

  def generate_key
    key = Bitcoin.generate_key
    address = Bitcoin.pubkey_to_address(key[1])
    { address: address, public_key: key[1], private_key: key[0] }
  end
end
