class CreateShortcuts < ActiveRecord::Migration[6.1]
  def change
    create_table :shortcuts do |t|
      t.references :bench, foreign_key: true
      t.string :name
      t.text :program
      t.date :introduced_date

      t.timestamps
    end
  end
end
