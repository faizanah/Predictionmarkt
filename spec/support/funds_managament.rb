def withdraw_funds(user, amount, currency)
  to_address = generate_address(currency)
  money = amount_to_money(amount, currency)
  CurrencyTransfer.create_withdrawal(user, money, to_address)
  money
end

def add_funds(user, amount, currency, chunks = 1)
  trx_args = { user: user, cause: user, reason: 'trading_set' }
  money = amount_to_money(amount, currency)
  trx_args[:currency] = money.currency.iso_code
  CurrencyTransaction.deposit!(money.fractional, trx_args)
  money
end

def add_wallets(user, amount, currency, chunks = 1)
  money = amount_to_money(amount, currency)
  chunks.times do |c|
    create(:wallet, currency: currency, amount: money / chunks, user: user)
  end
  money
end

# TODO: move everything to factories
def create_real_full_wallet(currency, user = nil, creds = true)
  currency = currency.to_s
  WalletCredentials.assigned.create!(full_wallet_creds(currency)) if creds
  create(:wallet,
         user: user,
         address: full_wallet_creds(currency)['address'],
         currency: currency, amount:
         full_wallet_money(currency))
end

def create_unused_wallets(n = 1)
  ApplicationCurrency.select(&:depositable?).each do |ac|
    n.times { create(:wallet, currency: ac.code) }
  end
end

# Support methods

def app_curr(currency)
  ApplicationCurrency.get(currency)
end

def full_wallet_creds(currency)
  full_wallet_config['creds'][currency.to_s]
end

def full_wallet_money(currency)
  Money.new(full_wallet_config['amounts'][currency.to_s], currency)
end

def full_wallet_config
  @full_wallet_config ||= Rails.application.config_for(:currencies)['real_full_wallets']
end

def amount_to_money(amount, currency)
  return amount if amount.is_a?(Money)
  Money.from_amount(amount, currency)
end

def generate_address(currency)
  app_curr(currency).generate_key[:address]
end

def raw_transaction_for(currency)
  tx_file = file_fixture("transactions/#{currency}.tx")
  app_curr(currency).payload_to_raw_tx(tx_file.read)
end
