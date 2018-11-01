class AddMarketSpecIdToMarkets < ActiveRecord::Migration[5.2]
  def change
    add_column :markets, :market_spec_id, :integer
    add_index :markets, :market_spec_id
  end
end
