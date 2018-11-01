class CreateContractTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :contract_transactions do |t|
      t.integer :reason, null: false
      t.integer :prev_id

      t.belongs_to :contract, null: false, foreign_key: true, index: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :total_change, :escrow_total_change, null: false, default: 0
      t.integer :total, :escrow_total, null: false, default: 0

      t.integer :market_id, null: false
      t.integer :market_outcome_id, null: false

      t.integer :cause_id, null: false
      t.string  :cause_type, null: false

      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index %i[user_id contract_id prev_id], unique: true, name: 'contract_prev_id'
      t.index %i[market_id market_outcome_id], name: 'contract_market'
      t.index %i[cause_type cause_id]
    end
  end
end
