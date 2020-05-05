class Column < ApplicationRecord
  belongs_to :board
  has_many :cards, dependent: :destroy
  validates :name, length: { within: 2..50 }, presence: true
  validates :board, presence: true
  scope :last_position, -> { maximum(:position) }
end
