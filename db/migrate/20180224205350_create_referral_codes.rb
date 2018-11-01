class CreateReferralCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :referral_codes do |t|
      t.string :code, null: false
      t.belongs_to :user, foreign_key: true, null: false
      t.text :details
      t.timestamps null: false

      t.index :code, unique: true
    end
  end
end
