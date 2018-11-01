class CreateMarkets < ActiveRecord::Migration[5.1]
  def change
    create_table :markets do |t|
      t.string :title
      t.string :external_id
      t.string :ticker, null: false
      t.text :details
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :winner_outcome, null: true, class_name: 'MarketOutcome'
      t.integer :market_type, null: false
      t.integer :state, null: false
      t.datetime :start_date, :close_date, index: true
      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index :ticker, unique: true
    end
  end
end
