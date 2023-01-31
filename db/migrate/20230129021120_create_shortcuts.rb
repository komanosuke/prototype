class CreateShortcuts < ActiveRecord::Migration[6.1]
  def change
    create_table :shortcuts do |t|
      t.references :park, foreign_key: true
      t.string :title, null: false
      t.string :nickname
      t.timestamp :start_time, null: false
      t.timestamp :end_time
      t.string :repeat
      t.text :program, null: false
      
      t.timestamps
    end
  end
end
