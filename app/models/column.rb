class Column < ApplicationRecord
  belongs_to :board
  belongs_to :user
  has_many :cards, dependent: :destroy
  validates :name, length: { within: 2..50 }, presence: true

  scope :last_position, -> { maximum(:position) }
end
