class CreateBenchAudios < ActiveRecord::Migration[6.1]
  def change
    create_table :bench_audios do |t|
      t.references :user, foreign_key: true
      t.references :bench
      t.string :name
      t.string :audio
      t.string :pdf_url

      t.timestamps
    end
  end
end
