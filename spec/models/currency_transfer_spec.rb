require 'rails_helper'

RSpec.describe CurrencyTransfer, type: :model do
  each_currency :withdrawable? do
    context "Currency withdrawal" do
      let(:user) { create(:user, :with_wallets) }
      let(:default_amount) { 10_000 }

      it "allows full balance withdrawal" do
        money = add_funds(user, default_amount, currency)
        expect(user.balance(currency)).to eq money
        expect { withdraw_funds(user, default_amount, currency) }.not_to raise_error
        expect(user.balance(currency)).to eq 0
      end

      it "allows partial balance withdrawal" do
        add_funds(user, 10, currency)
        expect { withdraw_funds(user, 1, currency) }.not_to raise_error
        expect(user.balance(currency)).to eq Money.from_amount(9, currency)
      end

      it "restricts zero balance withdrawal" do
        expect { withdraw_funds(user, 1, currency) }.to raise_error(ActiveRecord::RecordInvalid)
        expect(user.balance(currency)).to eq 0
      end

      it "restricts negative withdrawal" do
        add_funds(user, default_amount, currency)
        expect { withdraw_funds(user, -1, currency) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "Currency deposit" do
      let(:user) { create(:user) }
      let(:default_amount) { 10_000 }

      it "allows deposits" do
        money = add_funds(user, default_amount, currency)
        expect(user.balance(currency)).to eq money
      end

      it "does not create negative deposits" do
        add_wallets(user, default_amount, currency)
        expect { add_wallets(user, -1, currency) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "does not process multiple transactions to the same wallet" do
        money = add_wallets(user, default_amount, currency)
        wallet = user.wallets.full.where(currency: currency).last!
        wallet.update_balance(Money.new(default_amount + 1, currency))
        expect(user.balance(currency)).to eq money
      end
    end
  end
end
