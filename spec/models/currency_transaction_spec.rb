require 'rails_helper'

RSpec.describe CurrencyTransaction, type: :model do
  let(:user) { create(:user) }
  let(:transaction) { create(:currency_transaction) }

  it_behaves_like 'a chainable transaction'
end
