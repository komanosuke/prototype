class Park < ApplicationRecord
    belongs_to :user

    has_many :benches
    has_many :products, dependent: :destroy
    has_many :pictures, dependent: :destroy
    has_many :events, dependent: :destroy
    has_many :shortcuts, dependent: :destroy
end
