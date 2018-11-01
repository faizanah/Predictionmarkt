class CreateContractTradeStats < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_trade_stats do |t|
      t.integer :interval, null: false
      t.datetime :interval_at, null: false

      t.belongs_to :contract, null: false, foreign_key: true
      t.belongs_to :market, null: false, foreign_key: true
      t.belongs_to :market_outcome, null: false, foreign_key: true
      t.integer :currency, null: false

      t.integer :quantity, null: false
      t.decimal :amount, null: false, default: 0, precision: 42, scale: 0

      t.integer :user_quantity, null: false
      t.decimal :user_amount, null: false, default: 0, precision: 42, scale: 0

      t.decimal :open_odds, :close_odds, :min_odds, :max_odds, null: false, default: 0, precision: 6, scale: 4
      t.decimal :mean_odds, :sos_odds, null: false, default: 0, precision: 6, scale: 4

      t.timestamps null: false

      t.index %w[interval_at contract_id], name: 'cts_composite1'
      t.index %w[interval_at market_outcome_id], name: 'cts_composite2'
    end
  end
end
