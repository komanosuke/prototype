class CreateTmpMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :tmp_messages do |t|
      t.string :message
      t.timestamps
    end
  end
end
