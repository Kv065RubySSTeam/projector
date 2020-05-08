class Card < ApplicationRecord
  belongs_to :column
  belongs_to :user
  validates :title, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :column }
  
  before_validation(on: :create) do
    self.position = self.column.last_card_position.to_i + 1
  end
  
end
