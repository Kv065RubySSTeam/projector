class Notification < ApplicationRecord
  belongs_to :card

  self.inheritance_column = :type

  scope :available_for, -> (user) { joins(:card)
      .where(cards: { user_id: user.id } || {assignee_id: user.id} ) }

  def self.types
    [
      'MoveCardNotification',
      'AddCommentNotification',
      'AddAssigneeNotification'
    ]
  end

  self.per_page = 5
end
