module MaintenanceApi
  class Wallets < Base
    resource :wallets do
      desc 'Create a new wallet'
      params do
        requires :wallet, type: Hash do
          requires :all, using: Wallet::EntityParams.documentation
        end
      end
      post do
        wallet = Wallet.create!(declared(params)[:wallet])
        present wallet
      end

      get 'unused_count' do
        reply = {}
        ApplicationCurrency.select(&:depositable?).each do |ac|
          reply[ac.code] = Wallet.unused.where(currency: ac.code).count
        end
        reply
      end
    end
  end
end
