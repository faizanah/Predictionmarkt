class ApplicationCurrency
  # TODO: generate individual transactions with hashes for deposits, store them in the wallet transactions
  include CurrencyWithdrawal
  include CurrencyEncryption
  include CurrencyFormatting

  include CurrencyConfig
  extend CurrencyConfig
  extend CurrencyEnumeration

  def wallets
    Wallet.where(currency: code)
  end

  def wallet_balances(wallet_list)
    return [] if wallet_list.empty?
    balances(wallet_list).map do |b|
      OpenStruct.new(wallet: Wallet.receiving.where(address: b[:address]).last!,
                     money: Money.new(b[:balance], code))
    end
  end
end
