class Comment < ApplicationRecord
  include Discard::Model
  
  belongs_to :user
  belongs_to :card
  validates :body, presence: true, length: { maximum: 1000 }

  scope :kept, -> { undiscarded.joins(:card).merge(Card.kept) }

  self.per_page = 5
end
