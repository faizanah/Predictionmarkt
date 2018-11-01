def each_currency(filters = [], &block)
  ApplicationCurrency.each_with_code do |ac, currency|
    filters = Array.wrap(filters)
    next unless filters.all? { |f| ac.send(f) }

    # rubocop:disable RSpec/EmptyExampleGroup
    context "*#{currency}*" do
      let(:currency) { currency }
      let(:ac) { ApplicationCurrency.get(currency) }

      module_eval(&block)
    end
  end
end

def one_currency(&block)
  let(:currency) { 'eth' }
  let(:ac) { ApplicationCurrency.get(currency) }

  module_eval(&block)
end
