class User < ApplicationRecord
  has_many :boards, dependent: :nullify
  has_many :columns
  devise :database_authenticatable,
         :registerable, :validatable,
         :confirmable, :recoverable
end
