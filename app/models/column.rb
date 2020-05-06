class Column < ApplicationRecord
  belongs_to :board
  belongs_to :user
  validates :name, length: { within: 2..50 }, presence: true
  validates :board, presence: true
  
  scope :last_position, -> { maximum(:position) }

  before_validation :set_default_name, :set_position, on: :create 

  private
  def set_default_name
    self.name = "Default Title"
  end

  def set_position
    self.position = self.position.blank? ? 1 : self.position + 1
  end
end
