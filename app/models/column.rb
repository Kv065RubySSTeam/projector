class Column < ApplicationRecord
  belongs_to :board
  validates :name, length: { within: 2..50 }, presence: true

  scope :last_position, -> { maximum(:position) }
end
