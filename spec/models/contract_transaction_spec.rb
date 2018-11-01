require 'rails_helper'

RSpec.describe ContractTransaction, type: :model do
  let!(:transaction) { create(:contract_transaction) }

  it_behaves_like 'a chainable transaction'
end
