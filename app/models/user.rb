class User < ApplicationRecord
  devise :database_authenticatable, 
         :registerable, :validatable,
         :confirmable, :recoverable

  has_many :memberships, dependent: :destroy
  has_many :boards, through: :memberships
  has_many :administrated_boards, -> { where(admin: true) }, class_name: 'Board', through: :membership
end
