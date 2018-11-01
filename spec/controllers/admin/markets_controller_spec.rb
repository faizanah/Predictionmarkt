require 'rails_helper'

RSpec.describe Admin::MarketsController, type: :controller do

  let(:market) { create(:market) }
  let(:admin_user) { create(:admin_user) }
  let(:user) { create(:user) }

  before do
    MarketCategory.seed
    sign_in(user)
    sign_in(admin_user, scope: :admin_user)
  end

  context 'basic market operations' do
    it "shows the index" do
      get 'index'
      expect(response).to be_successful
    end

    it "edits the market" do
      get 'edit', params: { id: market }
      expect(response).to be_successful
    end
  end
end
