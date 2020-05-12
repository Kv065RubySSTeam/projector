class Column < ApplicationRecord
  DEFAULT_TITLE = 'Default Title'

  belongs_to :board
  belongs_to :user
<<<<<<< HEAD
  has_many :cards, dependent: :destroy
  validates :name, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :board }
  
  def last_card_position
    self.cards.maximum(:position)
  end

=======
  validates :name, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :board }
>>>>>>> 2ff5adf... refactoring column and board model, column controller, services
end
