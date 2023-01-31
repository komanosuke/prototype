class Bench < ApplicationRecord
    belongs_to :park

    has_many :bench_audios
    has_many :bench_images
    has_many :bench_videos
end
