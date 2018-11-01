require 'rails_helper'

RSpec.describe My::FundsController, type: :controller do
  let(:user) { create :user }
  let(:default_amount) { 10_000_000 }
  let(:contract) { create :contract }
  let(:user_with_money) { create(:user, :with_all_currencies, default_amount: default_amount) }
  let(:eth_address) { ApplicationCurrency.get('eth').generate_key[:address] }

  context 'for users with no money' do
    before { sign_in user }

    it "shows no funds" do
      get 'index'
      expect(response).to be_success
    end

    it "does not allow to withdraw" do
      get 'withdraw', params: { currency: 'eth' }
      expect(response).to be_redirect
    end
  end

  context 'for users with money' do
    before { sign_in user_with_money }

    it "shows funds" do
      get 'index'
      expect(response).to be_success
    end

    it "shows funds and currency transfers" do
      create(:currency_transfer, user: user_with_money)
      get 'index'
      expect(response).to be_success
    end

    it "shows withdraw page" do
      get 'withdraw', params: { currency: 'eth' }
      expect(response).to be_success
    end

    it "does not withdraw without valida arg" do
      [{ user: 'qwe' },
       { address: eth_address + '123' }].each do |form_params|
        expect do
          post 'withdraw', params: { withdraw_form: form_params, currency: 'eth' }
        end.to change { user_with_money.currency_transfers.count }.by(0), form_params
      end
    end

    each_currency :withdrawable? do
      let(:to_address) { ac.generate_key[:address] }

      it "withdraws partial amount" do
        money = Money.new(default_amount / 2, currency)
        expect do
          post 'withdraw', params: { currency: currency,
                                     withdraw_form: { currency: currency, money: money.fractional, address: to_address } }
        end.to change { user_with_money.currency_transfers.count }.by(1)
        expect(user_with_money.last_transaction(currency).total).to eq default_amount / 2
      end

      it "withdraws full amount" do
        expect do
          post 'withdraw', params: { currency: currency, withdraw_form: { currency: currency, address: to_address } }
        end.to change { user_with_money.currency_transfers.count }.by(1)
        expect(user_with_money.last_transaction(currency).total).to eq 0
      end
    end
  end
end
