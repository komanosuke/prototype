class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :zip
      t.string :prefecture
      t.string :city
      t.string :street
      t.string :address
      t.string :tel
      t.string :municipality
      t.string :division
      t.string :image
      t.text :profile
      t.string :notification
      t.string :flag
      t.text :admin_memo
      t.string :remember_digest
      t.string :activation_digest
      t.boolean :activated
      t.datetime :activated_at
      t.string :reset_digest
      t.datetime :reset_sent_at

      t.timestamps
    end
  end
end
