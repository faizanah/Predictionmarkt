class CreateTradesUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :trades_users do |t|
      t.belongs_to :trade, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false
    end
  end
end
