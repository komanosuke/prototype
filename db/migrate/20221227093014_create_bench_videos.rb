class CreateBenchVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :bench_videos do |t|
      t.references :bench, foreign_key: true
      t.string :name
      t.string :video

      t.timestamps
    end
  end
end
