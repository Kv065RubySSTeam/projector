# frozen_string_literal: true

# The comment belongs to the card, has a creator
# and can has many likes: only one like from every user.
# The comment has body with the maximum length 1000
# The comment has pagination with 5 comments per page
class Comment < ApplicationRecord
  # @!group Associations
  belongs_to :user
  belongs_to :card
  has_many :likes, as: :likable, dependent: :destroy
  has_many :notifications, as: :notificationable, dependent: :destroy

  # @!group Validations
  validates :body, presence: true, length: { maximum: 1000 }
  # @!endgroup

  # Pagination with 5 comments per page
  self.per_page = 5
end
