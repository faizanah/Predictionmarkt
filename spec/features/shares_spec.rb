require 'feature_helper'

describe 'Shares' do
  one_currency do |currency|
    include_context 'trading context'

    context 'for users with no shares' do
      let(:user) { create :user }

      before { login_as(user) }

      it "shows no funds" do
        visit my_shares_path
        expect(page).to have_content(/Shares/i)
        snap('shares', 'no-shares')
      end
    end

    context 'for users with shares' do
      before { login_as(user_with_shares) }

      it "shows shares" do
        visit my_shares_path
        snap('shares', 'with-not-traded-shares')
        TradeGenerator.new(user_with_shares.spendable_shares.last.contract).perform
        visit my_shares_path
        snap('shares', 'with-traded-shares')
      end
    end
  end
end
