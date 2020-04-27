class Board < ApplicationRecord
  belongs_to :user 

 validates :title, length: { minimum: 5 }
 validates :description, length: { minimum: 5 }
 validates :user_id, presence: true    

  scope :search, ->(input) { where("title ilike ? or description ilike ?", "%#{input}%", "%#{input}%") }

  scope :public_boards, -> { where(is_public: true) }
  scope :private_boards, -> { where(is_public: false) }

  scope :user_boards, -> { where(user_id: 1) }


  scope :filter, ->(filter) do
    case filter
      when "my"
        user_boards
      when "private"
        private_boards
      when "public"
        public_boards
    end
  end
end
