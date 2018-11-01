require 'rails_helper'

RSpec.describe Trade, type: :model do
  one_currency do
    include_context 'trading context'

    it 'closes both trading order' do
      trade = create(:trade)
      expect(trade.bo.state).to eq 'closed'
      expect(trade.ao.state).to eq 'closed'
    end
  end
end
