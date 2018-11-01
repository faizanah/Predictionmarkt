class CreateWithdrawalOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :withdrawal_orders do |t|
      t.integer :state, null: false
      t.integer :currency_transfer_id, null: false
      t.integer :residual_wallet_id, null: false
      t.text    :details
      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index :currency_transfer_id
      t.index :residual_wallet_id
    end
  end
end
