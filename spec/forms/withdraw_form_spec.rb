require 'rails_helper'

RSpec.describe WithdrawForm do
  let(:user) { create :user }
  let(:default_amount) { 10_000_000 }
  let(:user_with_money) { create(:user, :with_all_currencies, default_amount: default_amount) }

  it_behaves_like "an authenticated form"

  each_currency :withdrawable? do
    let(:to_address) { ApplicationCurrency.get(currency).generate_key[:address] }

    it 'does not pass validation without necessary arguments' do
      form = WithdrawForm.new(currency: currency, user: user_with_money)
      expect(form.valid?(:save)).to eq false
    end

    context 'for a user with money' do
      let(:form) { WithdrawForm.new(currency: currency, user: user_with_money, address: to_address) }

      it 'passes validation with no money argument' do
        expect(form.valid?(:save)).to eq true
      end

      it 'withdraws full amount of money' do
        form.save
        expect(form.user.balance(currency)).to eq 0
        expect(form.user.last_transaction(currency).escrow_total).to eq 0
        expect(form.user.spendable_balances.size).to be >= 1
      end

      it 'partially withdraws money' do
        form.money = default_amount / 10
        form.save
        expect(form.user.balance(currency).fractional).to eq default_amount / 10 * 9
      end

      it 'does not validate overbalance withdrawal' do
        form.money = default_amount * 2
        expect(form.valid?(:save)).to eq false
      end

      it 'does not validate negative withdrawal' do
        form.money = default_amount * -1
        expect(form.valid?(:save)).to eq false
      end
    end
  end
end
