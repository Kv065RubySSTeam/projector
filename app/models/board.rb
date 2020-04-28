# frozen_string_literal: true

class Board < ApplicationRecord
  belongs_to :user

  validates :title, length: { within: 5..50 }
  validates :description, length: { within: 5..255 }
  validates :user, presence: true

  scope :search, lambda { |input|
                   where('title ilike ? or description ilike ?',
                         "%#{input}%",
                         "%#{input}%")
                 }
  scope :user_boards, ->(user) { where(user_id: user.id) }
  scope :public_boards, -> { where(public: true) }
  scope :private_boards, -> { where(public: false) }
  scope :filter, lambda { |filter, user|
    case filter
    when 'my'
      user_boards(user)
    when 'private'
      private_boards.user_boards(user)
    when 'public'
      public_boards
    else
      all
    end
  }
  self.per_page = 10
  has_many :memberships
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
end
