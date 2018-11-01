require 'rails_helper'

RSpec.describe MaintenanceApi do
  include_context 'MaintenanceApi::Client'

  each_currency :withdrawable? do
    let!(:withdraw_amount) { 100 }
    let!(:order) { create(:withdrawal_order, withdraw_amount: withdraw_amount, currency: currency) }

    it 'receives withdrawal orders' do
      fetched_orders = MaintenanceApi::Client.withdrawal_orders
      expect(fetched_orders.size).to eq 1
      expect(fetched_orders.last.currency).to eq order.currency
      expect(fetched_orders.last.amount).to eq order.amount
    end

    it 'requires valid state attribute' do
      o = MaintenanceApi::Client.withdrawal_orders.last
      o.state = 'test'
      expect do
        MaintenanceApi::Client.update_withdrawal_order(o)
      end.to raise_error(ApiException)
    end

    it 'updates the state' do
      o = MaintenanceApi::Client.withdrawal_orders.last
      o.state = 'signed'
      o.raw_transaction = '0x00000123'
      MaintenanceApi::Client.update_withdrawal_order(o)
      expect(MaintenanceApi::Client.withdrawal_orders.size).to eq 0
    end
  end
end
