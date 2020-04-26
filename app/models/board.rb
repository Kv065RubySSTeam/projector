class Board < ApplicationRecord
  belongs_to :user 

 validates :title, length: { minimum: 5 }
 validates :description, length: { minimum: 5 }
 validates :user_id, presence: true    

  scope :search, ->(input) { where("title ilike ? or description ilike ?", "%#{input}%", "%#{input}%") }

  scope :board_type, ->(boolean) { where(is_public: boolean) }
  scope :user_boards, ->(user_id) { where(user_id: user_id) }

end
