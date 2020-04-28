class User < ApplicationRecord

  has_many :boards, dependent: :nullify
  devise :database_authenticatable, 
         :registerable, :validatable,
         :confirmable, :recoverable

end

