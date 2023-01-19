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
      t.string :hours
      t.string :tel
      t.string :fee
      t.string :map
      t.string :website
      t.string :iframe
      t.string :size
      t.text :profile
      t.string :status
      t.string :parking_info
      t.string :toilet_info
      t.string :playground_info
      t.string :facility_info
      t.string :sports_info
      t.string :view_info
      t.string :disaster_info
      t.string :other_info

      t.timestamps
    end
  end
end
