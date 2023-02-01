class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.references :park, foreign_key: true
      t.string :name
      t.string :date
      t.text :contents
      t.string :image

      t.timestamps
    end
  end
end
