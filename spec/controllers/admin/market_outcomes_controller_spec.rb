require 'rails_helper'

RSpec.describe Admin::MarketOutcomesController, type: :controller do
  let(:market_outcome) { create(:market_outcome) }
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }

  before do
    sign_in(user)
    sign_in(admin_user, scope: :admin_user)
  end

  context 'basic market outcome operations' do
    it "edits the market outcome" do
      get 'edit', params: { market_id: market_outcome.market, id: market_outcome }
      expect(response).to be_successful
    end
  end
end
