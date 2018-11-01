class WithdrawForm < ApplicationForm
  include CurrencyContainer
  include AuthenticatedForm

  attr_accessor :currency, :address
  attr_accessor :money, :balance

  validates_presence_of :currency
  validates :money, numericality: { greater_than: 0 }, allow_blank: true
  validates :money_max, numericality: { greater_than: 0 }

  validates_presence_of :address, on: :save
  validate :check_balance, unless: proc { |f| f.errors.any? }, on: :save
  validate :check_address, unless: proc { |f| f.errors.any? }, on: :save

  validates_corruptible :currency, :user, :money_max

  after_initialize :set_defaults

  def set_defaults
    return unless user # TODO: remove?
    self.money ||= money_max
  end

  def persist!
    to_withdraw = Money.new(money, currency)
    CurrencyTransfer.create_withdrawal(user, to_withdraw, address)
  end

  def check_balance
    return if CurrencyTransaction.withdrawable?(money, user: user, currency: currency, cause: user)
    errors.add(:money, 'Exceeds total balance')
  end

  def check_address
    errors.add(:address) unless ac.valid_address?(address)
  end

  def last_trx
    user.last_transaction(currency)
  end

  # Options for slider

  def money_max
    return 0 unless currency
    user.balance(currency).fractional
  end

  def text_money_step
    Money.new(1, currency).amount
  end

  def text_money
    Money.new(money, currency).amount
  end
end
