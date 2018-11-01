require 'rails_helper'

RSpec.describe MaintenanceApi do
  include_context 'MaintenanceApi::Client'

  each_currency :depositable? do
    it 'creates new unused wallets' do
      addr = ac.generate_key[:address]
      expect do
        MaintenanceApi::Client.create_wallet(addr, currency)
      end.to change { Wallet.count }.by(1)
      expect(Wallet.last.address).to eq addr
      expect(Wallet.last.currency).to eq currency
    end
  end

  it 'returns the number of unused wallets' do
    ApplicationCurrency.select(&:depositable?).each { |ac| create(:wallet, currency: ac.code) }
    counts = MaintenanceApi::Client.unused_wallets_count
    ApplicationCurrency.select(&:depositable?).each { |ac| expect(counts[ac.code]).to eq 1 }
  end
end
