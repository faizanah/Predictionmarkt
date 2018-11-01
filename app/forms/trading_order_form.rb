class TradingOrderForm < MarketOrderForm
  include TradingOrderFormMixins::Slider
  include TradingOrderFormMixins::Preview
  # URI params
  attr_accessor :type
  attr_accessor :market_outcome_id

  # Form attributes
  attr_accessor :money
  attr_accessor :quantity
  attr_accessor :limit_price
  attr_accessor :stop_price
  attr_accessor :time_in_force, :expires_at

  attr_accessor :order

  validates_presence_of :market, :market_outcome, :contract

  after_initialize :set_defaults

  def set_defaults
    self.money ||= 0
    self.quantity ||= 0
    self.limit_price ||= 0
  end

  # TODO: restrict saving twice / nonidempotency
  def persist!
    init_order
    result = @order.save
    result
  end

  # used in persist! and preview!
  def init_order
    new_order
    init_market_order if type == 'market'
    init_limit_order if type == 'limit'
    init_stop_order if type == 'stop'
    @order.assign_defaults # Need for the preview when it's not saved
  end

  def new_order
    @order = TradingOrder.new(user: user,
                              state: 'maker',
                              order_type: "#{type}_order",
                              operation: ask? ? 'ask' : 'bid',
                              contract: contract)
  end

  def init_market_order
    @order.requested_amount = money if bid?
    @order.requested_quantity = quantity if ask?
    @order.time_in_force = 'ioc' # immediate or cancel
  end

  def init_limit_order
    @order.requested_quantity = quantity
    @order.limit_price = limit_price.to_d
    @order.time_in_force = time_in_force
    @order.expires_at = expires_at if @order.gtt? # good till time
  end

  def init_stop_order
    @order.requested_quantity = quantity
    @order.limit_price = limit_price
    @order.stop_price = stop_price
    @order.time_in_force = 'ioc' # good till cancelled
  end

  #
  # Helpers
  #

  def min_price=(p)
    raise "not a bid order" unless ask?
    self.limit_price = p
  end

  def max_price=(p)
    raise "not an ask order" unless bid?
    self.limit_price = p
  end

  #
  # Validations
  #

  def shares_balance
    user.shares(contract)
  end

  def disabled?
    return true unless user
    return true if bid? && money_balance.zero?
    return true if ask? && user.shares(contract).zero?
    false
  end

  #
  # Helper attributes
  #

  def market_outcome
    return nil unless market_outcome_id
    @market_outcome ||= MarketOutcome.findy(market_outcome_id)
  end

  def market
    market_outcome&.market
  end

  def contract
    return nil unless market_outcome
    @contract ||= market_outcome.contracts.active.where(currency: currency).first
  end

  #
  # Params validation logic
  #

  def time_in_force_options
    { 'Good till Cancelled': :gtc,
      'Good till Time': :gtt,
      'Immediate or Cancel': :ioc }
  end

  def valid_uri_params?
    return false unless contract
    super
  end

  def allowed_outcome_params
    { type: %w[market limit stop],
      operation: %w[buy sell],
      currency: market_outcome.contracts.map(&:currency) }.with_indifferent_access
  end

  def self.uri_params_keys
    %w[market_outcome_id currency type operation]
  end

  def self.form_attributes_keys
    uri_params_keys + %w[money quantity limit_price stop_price time_in_force expires_at]
  end
end
