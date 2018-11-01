class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.text :details

      t.string :ip_address
      t.string :user_agent
      t.string :request_id

      t.integer :cause_id, null: false
      t.string  :cause_type, null: false

      t.timestamps null: false

      t.index :ip_address
      t.index :request_id
      t.index :created_at
      t.index %i[cause_type cause_id]
    end
  end
end
