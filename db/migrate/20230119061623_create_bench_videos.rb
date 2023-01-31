class CreateBenchVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :bench_videos do |t|
      t.references :user, foreign_key: true
      t.references :bench
      t.string :name
      t.string :video
      t.string :pdf_url

      t.timestamps
    end
  end
end
