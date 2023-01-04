class CreateBenchImages < ActiveRecord::Migration[6.1]
  def change
    create_table :bench_images do |t|
      t.references :bench, foreign_key: true
      t.string :name
      t.string :image

      t.timestamps
    end
  end
end
