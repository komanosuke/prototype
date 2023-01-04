class BenchVideo < ApplicationRecord
    belongs_to :bench
    mount_uploader :video, VideoUploader
end