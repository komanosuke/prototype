class BenchImage < ApplicationRecord
    belongs_to :user
    belongs_to :bench
    mount_uploader :image, ImageUploader
end
