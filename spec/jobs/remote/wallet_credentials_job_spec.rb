require 'rails_helper'

RSpec.describe Remote::WalletCredentialsJob do
  include_context 'MaintenanceApi::Client'

  it 'creates wallets' do
    described_class.perform_now

    ApplicationCurrency.select(&:depositable?).each do |ac|
      expect(Wallet.unused.where(currency: ac.code).count).to eq Wallet.config[:unused_batch]
    end
  end
end
