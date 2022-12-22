class CreateTmpData < ActiveRecord::Migration[6.1]
  def change
    create_table :tmp_data do |t|
      t.string :data
      t.string :mac_address

      t.timestamps
    end
  end
end
