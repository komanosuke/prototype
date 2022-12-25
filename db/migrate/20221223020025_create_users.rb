class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :role
      t.date :registered
      t.integer :login
      t.string :display_name
      t.string :email
      t.string :password_digest
      t.string :zip
      t.string :prefecture
      t.string :address
      t.string :street
      t.string :tel
      t.string :municipality
      t.string :division
      t.binary :image
      t.text :profile
      t.string :notification
      t.string :flag
      t.text :admin_memo

      t.timestamps
    end
  end
end
