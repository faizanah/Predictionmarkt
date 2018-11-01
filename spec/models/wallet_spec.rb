require 'rails_helper'

RSpec.describe Wallet, type: :model do
  context 'receiving address assignment' do
    let(:user) { create(:user) }

    it 'assigns wallets to a user' do
      user.wallets.delete_all
      expect do
        3.times do
          create_unused_wallets
          Wallet.assign_wallets_to_user(user)
        end
      end.to change(user.wallets, :count).by(depositable_currency_codes.size)
    end

    it 'assigns correct currencies do' do
      create_unused_wallets
      Wallet.assign_wallets_to_user(user)
      expect(user.wallets.map(&:currency)).to eq(depositable_currency_codes)
    end

    it 'allocates unused wallets' do
      create_unused_wallets(2)
      user.assign_wallets
      expect do
        user.wallets.last.full!
        user.assign_wallets
      end.to change(user.wallets, :count).by(1)
      expect(user.wallets.receiving.map(&:currency)).to eq(depositable_currency_codes)
    end
  end

  each_currency :depositable? do
    let(:user) { create(:user, :with_wallets) }

    it "updates user balance with 4 deposits" do
      expect { 2.times { add_wallets(user, 100_000, currency, 2) } }.to change(CurrencyTransfer.deposit, :count).by(4)
      expect(user.balance(currency)).to eq(Money.from_amount(200_000, currency))
      expect(user.wallets.full.count).to eq(4)
    end
  end

  def depositable_currency_codes
    ApplicationCurrency.select(&:depositable?).map(&:code)
  end
end
