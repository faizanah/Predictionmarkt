module CurrencyFormatting
  include ActionView::Helpers::TagHelper
  include FormatterHelper
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
  end

  def caption
    Money::Currency.find(code).name
  end

  def address_ext(address)
    return nil unless config[:external]
    format(config[:external]['address'], address: address)
  end
end
