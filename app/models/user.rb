class User < ApplicationRecord
  has_many :boards, dependent: :nullify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
