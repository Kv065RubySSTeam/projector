class User < ApplicationRecord
  has_many :boards, dependent: :nullify
  devise :database_authenticatable, 
         :registerable, :validatable,
         :confirmable, :recoverabl

  has_many :memberships, dependent: :destroy
  has_many :boards, through: :memberships
  has_many :administrated_boards, -> { where(admin: true) }, class_name: 'Board', through: :membership

  scope :search, ->(email) { where('email LIKE ?', "%#{email}%") }
end
