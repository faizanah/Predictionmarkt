class TradingSetForm < MarketOrderForm
  # TODO: validation, tests
  # URI params
  attr_accessor :market

  # Form attributes
  attr_accessor :quantity, :money

  attr_accessor :market_shares_trx

  validates_presence_of :market
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :money, numericality: { greater_than_or_equal_to: 0 }

  validate :validate_trx, if: proc { |f| f.errors.empty? }
  after_initialize :assign_defaults

  def trx_params
    { cause: user, market: market, currency: currency }.merge(reason: trx_reason)
  end

  def trx_reason
    bid? ? 'emission' : 'liquidation'
  end

  def persist!
    @market_shares_trx = MarketSharesTransaction.deposit!(deposit_quantity, trx_params) if bid?
    @market_shares_trx ||= MarketSharesTransaction.withdraw!(quantity, trx_params)
    true
  end

  # Options for slider

  def money_max
    user.balance(currency).fractional
  end

  def money_step
    market.settle_price(currency)
  end

  def text_money
    Money.new(money, currency).amount
  end

  def text_money_step
    Money.new(market.settle_price(currency), currency).amount
  end

  def text_quantity
    quantity.to_i
  end

  def quantity_max
    user&.sets_balance(market, currency)
  end

  #
  # Params validation logic
  #

  def allowed_outcome_params
    { operation: %w[buy sell],
      currency: market.available_currencies }.with_indifferent_access
  end

  def self.uri_params_keys
    %w[currency operation]
  end

  def self.form_attributes_keys
    uri_params_keys + %w[quantity money]
  end

  def sets_balance
    user.sets_balance(market, currency)
  end

  def disabled?
    return true unless user
    return true if bid? && money_balance.zero?
    return true if ask? && sets_balance.zero?
    false
  end

  private

    def validate_trx
      return if bid? && MarketSharesTransaction.depositable?(deposit_quantity, trx_params)
      return if ask? && MarketSharesTransaction.withdrawable?(quantity, trx_params)
      errors.add(:base, "can't perform transaction")
    end

    def assign_defaults
      self.money ||= 0
      self.quantity ||= 0
    end

    # only used to calculate shares to deposit from the money spent
    # TODO: maybe validate money properly for step / tick
    def deposit_quantity
      money.to_d.divmod(market.settle_price(currency)).first
    end
end
