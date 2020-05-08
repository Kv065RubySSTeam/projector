class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable, :validatable,
         :confirmable, :recoverable

  has_many :memberships, dependent: :destroy
  has_many :boards, through: :memberships
  validates :email, uniqueness: true

  has_many :administrated_boards, -> { where(memberships: { admin: true }) }, class_name: 'Board',
                                                                              through: :memberships, 
                                                                              source: :board

  scope :search, lambda { |user|
    where("concat(' OR ', LOWER(first_name), LOWER(last_name), LOWER(email)) LIKE LOWER(?)", "%#{user}%")
  }
end
