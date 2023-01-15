class CreateParks < ActiveRecord::Migration[6.1]
  def change
    create_table :parks do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :zip
      t.string :prefecture
      t.string :city
      t.string :street
      t.string :address
      t.json :hours
      t.string :tel
      t.json :fee
      t.string :map
      t.string :website
      t.string :size
      t.text :profile
      t.string :status
      t.json :parking_info
      t.json :toilet_info
      t.json :playground_info
      t.json :facility_info
      t.json :sports_info
      t.json :view_info
      t.json :disaster_info
      t.json :other_info
      
      t.timestamps
    end
  end
end
