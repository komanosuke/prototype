class BenchVideo < ApplicationRecord
    belongs_to :user
    belongs_to :bench
    mount_uploader :video, VideoUploader
end
