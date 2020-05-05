class Column < ApplicationRecord
  belongs_to :board
  validates :name, length: { within: 2..50 }, presence: true
  validates :board, presence: true
end
