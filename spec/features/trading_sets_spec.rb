require 'feature_helper'

describe 'Trading Sets' do
  include ActiveSupport::Testing::TimeHelpers

  include_context 'trading set context'

  let(:currency) { 'eth' }
  let(:other_currency) { 'pmt' }

  context 'for a user with no money and no shares' do
    before do
      login_as(user_with_no_money)
      visit full_trading_set_path(market, currency: currency)
    end

    it 'shows error to a user with no money when buying' do
      snap('trading-sets', 'new-buy-no-funds')
      expect(page).to have_content('No funds')

      switch_to_operation('sell')
      expect(page).to have_content('Not enough shares')
      snap('trading-sets', 'new-buy-no-shares')
    end

    it 'changes the currency' do
      market.reload.generate_contracts
      click_on('Currency: ETH')
      snap('trading-sets', 'currency-caption')
      within('.currency-menu__list') { click_on other_currency }
      expect(page).to have_content("Currency: #{other_currency}".upcase)
      snap('trading-sets', 'currency-switched')
    end
  end

  context 'for a user with money and shares' do
    let(:user) { user_with_money_and_shares }

    before do
      login_as(user)
      visit full_trading_set_path(market, currency: currency)
    end

    context 'selling trading sets' do
      before do
        switch_to_operation('sell')
      end

      it 'adds an order using text input' do
        fill_in "Number of bundles", with: max_sets
        snap('trading-sets', 'sell-fill')
        submit_form
        expect(page).to have_content('Your order is executed')
        expect(page).to have_content(max_sets)
        snap('trading-sets', 'sell-done')
        validate_last_trx(total_change: -max_sets)
      end

      it 'adds an order using slider' do
        snap('trading-sets', 'sell-start')
        slider_select(:quantity, 300)
        snap('trading-sets', 'sell-slider')
        submit_form
        validate_last_trx(reason: 'liquidation')
        snap('trading-sets', 'sell-slider-done')
      end
    end

    context 'buying trading sets' do
      before do
        switch_to_operation('buy')
      end

      it 'adds an order using text input' do
        fill_in "Amount, in #{currency.upcase}", with: Money.new(max_money, currency).to_s
        snap('trading-sets', 'buy-filled')
        submit_form
        snap('trading-sets', 'buy-done')
        validate_last_trx(total_change: max_sets)
        expect(page).to have_content('Your order is executed')
      end

      it 'adds an order using slider' do
        snap('trading-sets', 'buy-start')
        slider_select(:money, 300)
        snap('trading-sets', 'buy-slider')
        submit_form
        validate_last_trx(reason: 'emission')
        snap('trading-sets', 'buy-slider-done')
      end
    end
  end

  def switch_to_operation(op = 'sell')
    find(".market-operation-#{op}").click
    expect(page).to have_selector("#test_form_operation_#{op}", visible: false)
  end

  def validate_last_trx(args = {})
    trx = user.market_shares_transactions.last
    args.each do |k, v|
      attr_value = trx.send(k)
      expect(attr_value).to eq(v), "expected trx's #{k} to be #{v.inspect} but got #{attr_value.inspect}"
    end
  end

  def slider_select(attr, value)
    within("#trading_set_form_#{attr}_slider") do
      find('.mdc-slider__thumb-container').drag_by(value, 0)
    end
  end
end
