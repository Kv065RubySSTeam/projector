# frozen_string_literal: true

# The membership belongs to the board,
# the board is present and can have any amount of users.
# The membership has uniqueness of user on board scope, and need to be present.
class Membership < ApplicationRecord
  # @!group Associations
  belongs_to :board
  belongs_to :user
  # @!endgroup

  # @!group Validations
  validates_uniqueness_of :user_id, scope: :board_id, presence: true
  # @!endgroup

  # @return [Boolean] with TRUE value
  def admin!
    update(admin: true)
  end

  # @return [Boolean] with FALSE value
  def remove_admin!
    update(admin: false)
  end
end
