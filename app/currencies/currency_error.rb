module CurrencyError
  class NoFunds < StandardError; end
  class NoWallets < StandardError; end
  class ApiError < StandardError; end
end
