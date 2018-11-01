class MarketOrderForm < ApplicationForm
  # This form is initialized with:
  # 1) URI params
  # 2) Form attributes
  # 3) user

  include CurrencyContainer
  include AuthenticatedForm

  # URI params
  attr_accessor :currency, :operation

  validate :validate_params

  def uri_params
    self.class.uri_params_keys.map { |k| [k, send(k)] }.to_h.with_indifferent_access
  end

  def default_outcome_params
    allowed_outcome_params.each_with_object({}) do |(k, v), h|
      h[k] = send(k) || v.first
      h
    end.with_indifferent_access
  end

  def valid_uri_params?
    uri_params.all? do |k, v|
      if allowed_outcome_params.key?(k)
        allowed_outcome_params[k].include?(v)
      else # Ignore all the non-default request arguments
        true
      end
    end
  end

  def ask?
    operation == 'sell'
  end

  def bid?
    operation == 'buy'
  end

  def money_balance
    user.balance(currency).fractional
  end

  private

    def validate_params
      errors.add(:base, 'invalid uri parameters') unless valid_uri_params?
    end
end
