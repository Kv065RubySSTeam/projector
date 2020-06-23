# frozen_string_literal: true

# The column belongs to the board,
# has a creator and can have any amount of cards.
# The column has default title with the length within 2 to 50
# and uniqueness on board scope.
class Column < ApplicationRecord
  # @note Default title for any new column
  DEFAULT_TITLE = 'Default Title'

  # @!group Associations
  belongs_to :board
  belongs_to :user
  has_many :cards, dependent: :destroy
  # @!endgroup

  # @!group Validations
  validates :name, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :board }
  # @!endgroup

  # @return [Integer] maximum card position on the current column

  self.per_page = 10

  def last_card_position
    cards.maximum(:position)
  end
end
