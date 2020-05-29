class Card < ApplicationRecord
  belongs_to :column
  belongs_to :user
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id", optional: true
  has_many :comments, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :emojis, as: :emojible, dependent: :destroy
  validates :title, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :column }

  acts_as_taggable_on :tags

  scope :available_for, -> (user) {joins(column: {board: :memberships})
                                  .where(memberships: {user_id: user.id})}
  scope :search, ->(input) { joins(:user).where("cards.title ilike :search
                                                or cards.body ilike :search
                                                or users.first_name ilike :search
                                                or users.last_name ilike :search ",
                                                search: "%#{input}%") }
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
