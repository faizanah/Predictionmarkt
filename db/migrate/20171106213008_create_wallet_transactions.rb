class CreateWalletTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :wallet_transactions do |t|
      t.integer :reason, null: false
      t.belongs_to :wallet, null: false, foreign_key: true
      t.belongs_to :currency_transfer, foreign_key: true, index: true
      t.integer :prev_id
      t.decimal :total_change, :escrow_total_change, null: false, default: 0, precision: 42, scale: 0
      t.decimal :total, :escrow_total, null: false, default: 0, precision: 42, scale: 0
      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index %i[wallet_id prev_id], unique: true, name: 'wallet_prev_id'
    end
  end
end
