class Bench < ApplicationRecord
    belongs_to :park

    has_many :shortcuts, dependent: :destroy
end
