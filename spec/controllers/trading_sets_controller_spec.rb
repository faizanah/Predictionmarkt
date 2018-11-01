require 'rails_helper'

RSpec.describe TradingSetsController, type: :controller do
  shared_examples "rendering all trading set operations" do
    it 'redirects to the full trading set path' do
      market = create(:market, state: 'active')
      get 'new', params: { market_id: market }
      expect(response).to redirect_to(full_trading_set_path(market))
    end

    it 'allows all trading sets operations for an active market' do
      market = create(:market, state: 'active')
      each_trading_set_param_combo(market: market) do |set_args|
        get 'new', params: { market_id: market }.merge(set_args)
        expect(response).to be_successful
      end
    end

    it 'restricts trading sets operations for a closed market' do
      market = create(:market, state: 'closed')
      get 'new', params: { market_id: market }.merge(trading_set_args(market))
      expect(response).to redirect_to(market_path(market))
    end
  end

  context 'for authenticated user' do
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it_behaves_like 'rendering all trading set operations'

    it 'allows trading sets operations for an active market' do
      market = create(:market, state: 'active')
      each_trading_set_param_combo(market: market, user: user) do |set_args|
        get 'new', params: { market_id: market }.merge(set_args)
        expect(response).to be_successful
      end
    end
  end

  context 'for un-authenticated user' do
    it_behaves_like 'rendering all trading set operations'
  end

  each_currency :enabled? do
    include_context 'trading set context'

    context 'for users with no money' do
      before { sign_in user_with_no_money }

      it "does not allow to sell/purchase trading sets" do
        trade_set(operation: 'buy', quantity: max_sets)
        expect(response).to be_success
      end
    end

    context 'for users with money' do
      before { sign_in user_with_money }

      it "allows to buy trading sets" do
        trade_set(operation: 'buy', money: max_money)
        validate_balance(0)
        validate_shares_balance(max_sets)
      end
    end

    context 'for users with shares' do
      before { sign_in user_with_shares }

      it "allows to sell trading sets" do
        trade_set(operation: 'sell', quantity: max_sets)
        validate_shares_balance(0)
        validate_balance(max_sets * market.settle_price(currency))
      end
    end
  end

  def validate_balance(money)
    money = Money.new(money, currency) unless money.is_a?(Money)
    expect(controller.current_user.balance(currency)).to eq money
  end

  # rubocop:disable Metrics/AbcSize
  def validate_shares_balance(quantity)
    if quantity == 0
      expect(controller.current_user.spendable_shares.count).to eq 0
      return
    end
    expect(controller.current_user.spendable_shares.count).to eq 2
    controller.current_user.spendable_shares.each do |c|
      expect(c.total).to eq(quantity)
    end
  end

  def trade_set(args)
    post 'create', params: trading_set_params(trading_set_form: args)
  end

  def trading_set_params(p = {})
    { market_id: market, currency: currency }.merge(p)
  end
end
