class Card < ApplicationRecord
  belongs_to :column
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings
  validates :title, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :column }
  acts_as_taggable_on :tags
  
  before_validation(on: :create) do
    self.position = self.column.last_card_position.to_i + 1
  end
end
