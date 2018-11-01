class ApplicationApi < Grape::API
  prefix '/'
  # mount ClientApi::Base
  # mount MaintenanceApi::Base
  mount MaintenanceApi::WithdrawalOrders
  mount MaintenanceApi::Wallets
  mount ChartsApi::Udf
end
