module CurrencyWithdrawal
  # TODO: limit transactions to one source wallet for Ethereum
  # TODO: reject wallets with balance below their marginal fee / size of the transaction
  # TODO: make sure the balance of the residual wallets is checked
  # TODO: implement the wallet merging business logic
  # TODO: make sure the source wallets are selected in the right order
  # TODO: validate all the source balances and fees before signing the transaction
  CONFIG = Rails.application.config_for(:wallets).freeze

  # *** Step 1: Create withdrawal orders (prod) ***

  def create_withdrawal_orders
    CurrencyTransfer.requested_withdrawals(code).each do |withdrawal|
      from_wallets = select_wallets_for_withdrawal(withdrawal)
      raise CurrencyError::NoWallets if from_wallets.blank?
      withdrawal.withdrawal_orders.pending.create!(
        residual_wallet: wallets.unused.last,
        from_wallet_ids: from_wallets.map(&:id)
      )
    end
  end

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
  def select_wallets_for_withdrawal(withdrawal)
    logger.info { "Looking for wallets with amount: #{withdrawal.amount} for withdrawal-#{withdrawal.id}" }
    from_wallets = []
    spending = []
    wallets.full.sort_by(&:balance).reverse.each do |from_wallet|
      from_wallets << from_wallet
      spending = spending_details(from_wallets)
      wallets_debug(from_wallets, spending, "considering...")
      break if from_wallets.size >= config[:input_limit]
      break if spending.last >= withdrawal.amount
    end
    if spending.last >= withdrawal.amount
      logger.info { "found the wallets ^" }
      from_wallets
    else
      logger.info { "exhausted all the wallets" }
      nil
    end
  end

  # Returns an array [sum, fee, max_output] where
  # sum = total sum of the balance in all the wallets
  # fee = transaction fee
  # max_output = maximum amount of money transferable from the wallets
  def spending_details(from_wallets)
    b = from_wallets.sum(&:balance)
    f = tx_fee(from_wallets)
    [b, f, b - f]
  end

  def wallets_debug(wallets, spending, message)
    logger.info do
      "#{wallets.size} wallets; ids: #{wallets.map(&:id).join(',')};"\
      "balance: #{spending[0]}; fee: #{spending[1]}; left: #{spending.last}"\
      " | #{message}"
    end
  end

  def validate_balances(order); end

  # *** Step 2: Generate and sign transaction (payment) ***

  def sign_withdrawal_orders
    MaintenanceApi::Client.withdrawal_orders.map do |order|
      order.raw_transaction = generate_withdrawal_transaction(order)
      update_signed_order(order)
      order
    end
  end

  def update_signed_order(order)
    order.state = 'signed'
    MaintenanceApi::Client.update_withdrawal_order(order)
  end

  # *** Step 3: Send transactions ***

  def send_signed_transactions
    WithdrawalOrder.signed.each do |order|
      next unless order.currency == code
      begin
        order.sent! if pushtx(order)
      rescue StandardError => e
        raise CurrencyError::ApiError, e.message
      end
    end
  end
end
