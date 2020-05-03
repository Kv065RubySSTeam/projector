class User < ApplicationRecord
  has_many :boards, dependent: :nullify
  devise :database_authenticatable, 
         :registerable, :validatable,
         :confirmable, :recoverabl

  has_many :memberships
  has_many :boards, through: :memberships
end
