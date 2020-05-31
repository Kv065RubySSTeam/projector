class Card < ApplicationRecord
  include Discard::Model
  include PgSearch::Model
  pg_search_scope :search_everywhere,
    against: [:title, :body], 
    associated_against: {
    assignee: [:first_name, :last_name], user: [:first_name, :last_name] },
    using: { tsearch: { prefix: true } }

  scope :search, ->(input) { input ? search_everywhere(input) : all }

  belongs_to :column
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id", optional: true
  has_many :comments, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings
  validates :title, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :column }

  acts_as_taggable_on :tags

  scope :available_for, -> (user) { joins(column: { board: :memberships })
                                  .where(memberships: { user_id: user.id }) }
  scope :by_board, -> (title) { joins(column: :board).where(boards: { title: title }) }
  scope :filter_by_board, ->(board_title) { board_title ? by_board(board_title) : all }
  scope :assigned, ->(user) { where(assignee_id: user.id) }
  scope :created, ->(user) { where(user_id: user.id) }
  scope :filter, ->(filter, user) do 
    case filter
    when "all"
      with_discarded
    when "deleted"
      with_discarded.discarded
    when "assigned"
      assigned(user)
    when "created"
      created(user)
    else
      all
    end
  end

  before_validation(on: :create) do
    self.position = self.column.last_card_position.to_i + 1
  end

  self.per_page = 10

  def assign!(user)
    update(assignee: user)
  end

  def remove_assign!
    update(assignee: nil)
  end
end
