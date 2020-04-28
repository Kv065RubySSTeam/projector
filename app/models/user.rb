class User < ApplicationRecord
  has_many :boards, dependent: :nullify
  devise :database_authenticatable, 
         :registerable, :validatable,
         :confirmable, :recoverabl

  has_many :memberships
  has_many :boards, through: :memberships
  has_many :administrated_boards, -> { where(admin: true) }, class_name: 'Board', through: :membership
end
