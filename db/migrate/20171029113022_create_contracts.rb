class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.string :ticker, null: false
      t.belongs_to :market, null: false, index: true, foreign_key: true
      t.belongs_to :market_outcome, null: false, index: true, foreign_key: true
      t.integer :currency, null: false
      t.decimal :settle_price, null: false, precision: 42, scale: 0
      t.integer :state, null: false
      t.text :details
      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index :ticker, unique: true
      t.index %i[market_id market_outcome_id currency], unique: true, name: 'contracts_unique_outcomes'
    end
  end
end
