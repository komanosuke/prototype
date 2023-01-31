class Picture < ApplicationRecord
    belongs_to :park

    mount_uploader :picture, ImageUploader
end
