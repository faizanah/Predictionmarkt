class CreateReferredVisitors < ActiveRecord::Migration[5.2]
  def change
    create_table :referred_visitors do |t|
      t.text :details
      t.belongs_to :referral_code, foreign_key: true, null: false

      t.belongs_to :referred, null: true, class_name: 'User'
      t.belongs_to :referrer, null: false, class_name: 'User'

      t.timestamps null: false
    end
  end
end
