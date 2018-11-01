require 'rails_helper'

RSpec.describe TradingOrderForm do
  it_behaves_like "an authenticated form"

  each_currency do
    let(:contract) { create(:contract, currency: currency) }

    let(:available_money) { Money.new(contract.max * 1000, currency) }
    let(:available_shares) { 1000 }
    let(:user_with_no_money) { create(:user) }
    let(:user_with_money) { create(:user, funds: available_money) }
    let(:user_with_shares) { create(:user, shares: { contract => available_shares }) }
    let(:one_day_from_now) { 1.day.from_now.round }

    let(:form) do
      TradingOrderForm.new(market_outcome_id: contract.market_outcome.to_param,
                           currency: currency)
    end

    it 'does not pass validation without necessary arguments' do
      form.user = user_with_no_money
      expect(form.valid?).to eq false
      expect(form.save).to eq false
      expect(form.errors.size).to be >= 1
    end

    context "while buying the shares" do
      before { form.operation = 'buy' }

      context 'by a user with no money' do
        before { form.user = user_with_no_money }

        it 'fails to create market orders' do
          fail_to_create_order(type: 'market', money: available_money.fractional)
        end
      end

      context 'by a user with money' do
        before { form.user = user_with_money }

        it 'creates market orders' do
          order = create_order(type: 'market', money: limit_price(10))
          validate_order(order, requested_amount: limit_price(10), time_in_force: 'ioc')
        end

        it 'does not create market orders when they are over balance' do
          fail_to_create_order(type: 'market', money: available_money.fractional + contract.tick)
        end

        it 'creates limit orders' do
          order = create_order(type: 'limit', max_price: limit_price(2),
                               quantity: 3, time_in_force: 'gtc')
          validate_order(order, time_in_force: 'gtc', requested_quantity: 3,
                                requested_amount: limit_price(6))
        end

        it 'creates limit order matching full balance' do
          create_order(type: 'limit', max_price: contract.max,
                       quantity: available_money.fractional / contract.max, time_in_force: 'gtc')
          expect(form.user.reload.balance(currency)).to eq 0
        end

        it 'creates Good Till Time limit order' do
          order = create_order(type: 'limit', max_price: limit_price(2), quantity: 3,
                               time_in_force: 'gtt', expires_at: one_day_from_now)

          validate_order(order, time_in_force: 'gtt', expires_at: one_day_from_now, requested_quantity: 3,
                                requested_amount: limit_price(6))
        end

        it 'does not create over-balance limit orders' do
          fail_to_create_order(type: 'limit', max_price: contract.max,
                               quantity: available_money.fractional / contract.max + 1, time_in_force: 'gtc')
        end

        it 'creates stop orders' do
          order = create_order(type: 'stop', max_price: limit_price(2),
                               quantity: 3, time_in_force: 'gtc', stop_price: limit_price(1))
          validate_order(order, requested_amount: limit_price(6), requested_quantity: 3,
                                stop_price: limit_price(1))
        end
      end
    end

    context "while selling the shares" do
      before { form.operation = 'sell' }

      context 'by a user with no money' do
        before { form.user = user_with_no_money }

        it 'fails to create market orders' do
          fail_to_create_order(type: 'market', quantity: available_shares)
        end
      end

      context 'by a user with shares' do
        before { form.user = user_with_shares }

        it 'creates market orders' do
          order = create_order(type: 'market', quantity: available_shares)
          validate_order(order, requested_quantity: available_shares, time_in_force: 'ioc')
        end

        it 'does not create market orders when they are over balance' do
          fail_to_create_order(type: 'market', quantity: available_shares + 1)
        end

        it 'creates limit orders' do
          order = create_order(type: 'limit', min_price: limit_price(2),
                               quantity: 3, time_in_force: 'gtc')
          validate_order(order, time_in_force: 'gtc', requested_quantity: 3,
                                requested_amount: limit_price(6))
        end

        it 'creates limit order matching full balance' do
          create_order(type: 'limit', min_price: contract.max,
                       quantity: available_shares, time_in_force: 'gtc')
          expect(form.user.shares(contract)).to eq 0
        end

        it 'creates Good Till Time limit order' do
          order = create_order(type: 'limit', min_price: limit_price(2), quantity: 3,
                               time_in_force: 'gtt', expires_at: one_day_from_now)

          validate_order(order, time_in_force: 'gtt', expires_at: one_day_from_now,
                                requested_amount: limit_price(6), requested_quantity: 3)
        end

        it 'does not create over-balance limit orders' do
          fail_to_create_order(type: 'limit', min_price: contract.max,
                               quantity: available_shares + 1, time_in_force: 'gtc')
        end

        it 'creates stop orders' do
          order = create_order(type: 'stop', min_price: limit_price(2),
                               quantity: 3, time_in_force: 'gtc', stop_price: limit_price(1))
          validate_order(order, requested_amount: limit_price(6), requested_quantity: 3,
                                stop_price: limit_price(1))
        end
      end
    end

    def create_order(input_args)
      form.assign_attributes(input_args)
      expect(form.save).to eq(true), "form #{input_args.inspect} save failed with #{form.errors.to_a.inspect}"
      fetch_order(input_args)
    end

    def fail_to_create_order(input_args)
      form.assign_attributes(input_args)
      expect(form.save).to eq false
    end

    def fetch_order(input_args)
      order = form.user.trading_orders.last
      expect(order.order_type).to eq "#{input_args[:type]}_order"
      order
    end

    def validate_order(order, attr_hash)
      attr_hash.each do |k, v|
        attr_value = order.send(k)
        expect(attr_value).to eq(v), "expected order's #{k} to be #{v.inspect} but got #{attr_value.inspect}"
      end
    end

    def limit_price(step)
      Money.new(contract.tick * step, currency).fractional
    end
  end
end
