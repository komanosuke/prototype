class User < ApplicationRecord
    has_secure_password

    has_many :park, dependent: :destroy
    has_many :news
    has_many :media
end