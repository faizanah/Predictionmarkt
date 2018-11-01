class CreateCurrencyTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :currency_transactions do |t|
      t.integer :reason, null: false
      t.integer :prev_id

      # Scope
      t.integer :currency, null: false
      t.belongs_to :user, null: false, foreign_key: true

      t.decimal :total_change, :escrow_total_change, null: false, default: 0, precision: 42, scale: 0
      t.decimal :total, :escrow_total, null: false, default: 0, precision: 42, scale: 0

      t.integer :cause_id, null: false
      t.string  :cause_type, null: false

      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index %i[user_id currency prev_id], unique: true, name: 'currency_prev_id'
      t.index %i[cause_type cause_id]
    end
  end
end
