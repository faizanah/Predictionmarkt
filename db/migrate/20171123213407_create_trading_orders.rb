class CreateTradingOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :trading_orders do |t|
      t.integer :state, null: false
      t.integer :order_type, null: false
      t.integer :operation, null: false
      t.integer :time_in_force, null: false
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :contract, null: false, foreign_key: true
      t.belongs_to :market, null: false, foreign_key: true, index: true
      t.belongs_to :market_outcome, null: false, foreign_key: true

      t.integer :filled_quantity, :requested_quantity, :escrowed_quantity
      t.decimal :filled_amount, :requested_amount, :escrowed_amount, precision: 42, scale: 0
      t.decimal :limit_price, :stop_price, precision: 42, scale: 0

      t.datetime :expires_at

      t.text    :details

      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index %i[state user_id market_id contract_id], name: 'trading_orders_userindex'
      t.index %i[state market_id contract_id order_type operation limit_price], name: 'trading_orders_combo_limit'
      t.index %i[state market_id contract_id stop_price], name: 'trading_orders_combo_stop'
      t.index :expires_at
      t.index :created_at
    end
  end
end
