require 'rails_helper'

RSpec.describe CurrencyEncryption do
  each_currency :crypto? do
    it 'initializes and validates encryption' do
      expect(SymmetricEncryption.decrypt(SymmetricEncryption.encrypt('test'))).to eq 'test'
      expect(ApplicationCurrency.validate_encryption).to eq true
    end

    it 'provides a private key' do
      creds = WalletCredentials.generate(currency)
      ac.signing_key(creds.address)
    end
  end
end
