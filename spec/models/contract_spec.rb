require 'rails_helper'

RSpec.describe Contract, type: :model do
  each_currency do
    let(:contract) { create(:contract, currency: currency) }

    it 'has consistent fields' do
      expect(contract.tick).to be > 0
      expect(contract.tick).to be >= contract.min
      expect(contract.max).to be > contract.min
    end
  end
end
