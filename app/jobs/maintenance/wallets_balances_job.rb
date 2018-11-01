module Maintenance
  class WalletsBalancesJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      Wallet.update_balances
    end
  end
end
