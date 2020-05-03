class User < ApplicationRecord
  before_save :capitalize_first_last_name

  has_many :boards, dependent: :nullify
  has_one_attached :avatar

  EMAIL_REGEX = /.+@.+\.[a-z]{1,5}([a-z]{1,5})?/i

  validates :email, length: { within: 5..255 }, 
                  format: { with: EMAIL_REGEX }
  validates :first_name, length: { within: 3..100 }
  validates :last_name, length: { within: 3..100 }
  validate :correct_avatar_type

  devise :database_authenticatable, 
         :registerable, :validatable,
         :confirmable, :recoverable

  private

  def capitalize_first_last_name
    self.first_name = first_name.downcase.capitalize
    self.last_name = last_name.downcase.capitalize
  end

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
