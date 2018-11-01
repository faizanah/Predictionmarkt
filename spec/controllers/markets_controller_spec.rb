require 'rails_helper'

RSpec.describe MarketsController, type: :controller do
  context 'markets listing' do
    let(:market) { create(:market) }

    before do
      MarketCategory.seed
    end

    context 'for authenticated user' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it "shows the index" do
        get 'index'
        expect(response).to be_successful
      end

      it "shows the market" do
        get 'show', params: { id: market }
        expect(response).to be_successful
      end
    end

    context 'for un-authenticated user' do
      it "shows the index" do
        get 'index'
        expect(response).to be_successful
      end

      it "shows the market" do
        get 'show', params: { id: market }
        expect(response).to be_successful
      end
    end
  end
end
