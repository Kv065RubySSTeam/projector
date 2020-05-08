class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :card
  validates :name, length: { within: 2..255 }
end
