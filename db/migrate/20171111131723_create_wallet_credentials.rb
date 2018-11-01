class CreateWalletCredentials < ActiveRecord::Migration[5.1]
  def change
    create_table :wallet_credentials do |t|
      t.integer :currency, null: false
      t.integer :state, null: false
      t.string  :address, null: false
      t.string  :public_key, null: false
      t.string  :encrypted_private_key, null: false
      t.text :details
      t.integer :lock_version, default: 0, null: false
      t.timestamps null: false

      t.index :address, unique: true
    end
  end
end
