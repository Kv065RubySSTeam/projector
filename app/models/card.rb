class Card < ApplicationRecord
  belongs_to :column
  validates :title, length: { within: 2..50 }
  
  # scope :last_position, -> { maximum(:position) }
end
