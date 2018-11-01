require 'rails_helper'

RSpec.describe WithdrawalOrder, type: :model do
  each_currency :withdrawable? do
    it 'updates currency transfer state' do
      raw_tx = raw_transaction_for(currency)
      order = create(:withdrawal_order, state: :pending, raw_transaction: raw_tx, currency: currency)
      order.sent!

      currency_transfer = CurrencyTransfer.find(order.currency_transfer_id)
      expect(currency_transfer.sent?).to eq true
      expect(currency_transfer.receiving_transaction_id).to be_a(String)
    end

    it 'takes out 4% of withdraw comission' do
      order = create(:withdrawal_order, withdraw_amount: 100, currency: currency)
      expect(order.amount).to eq 96
    end

    it 'does proper rounding' do
      order = create(:withdrawal_order, withdraw_amount: 10, currency: currency)
      expect(order.amount).to eq 9
    end
  end
end
