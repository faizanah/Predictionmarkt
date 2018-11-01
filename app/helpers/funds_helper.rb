module FundsHelper
  # TODO: replace btc with something else?
  def currency_statement_button
    ac = current_user.preferred_ac
    trx = current_user.currency_transactions.last
    classes = trx ? '' : 'disabled'
    link_to 'Statement', statement_my_funds_path(ac.code), class: "btn-table-action #{classes}"
  end

  # TODO: optimize for speed, pass disabled state
  def withdraw_button(currency, args = {})
    return nil unless ApplicationCurrency.get(currency).config[:withdrawable]
    disabled = current_user.balance(currency).zero?
    classes = disabled ? 'disabled' : ''
    button_to 'Withdraw', withdraw_my_funds_path(currency, args), class: "btn-table-action #{classes}",
                                                                  disabled: disabled, method: 'get'
  end

  def deposit_button(currency, _args = {})
    wallet = deposit_wallet(currency)
    link_to 'Deposit', wallet.ac.address_ext(wallet.address),
            target: '_blank', class: "btn-table-action"
  end

  def transfer_info_button(transfer, _args = {})
    link_to 'Address', transfer.ac.address_ext(transfer.receiving_address),
            target: '_blank', class: "btn-table-action"
  end

  def deposit_wallet(currency)
    current_user.wallets.receiving.find { |w| w.currency == currency }
  end
end
