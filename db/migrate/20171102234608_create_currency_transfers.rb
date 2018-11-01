class CreateCurrencyTransfers < ActiveRecord::Migration[5.1]
  def change
    create_table :currency_transfers do |t|
      t.integer :reason, null: false
      t.integer :state, null: false
      t.decimal :total_change, null: false, precision: 42, scale: 0
      t.integer :currency, null: false
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :lock_version, default: 0, null: false
      t.string  :receiving_address, null: false
      t.string  :receiving_transaction_id
      t.timestamps null: false

      t.index %i[user_id reason state]
    end
  end
end
