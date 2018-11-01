require 'feature_helper'

describe 'Trading Orders' do
  include ActiveSupport::Testing::TimeHelpers

  include_context 'trading context'

  let(:currency) { 'eth' }
  let(:other_currency) { 'pmt' }
  let(:market) { contract.market }
  let(:market_outcome) { contract.market_outcome }

  before do
    1.times { TradeGenerator.new(contract).perform }
  end

  context 'for a user with no money and no shares' do
    before do
      login_as(user_with_no_money)
      visit new_market_outcome_trading_order_path(market_outcome)
    end

    it 'shows error to a user with no money when buying' do
      snap('trading-orders', 'new-buy-no-funds')
      expect(page).to have_content('No funds')

      switch_to_operation('sell')
      expect(page).to have_content('No shares')
      snap('trading-orders', 'new-buy-no-shares')
    end

    it 'changes the currency' do
      market.reload.generate_contracts
      click_on('Currency: ETH')
      snap('trading-orders', 'currency-caption')
      within('.currency-menu__list') { click_on other_currency }
      expect(page).to have_content("Currency: #{other_currency}".upcase)
      snap('trading-orders', 'currency-switched')
    end
  end

  context 'for a user with money and shares' do
    let(:user) { user_with_money_and_shares }

    before do
      login_as(user)
      visit new_market_outcome_trading_order_path(market_outcome, currency: currency)
    end

    it 'executes empty market buy' do
      snap('trading-orders', 'new-buy-funds')
      fill_in "Amount, in #{currency.upcase}", with: Money.new(bid_money, currency).to_s
      snap('trading-orders', 'new-buy-funds-filled')
      submit_form
      expect(page).to have_content('closed immediately')
      snap('trading-orders', 'new-buy-funds-bought-none')
    end

    context 'selling shares, market order' do
      before do
        switch_to_operation('sell')
      end

      it 'executes empty market sell using text input' do
        snap('trading-orders', 'new-sell-shares')
        fill_in "Number of shares", with: ask_quantity
        snap('trading-orders', 'new-sell_shares-filled')
        submit_form
        expect(page).to have_content('closed immediately')
        snap('trading-orders', 'new-sell-shares-sold-none')
        expect(page).to have_content("0 / #{ask_quantity}")
      end

      it 'executes empty market sell using slider' do
        find('.mdc-slider__thumb-container').drag_by(100, 0)
        snap('trading-orders', 'new-sell_shares-slider')
        submit_form
        snap('trading-orders', 'new-sell-shares-sold-some')
        expect(page).not_to have_content(ask_quantity)
        expect(user.trading_orders.last.requested_quantity).to be > 0
      end
    end

    context 'selling shares, limit order' do
      before do
        switch_to_operation('sell')
        switch_to_order_type('limit')
      end

      it 'adds an order using text input' do
        snap('trading-orders', 'sell-limit-start')
        fill_in "Price per share, in #{currency.upcase}", with: Money.new(bid_price, currency).to_s
        fill_in "Number of shares", with: bid_quantity
        snap('trading-orders', 'sell-limit-fill')
        submit_form
        snap('trading-orders', 'sell-limit-sent')
        validate_last_order(requested_quantity: bid_quantity, limit_price: bid_price)
      end

      it 'adds an order using slider' do
        slider_select(:limit_price, 200)
        slider_select(:quantity, 300)
        snap('trading-orders', 'sell-limit-slider')
        submit_form
        snap('trading-orders', 'sell-limit-slider-sent')
        validate_last_order(state: 'maker')
      end
    end

    context 'buying shares, limit order' do
      before do
        switch_to_operation('buy')
        switch_to_order_type('limit')
      end

      it 'adds an order using text input' do
        snap('trading-orders', 'buy-limit-start')
        fill_in "Price per share, in #{currency.upcase}", with: Money.new(ask_price, currency).to_s
        fill_in "Number of shares", with: ask_quantity
        snap('trading-orders', 'buy-limit-fill')
        submit_form
        snap('trading-orders', 'buy-limit-sent')
        validate_last_order(requested_quantity: ask_quantity, limit_price: ask_price)
      end

      it 'adds an order using slider' do
        slider_select(:limit_price, 200)
        slider_select(:quantity, 300)
        snap('trading-orders', 'buy-limit-slider')
        submit_form
        snap('trading-orders', 'buy-limit-slider-sent')
        validate_last_order(state: 'maker')
      end
    end
  end

  def switch_to_operation(op = 'sell')
    find(".market-operation-#{op}").click
    expect(page).to have_selector("#test_form_operation_#{op}", visible: false)
  end

  def switch_to_order_type(ot = 'limit')
    find(".order-type-#{ot}").click
    expect(page).to have_selector("#test_form_type_#{ot}", visible: false)
  end

  def validate_last_order(args = {})
    order = user.trading_orders.last
    args.each do |k, v|
      attr_value = order.send(k)
      expect(attr_value).to eq(v), "expected order's #{k} to be #{v.inspect} but got #{attr_value.inspect}"
    end
  end

  def slider_select(attr, value)
    within("#trading_order_form_#{attr}_slider") do
      find('.mdc-slider__thumb-container').drag_by(value, 0)
    end
  end
end
