class CreateMarketOutcomes < ActiveRecord::Migration[5.1]
  def change
    create_table :market_outcomes do |t|
      t.string :title
      t.string :short_title
      t.string :external_id
      t.string :ticker, null: false
      t.integer :outcome_type, null: false
      t.belongs_to :market, null: false, foreign_key: true
      t.text :details
      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index %i[market_id title], unique: true
      t.index :ticker, unique: true
    end
  end
end
