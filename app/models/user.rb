class User < ApplicationRecord
  has_many :boards, dependent: :nullify
  has_many :columns, dependent: :destroy
<<<<<<< HEAD
  has_many :cards, dependent: :destroy
=======
>>>>>>> 2ff5adf... refactoring column and board model, column controller, services
  devise :database_authenticatable,
         :registerable, :validatable,
         :confirmable, :recoverable
end
