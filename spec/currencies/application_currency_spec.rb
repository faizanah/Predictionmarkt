require 'rails_helper'

RSpec.describe ApplicationCurrency do
  each_currency :depositable? do
    context 'Balance checking' do
      let(:user) { create(:user, :with_wallets) }

      it "returns transfers via WalletMoney" do
        wallet = user.wallets.receiving.where(currency: currency).last!
        balances = [{ address: wallet.address, balance: "0.1231" }]
        allow(described_class).to receive(:get).and_return(ac)
        allow(ac).to receive(:balances).and_return(balances)
        transfers = ac.wallet_balances(Wallet.monitored)
        expect(transfers.last.money).to eq Money.new('0.1231', currency)
      end

      it "handles empty list of wallets to check" do
        expect(ac.wallet_balances([])).to eq []
      end
    end
  end
end
