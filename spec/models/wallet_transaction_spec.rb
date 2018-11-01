require 'rails_helper'

RSpec.describe WalletTransaction, type: :model do
  each_currency :depositable? do
    let(:transaction) { create(:wallet_transaction, currency: currency) }

    it_behaves_like 'a chainable transaction'
  end
end
