module Remote
  class WalletCredentialsJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      MaintenanceApi::Client.unused_wallets_count.each do |currency, count|
        next if count > Wallet.config[:unused_min]
        Array.new(Wallet.config[:unused_batch]).each do
          creds = WalletCredentials.generate(currency)
          MaintenanceApi::Client.create_wallet(creds.address, currency)
        end
      end
    end
  end
end
