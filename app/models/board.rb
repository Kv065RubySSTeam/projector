# frozen_string_literal: true

# Boards model
class Board < ApplicationRecord
  # @!group Associations
  belongs_to :user
  has_many :columns, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  # @!endgroup

  # @!group Validations
  validates :title, length: { within: 5..50 }
  validates :description, length: { within: 5..255 }
  validates :user, presence: true
  # @!endgroup

  # @!method search(input)
  #   Searches boards by title or description that match +input+ phrase.
  #   Case insensitive search.
  #   @param  [String] input the searach word or phrase
  #   @return [Set<Board>] the list of founded boards.
  scope :search, lambda { |input|
                   where('title ilike ? or description ilike ?',
                         "%#{input}%",
                         "%#{input}%")
                 }
  # @!method user_boards(user)
  #   Returns list of boards created by +user+
  #   @param [User] user the current user
  #   @return [Set<Board>] the list of public boards
  scope :user_boards, ->(user) { where(user_id: user.id) }
  # Returns list of public boards
  # @return [Set<Board>] the list of public boards
  scope :public_boards, -> { where(public: true) }
  # Returns list of private boards
  # @return [Set<Board>] the list of private boards
  scope :private_boards, -> { where(public: false) }
  # @!method membership_and_public_boards(user)
  #   Returns list of boards where +user+ is member or board is public
  #   @param [User] user the current user
  #   @return [Set<Board>] the list of public and boards where user member
  scope :membership_and_public_boards, lambda { |user|
    left_outer_joins(:memberships).where('boards.public = ? OR memberships.user_id = ?', true, user.id).distinct
  }
  # @!method filter(filter, user)
  #   Filters boards in accordance with the transmitted parameters and returns an appropriate collection
  #   @param [String] filter the word which indecates which sope will be used
  #   @param [User] user the current user which uses filter
  #   @return [Set<Board>] the list of appropriate boards.
  scope :filter, lambda { |filter, user|
    case filter
    when 'my'
      user_boards(user)
    when 'private'
      private_boards.user_boards(user)
    when 'public'
      public_boards
    else
      membership_and_public_boards(user)
    end
  }
  # @!method sorting(sort_order)
  #   Sorting boards by created_at column in according to +sort_order+ parameter.
  #   @param [String] sort_order the order for sorting 'asc' or 'desc'
  #   @return [Set<Board>] the list of sorted boards.
  scope :sorting, lambda { |sort_order|
    sort_order = %w[asc desc].include?(sort_order) ? sort_order : 'asc'
    order(created_at: sort_order)
  }

  self.per_page = 10

  # Returns last position of the column in the board
  # @return [Integer] the last position of the column in the board
  def last_column_position
    columns.maximum(:position)
  end
end
