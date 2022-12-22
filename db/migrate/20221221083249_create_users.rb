class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :role
      t.date :user_registered
      t.integer :user_login
      t.string :display_name
      t.string :user_email
      t.string :user_pass
      t.string :user_zip
      t.string :user_prefecture
      t.string :user_address
      t.string :user_street
      t.string :user_tel
      t.string :user_municipality
      t.string :user_division
      t.binary :user_image
      t.text :user_profile
      t.string :user_notification
      t.string :user_flag
      t.text :user_admin_memo
      
      t.timestamps
    end
  end
end
