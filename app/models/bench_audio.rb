class BenchAudio < ApplicationRecord
    belongs_to :user
    belongs_to :bench
    mount_uploader :audio, AudioUploader
end
