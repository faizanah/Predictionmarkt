require 'rails_helper'

RSpec.describe CurrencyWithdrawal do
  include_context 'external currency services'

  each_currency :withdrawable? do
    context "on the production side (step 1)" do
      let(:initial_funds) { Money.from_amount(1, currency) }
      let!(:user) { create(:user, :with_wallets, funds: initial_funds, create_wallets: true) }

      it 'fails if deposited funds can not cover transaction fees' do
        withdraw_funds(user, initial_funds, currency)
        expect { ac.create_withdrawal_orders }.to raise_error(CurrencyError::NoWallets)
      end

      it 'creates withdrawal orders for one transfer' do
        1.times { withdraw_funds(user, 0.2, currency) }
        expect do
          ac.create_withdrawal_orders
        end.to change { WithdrawalOrder.count }.by(1)
      end
    end

    context "on the payments side (step 2)" do
      let(:user) { create(:user, :with_wallets) }
      let(:real_money) { full_wallet_money(currency) }

      before { create_real_full_wallet(currency, user)  }

      it 'imports orders but fails to sign them because fee increased' do
        create_real_withdrawal_orders(user: user, amount: real_money, currency: currency, fee: 0)
        if currency.to_s == 'btc'
          allow(ac).to receive(:tx_fee).and_return(500) # exeed 1% (withdrawal comission)
          expect { ac.sign_withdrawal_orders }.to raise_error(CurrencyError::NoFunds)
          puts 'signing the order'
        end
      end

      it 'processes the transaction' do
        amount = Money.new(3, currency)
        create_real_withdrawal_orders(user: user, amount: amount, currency: currency, fee: 2)
        expect { ac.sign_withdrawal_orders }.to change { WithdrawalOrder.signed.count }.by(1)
      end
    end

    context "on the production side (step 3)" do
      before do
        create(:withdrawal_order, state: 'signed', currency: currency, raw_transaction: raw_transaction_for(currency))
      end

      it 'updates state to sent after pushing transactions' do
        allow(ac).to receive(:pushtx).and_return(true)
        expect { ac.send_signed_transactions }.to change { WithdrawalOrder.sent.count }.by(1)
      end
    end

    context "full circle withdrawal (all steps)" do
      let(:user) { create(:user, :with_wallets) }
      let(:real_money) { full_wallet_money(currency) }
      let(:amount) { Money.new(3, currency) }

      before do
        create_real_full_wallet(currency, user)
        create_real_withdrawal_orders(user: user, amount: amount, currency: currency, fee: 2)
        ac.sign_withdrawal_orders
      end

      it 'throws error if transaction is not valid' do
        expect { ac.send_signed_transactions }.to raise_error(CurrencyError::ApiError)
      end
    end
  end

  def create_real_withdrawal_orders(args)
    withdraw_funds(args[:user], args[:amount], args[:currency])
    allow(ac).to receive(:tx_fee).and_return(args[:fee] || 0)
    ac.create_withdrawal_orders
  end
end
