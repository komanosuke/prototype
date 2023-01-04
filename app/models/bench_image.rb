class BenchImage < ApplicationRecord
    mount_uploader :image, ImageUploader
end
