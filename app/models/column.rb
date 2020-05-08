class Column < ApplicationRecord
  belongs_to :board
  belongs_to :user
  validates :name, length: { within: 2..50 }
  validates :position, uniqueness: { scope: :board }

  before_validation :set_default_name, :set_position, on: :create 

  private
  def set_default_name
    self.name = "Default Title"
  end

  def set_position 
    self.position = self.board.last_column_position.to_i + 1
  end

  
end
