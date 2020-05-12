class Column < ApplicationRecord
  DEFAULT_TITLE = 'Default Title'

  belongs_to :board
  belongs_to :user
  validates :name, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :board }
end
