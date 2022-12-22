class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.references :park, foreign_key: true
      t.string :name
      t.text :contents
      
      t.timestamps
    end
  end
end
