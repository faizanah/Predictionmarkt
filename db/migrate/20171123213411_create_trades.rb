class CreateTrades < ActiveRecord::Migration[5.1]
  def change
    create_table :trades do |t|
      t.integer :state, null: false
      t.integer :trade_type, null: false

      # TODO: add foreign keys
      t.integer :ask_order_id, :bid_order_id, null: false

      t.belongs_to :contract, null: false, foreign_key: true
      t.belongs_to :market, null: false, foreign_key: true
      t.belongs_to :market_outcome, null: false, foreign_key: true

      t.integer :currency, null: false
      t.integer :quantity, null: false
      t.decimal :price, null: false, default: 0, precision: 42, scale: 0
      t.decimal :amount, null: false, default: 0, precision: 42, scale: 0

      t.text    :details

      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index :ask_order_id
      t.index :bid_order_id
      t.index %i[state market_id contract_id trade_type], name: 'trades_comboindex'
      t.index %i[market_id contract_id created_at trade_type], name: 'trades_comboindex_time'
      t.index %i[market_id created_at]
    end
  end
end
