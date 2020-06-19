class Notification < ApplicationRecord
  belongs_to :notificationable, polymorphic: true

  sql = "INNER JOIN cards ON cards.id = notifications.notificationable_id"
  scope :available_for, -> (user) { joins(sql)
    .where(cards: { user_id: user.id } || { assignee_id: user.id }) }

  self.per_page = 5

end
