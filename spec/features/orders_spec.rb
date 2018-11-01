require 'feature_helper'

describe 'Orders' do
  one_currency do |currency|
    include_context 'trading context'

    context 'for users with no orders' do
      let(:user) { create :user }

      before { login_as(user) }

      it "shows no ordes" do
        visit my_trading_orders_path
        expect(page).to have_content(/Shares/i)
        snap('orders', 'no-orders')
      end
    end

    context 'for users with shares' do
      let(:u) { user_with_money_and_shares }

      before { login_as(u) }

      it "shows and cancels one order" do
        c = user_with_shares.spendable_shares.last.contract
        create(:trading_order, :limit_ask, contract: c, requested_quantity: 1, user: u)
        visit my_trading_orders_path
        snap('orders', 'one-bid-order')
        click_on 'Cancel'
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content("You do not have any")
      end

      it 'shows two orders' do
        c = user_with_shares.spendable_shares.last.contract
        create(:trading_order, :limit_bid, contract: c, requested_quantity: 1, user: u)
        create(:trading_order, :limit_bid, user: u, requested_quantity: 1)
        visit my_trading_orders_path
        snap('orders', 'bid-and-ask-orders')
      end
    end
  end
end
