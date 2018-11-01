require 'feature_helper'

describe 'Blog Posts screenshots' do
  include_context 'trading context'

  let(:currency) { 'eth' }

  context 'How to trade on prediction markets' do
    let(:default_amount) { Money.from_amount(0.05, 'eth').fractional }
    let(:user_with_money) { create(:user, :with_all_currencies, default_amount: default_amount) }

    let(:market) do
      create(:market, title: 'Will SapienNetwork token (SPN) cost twice the ICO price at the end of 2018?',
                      cover_name: 'sapien',
                      market_type: 'binary')
    end

    let(:outcome_yes) { market.market_outcomes.yes.take }
    let(:outcome_no) { market.market_outcomes.no.take }
    let(:contract_yes) { outcome_yes.contracts.eth.take }
    let(:contract_no) { outcome_no.contracts.eth.take }

    before do
      login_as(user_with_money.reload)
      create(:trading_order, :limit_bid, odds: 0.6, requested_quantity: 50, contract: contract_no)
      create(:trading_order, :limit_ask, odds: 0.7, requested_quantity: 50, contract: contract_no)

      create(:trading_order, :limit_bid, odds: 0.3, requested_quantity: 50, contract: contract_yes)
      create(:trading_order, :limit_ask, odds: 0.4, requested_quantity: 50, contract: contract_yes)
    end

    # rubocop:disable RSpec/ExampleLength
    it "browses markets" do
      visit market_path(market)
      blog_snap(2, 'pmkt-sapien-network-token-odds', '800')
      visit new_market_outcome_trading_order_path(outcome_no, currency: currency)
      fill_in "Amount, in #{currency.upcase}", with: '0.0035'
      wait_for_preview
      blog_snap(2, 'pmkt-sapien-network-token-trade-no', '950')
      submit_form
      blog_snap(2, 'pmkt-sapien-network-token-order-complete', '800')
    end

    def wait_for_preview
      page.execute_script("$('input').trigger('change');")
      expect(page).to have_content('Order preview')
    end
  end
end
