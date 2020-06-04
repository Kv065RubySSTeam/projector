class Board < ApplicationRecord
  belongs_to :user
  has_many :columns, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :title, length: { within: 5..50 }
  validates :description, length: { within: 5..255 }
  validates :user, presence: true

  scope :search, ->(input) { where("title ilike ? or description ilike ?",
                                   "%#{input}%",
                                   "%#{input}%") }
  scope :user_boards, ->(user) { where(user_id: user.id) }
  scope :public_boards, -> { where(public: true) }
  scope :private_boards, -> { where(public: false) }
  scope :membership_and_public_boards, ->(user) do
    left_outer_joins(:memberships).where("boards.public = ? OR memberships.user_id = ?", true, user.id)
  end
  scope :filter, ->(filter, user) do
    case filter
    when "my"
      user_boards(user)
    when "private"
      private_boards.user_boards(user)
    when "public"
      public_boards
    else
      membership_and_public_boards(user)
    end
  end
  scope :sorting, -> (sort_order) do
    sort_order = %w[asc desc].include?(sort_order) ? sort_order : 'asc'
    order(created_at: sort_order)
  end
  self.per_page = 10

  def last_column_position
    columns.maximum(:position)
  end
end
