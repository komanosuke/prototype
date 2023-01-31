class CreateBenches < ActiveRecord::Migration[6.1]
  def change
    create_table :benches do |t|
      t.references :park, foreign_key: true
      t.string :name
      t.string :mac_address
      t.string :os_name
      t.date :introduced_date
      t.string :position
      t.boolean :timer

      t.timestamps
    end
  end
end
