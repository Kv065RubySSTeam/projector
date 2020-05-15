class Membership < ApplicationRecord
  belongs_to :board
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :board_id, presence: true

  def admin!
    update(admin: true)
  end

  def remove_admin!
    update(admin: false)
  end
end
