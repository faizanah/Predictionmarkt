module MaintenanceApi
  class WithdrawalOrders < Base
    resource :withdrawal_orders do
      desc 'List of withdrawal orders requiring signing'
      get do
        present WithdrawalOrder.pending
      end

      desc 'Receive signed transactions for the withdrawal orders'
      params do
        requires :withdrawal_order, type: Hash do
          requires :all, using: WithdrawalOrder::EntityParams.documentation
        end
      end
      put ':id' do
        order = WithdrawalOrder.pending.find(params[:id])
        order.receive_signed_transaction(declared(params)[:withdrawal_order])
      end
    end
  end
end
