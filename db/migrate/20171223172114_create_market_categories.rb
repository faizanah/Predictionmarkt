class CreateMarketCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :market_categories do |t|
      t.string :name, null: false, index: true
      t.integer :parent_id, null: true, index: true
      t.integer :lft, null: false, index: true
      t.integer :rgt, null: false, index: true

      t.text :details

      # optional fields
      t.integer :depth, null: false, default: 0
      t.timestamps null: false
    end
  end
end
