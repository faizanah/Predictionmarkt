class CreateMarketSharesTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :market_shares_transactions do |t|
      t.integer :reason, null: false
      t.integer :prev_id

      # Scope
      t.belongs_to :market, null: false, foreign_key: true
      t.integer :currency, null: false

      t.integer :total_change, :escrow_total_change, null: false, default: 0
      t.integer :total, :escrow_total, null: false, default: 0

      t.integer :cause_id, null: false
      t.string  :cause_type, null: false

      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index %i[market_id currency prev_id], unique: true, name: 'market_shares_prev_id'
      t.index %i[cause_type cause_id]
    end
  end
end
