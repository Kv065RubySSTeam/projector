# frozen_string_literal: true

class User < ApplicationRecord
  has_many :boards, dependent: :nullify
  devise :database_authenticatable,
         :registerable, :validatable,
         :confirmable, :recoverable

  has_many :memberships, dependent: :destroy
  has_many :boards, through: :memberships
  validates :email, uniqueness: true

  has_many :administrated_boards, -> { where(memberships: { admin: true }) }, class_name: 'Board',
                                                                              through: :memberships,
                                                                              source: :board

  scope :search, ->(email) { where('email LIKE ?', "%#{email}%") }
end
