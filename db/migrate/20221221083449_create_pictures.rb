class CreatePictures < ActiveRecord::Migration[6.1]
  def change
    create_table :pictures do |t|
      t.references :park, foreign_key: true
      t.string :name
      t.binary :picture
      
      t.timestamps
    end
  end
end
