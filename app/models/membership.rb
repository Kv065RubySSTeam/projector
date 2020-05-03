class Membership < ApplicationRecord
  belongs_to :board
  belongs_to :user

  scope :add, ->(board, user) { where(board_id: board.id, user_id: user.id) }
end
