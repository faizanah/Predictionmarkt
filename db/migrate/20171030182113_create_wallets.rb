class CreateWallets < ActiveRecord::Migration[5.1]
  def change
    create_table :wallets do |t|
      t.integer :currency, null: false
      t.integer :state, null: false
      t.string  :address, null: false
      t.belongs_to :user, index: true
      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index :address, unique: true
    end
  end
end
