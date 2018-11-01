require 'rails_helper'

RSpec.describe TradingOrder, type: :model do
  one_currency do
    include_context 'trading context'

    it 'fails to validate bid order for user with no money' do
      expect do
        limit_bid(1, available_money + 1, user: user_with_no_money)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'fails to validate ask order for user with no shares' do
      expect do
        limit_ask(available_shares + 1, 1, user: user_with_no_money)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'changes state when the order gets closed' do
      ask = limit_ask(bid_quantity, bid_price, user: user_with_shares)
      expect(ask.state).to eq 'maker'
      market_bid(bid_money, user: user_with_money)
      expect(ask.reload.state).to eq 'closed'
    end

    it 'keeps the order open if not fully filled' do
      ask = limit_ask(bid_quantity, bid_price, user: user_with_shares)
      expect(ask.state).to eq 'maker'
      market_bid(bid_money - 1, user: user_with_money)
      expect(ask.reload.state).to eq 'maker'
    end
  end

  each_currency do
    it 'escrows/unescrows the money' do
      order = limit_bid(bid_quantity, bid_price, user: user_with_money)
      validate_balance(order, available_money - bid_money, bid_money)
      order.cancelled!
      validate_balance(order, available_money, 0)
    end

    it 'escrows/unescrows the shares' do
      o = limit_ask(ask_quantity, ask_price, user: user_with_shares)
      validate_shares(o, available_shares - ask_quantity, ask_quantity)
      o.cancelled!
      validate_shares(o, available_shares, 0)
    end

    it 'processes and closes matching orders' do
      ask = limit_ask(bid_quantity, bid_price, user: user_with_shares)
      bid = market_bid(bid_money, user: user_with_money)
      [ask, bid].each { |o| expect(o.reload.closed?).to eq true }
      validate_balance(bid, available_money - ask_money, 0)
      validate_balance(ask, ask_money, 0)
      validate_shares(bid, bid_quantity, 0)
      validate_shares(ask, available_shares - ask_quantity, 0)
    end

    it 'immediately closes market order' do
      bid = market_bid(bid_money)
      expect(bid.state).to eq 'closed'
      expect(bid.filled_quantity).to eq 0
    end

    def validate_balance(order, total, escrow)
      expect_equal_money(order.user.last_transaction(currency).total, total)
      expect_equal_money(order.user.last_transaction(currency).escrow_total, escrow)
    end

    def validate_shares(order, total, escrow)
      expect(order.user.last_contract_transaction(order.contract).total).to eq total
      expect(order.user.last_contract_transaction(order.contract).escrow_total).to eq escrow
    end

    def expect_equal_money(a, b)
      a = Money.new(a, currency) unless a.is_a?(Money)
      b = Money.new(b, currency) unless b.is_a?(Money)
      expect(a).to eq(b)
    end
  end

  one_currency do
    include_context 'trading context'

    it "returns progress" do
      ask = limit_ask(ask_quantity * 0.2, ask_price, user: user_with_shares)
      bid = market_bid(bid_money, user: user_with_money)
      expect(ask.reload.progress).to eq 1
      expect(bid.reload.progress).to eq 0.2
    end
  end
end
