class User < ApplicationRecord
  has_many :boards, dependent: :nullify
  has_one_attached :avatar

  validates :first_name, length: { within: 1..100 }
  validates :last_name, length: { within: 1..100 }
  validate :correct_avatar_type

  devise :database_authenticatable, 
         :registerable, :validatable,
         :confirmable, :recoverable

  private
  def correct_avatar_type
    return unless avatar.attached?
    if !avatar.content_type.in?(%w(image/jpeg image/png))
      errors.add(:avatar, 'must be a JPEG or PNG')
    end
    if avatar.blob.byte_size >= 1.megabyte
      errors.add(:avatar, "avatar is too big, maximum size - 1 mb")
    end
  end
end
