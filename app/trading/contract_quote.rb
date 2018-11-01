class ContractQuote
  include ContractQuoteMixins::Udf
  include ContractQuoteMixins::Today
  include ContractQuoteMixins::Latest
  include FormatterHelper
  include CurrencyFormatterHelper

  attr_accessor :contract

  def initialize(c)
    self.contract = c
  end

  def market_outcome
    contract.market_outcome
  end
end
