class BenchAudio < ApplicationRecord
    belongs_to :user
    mount_uploader :audio, AudioUploader
end
