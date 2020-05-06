class Card < ApplicationRecord
  belongs_to :column
  belongs_to :user
  validates :title, length: { within: 2..50 }
  
  scope :last_position, -> { maximum(:position) }

  before_validation(on: :create) do
    self.position = self.position.blank? ? 1 : self.position + 1
  end
end
