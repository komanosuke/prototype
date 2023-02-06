class CreateShortcuts < ActiveRecord::Migration[6.1]
  def change
    create_table :shortcuts do |t|
      t.references :park, foreign_key: true
      t.string :title, null: false
      t.string :nickname
      t.timestamp :start_time, null: false
      t.timestamp :end_time
      t.string :mac_address1, null: false
      t.string :triggers, null: false
      t.string :mac_address2, null: false
      t.string :actions, null: false
      t.string :repeat
      
      t.timestamps
    end
  end
end
