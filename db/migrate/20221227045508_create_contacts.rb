class CreateContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :contacts do |t|
      t.string :category, null: false
      t.string :name, null: false
      t.string :organization, null: false
      t.string :email, null: false
      t.string :tel, null: false
      t.text :message, null: false
      t.boolean :agree, null: false

      t.timestamps
    end
  end
end
