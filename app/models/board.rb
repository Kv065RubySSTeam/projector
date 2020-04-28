class Board < ApplicationRecord
  belongs_to :user 

  validates :title, length: { minimum: 5 }
  validates :description, length: { minimum: 5 }
  validates :user_id, presence: true    

  scope :search, ->(input) { where("title ilike ? or description ilike ?", "%#{input}%", "%#{input}%") }
  scope :user_boards, ->(user) { where(user_id: user.id) }
  scope :public_boards, -> { where(public: true) }
  scope :private_boards, -> { where(public: false) }
  scope :pagination, ->(page_params) { paginate(page: page_params, per_page: 10).order('created_at DESC') }
  

  scope :filter, ->(filter,user) do
    case filter
      when "my"
        user_boards(user)
      when "private"
        private_boards.user_boards(user)
      when "public"
        public_boards
      else
        self.all
    end
  end
end
