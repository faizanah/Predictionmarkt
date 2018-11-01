require 'rails_helper'

# TODO: tests for money argument, now testing only quantity
RSpec.describe TradingSetForm do
  # it_behaves_like "an authenticated form"

  each_currency :enabled? do
    include_context 'trading set context'

    let(:form) { TradingSetForm.new(market: market, currency: currency) }

    it 'does not pass validation without necessary arguments' do
      form.user = user_with_money
      expect(form.valid?).to eq false
      expect(form.save).to eq false
      expect(form.errors.size).to be >= 1
    end

    context "while buying the shares" do
      before { form.operation = 'buy' }

      context 'by a user with no money' do
        before { form.user = user_with_no_money }

        it 'fails to create market orders' do
          fails_to_trade_set(money: max_money)
        end
      end

      context 'by a user with money' do
        before { form.user = user_with_money }

        it 'deposits all contracts for the market' do
          trade_set(money: max_money)
          validate_shares_balance(max_sets)
          validate_balance(0)
        end

        it 'partially deposits the contracts' do
          quantity_bought = max_sets / 3
          quantity_left = max_sets - quantity_bought
          trade_set(money: quantity_bought * market.settle_price(currency))
          validate_shares_balance(quantity_bought)
          validate_balance(quantity_left * market.settle_price(currency))
        end

        it 'does not allow to go over balance' do
          fails_to_trade_set(money: (max_sets + 1) * market.settle_price(currency))
        end
      end
    end

    context "while selling the shares" do
      before { form.operation = 'sell' }

      context 'by a user with no money' do
        before { form.user = user_with_no_money }

        it 'fails to create market orders' do
          fails_to_trade_set(quantity: max_sets)
        end
      end

      context 'by a user with shares' do
        before { form.user = user_with_shares }

        it 'withdraws the contracts' do
          trade_set(quantity: max_sets)
          validate_shares_balance(0)
          validate_balance(max_sets * market.settle_price(currency))
        end

        it 'partially withdraws the contracts' do
          quantity_sold = max_sets / 3
          quantity_left = max_sets - quantity_sold
          trade_set(quantity: quantity_sold)
          validate_shares_balance(quantity_left)
          validate_balance(quantity_sold * market.settle_price(currency))
        end

        it 'does not allow to go over balance' do
          fails_to_trade_set(quantity: max_sets + 1)
        end
      end
    end

    def validate_balance(money)
      money = Money.new(money, currency) unless money.is_a?(Money)
      expect(form.user.balance(currency)).to eq money
    end

    # rubocop:disable Metrics/AbcSize
    def validate_shares_balance(quantity)
      if quantity == 0
        expect(form.user.spendable_shares.count).to eq 0
        return
      end
      expect(form.user.spendable_shares.count).to eq 2
      form.user.spendable_shares.each do |c|
        expect(c.total).to eq(quantity)
      end
    end

    def trade_set(args)
      form.assign_attributes(args)
      expect(form.save).to eq(true), "form #{args.inspect} save failed with #{form.errors.first.inspect}"
    end

    def fails_to_trade_set(args)
      form.assign_attributes(args)
      expect(form.save).to eq false
    end
  end
end
