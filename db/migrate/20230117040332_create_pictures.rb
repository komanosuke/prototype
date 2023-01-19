class CreatePictures < ActiveRecord::Migration[6.1]
  def change
    create_table :pictures do |t|
      t.references :park, foreign_key: true
      t.string :name
      t.string :picture
      t.string :size

      t.timestamps
    end
  end
end
