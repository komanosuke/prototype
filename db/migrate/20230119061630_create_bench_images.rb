class CreateBenchImages < ActiveRecord::Migration[6.1]
  def change
    create_table :bench_images do |t|
      t.references :user, foreign_key: true
      t.references :bench
      t.string :name
      t.string :image
      t.string :pdf_url

      t.timestamps
    end
  end
end
