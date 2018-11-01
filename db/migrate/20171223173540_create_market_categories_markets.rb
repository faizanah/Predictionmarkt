class CreateMarketCategoriesMarkets < ActiveRecord::Migration[5.1]
  def change
    create_table :market_categories_markets do |t|
      t.belongs_to :market, foreign_key: true, null: false
      t.belongs_to :market_category, index: true, foreign_key: true, null: false

      t.index %w[market_id market_category_id], unique: true, name: 'unique_markets_in_category'
    end
  end
end
