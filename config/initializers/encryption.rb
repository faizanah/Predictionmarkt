if Rails.env.payment? && ENV['PMKT_ENCRYPTION']
  ApplicationCurrency.initialize_encryption
  ApplicationCurrency.validate_encryption
end
