class CreateNews < ActiveRecord::Migration[6.1]
  def change
    create_table :news do |t|
      t.date :date
      t.string :title
      t.text :contents
      
      t.timestamps
    end
  end
end
