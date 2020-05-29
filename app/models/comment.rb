class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :card
  has_many :emojis, as: :emojible, dependent: :destroy
  validates :body, presence: true, length: { maximum: 1000 }

  self.per_page = 5
end
