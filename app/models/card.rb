class Card < ApplicationRecord
  include Discard::Model
  include PgSearch::Model

  belongs_to :column
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id", optional: true
  has_many :comments, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :likes, as: :likable, dependent: :destroy
  validates :title, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :column }

  # ActionText
  has_rich_text :body

  # Audited gem for logs
  audited except: :position
  audited associated_with: :rich_text_body

  acts_as_taggable_on :tags

  # @!method available_for
  # @param [User]
  # @note Returns cards, available for user
  # @example
  #   Card.available_for(current_user)
  # @return [Set<Card>] cards available for user
  scope :available_for, -> (user) { joins(column: { board: :memberships })
                                  .where(memberships: { user_id: user.id }) }

  # @!method by_board
  # @param [String] - title of the board
  # @note Returns cards filtered by board
  # @example
  #   Card.by_board('title')
  # @return [Set<Card>] cards from the concrete board
  scope :by_board, -> (title) { joins(column: :board).where(boards: { title: title }) }

  # @!method filter_by_board
  # @param [String] - title of the board
  # @note Returns cards filtered by board
  # @example
  #   Card.filter_by_board('title')
  # @return [Set<Card>] cards from the concrete board
  scope :filter_by_board, ->(title) { title ? by_board(title) : all }

  # @!method assigned
  # @param [User] user, to which cards are assigned to
  # @note Returns cards assigned to the concrete user
  # @example
  #   Card.assigned(user)
  # @return [Set<Card>] cards, assigned to the concrete user
  scope :assigned, ->(user) { where(assignee: user) }

  # @!method created
  # @param [User] user, to which cards are created by
  # @note Returns cards created by concrete user
  # @example
  #   Card.created(user)
  # @return [Set<Card>] cards, created by the concrete user
  scope :created, ->(user) { where(user: user) }
  scope :search, ->(input) { input ? search_everywhere(input) : all }

  # @!method filter
  # @param [filer_item, user] item to filter by
  # @note Returns cards filtered by passed item
  # @example
  #   Card.filter('all', user)
  #   Card.filter('deleted', user)
  #   Card.filter('assigned', user)
  #   Card.filter('created', user)
  # @return [Set<Card>] cards, filtered by passed param
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

  # @!method pg_search_scope
  # @param [String] input string
  # @note Searches cards by card title, card body, creator first_name, creator last_name
  # @example
  #   Card.search_everywhere('Surname')
  # @return [Set<Card>] that matches input inserted
  pg_search_scope :search_everywhere,
  against: [:title],
  associated_against: {
    assignee: [:first_name, :last_name],
    user: [:first_name, :last_name],
    rich_text_body: [:body]
  },
  using: {
    tsearch: {
      prefix: true,
      dictionary: "english"
    }
  }

  before_validation(on: :create) do
    self.position = self.column.last_card_position.to_i + 1
  end

  self.per_page = 10

  # @!method assign!(user)
  #   Updates assignee of current card with user
  # @param [User] member of current board
  # @note Is being called at card - add assignee button
  # @example
  #   assign!(user)
  # @return [Boolean] whether the attribute was updated successfully
  def assign!(user)
    update(assignee: user)
  end

  # @!method remove_assign!
  # @note Updates assignee of current card to nil
  # @example
  #   remove_assign!
  # @return [Boolean] whether the attribute was deleted successfully
  def remove_assign!
    update(assignee: nil)
  end

  # @!method notification_receivers
  # @note Returns list of users, assigned to the concret card + creator
  # @example
  #   card.notification_receivers
  # @return [Set<User>] cards, created by the concrete user
  def notification_receivers
    [self.user, self.assignee].compact
  end

end
