class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :boards, through: :memberships
  validates :email, uniqueness: true
  
  has_one_attached :avatar

  validates :first_name, length: { within: 1..100 }
  validates :last_name, length: { within: 1..100 }
  validates :avatar, content_type:
    { in: ['image/png', 'image/jpg', 'image/jpeg'],
      message: "format is wrong, please use JPG, PNG or JPEG" }
  devise :database_authenticatable,
         :registerable, :recoverable, :validatable,
         :async,:confirmable
  attribute :remove_avatar, :boolean,  default: false
  after_save :purge_avatar, if: :remove_avatar
  
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
  
  has_many :administrated_boards, -> { where(memberships: { admin: true }) }, class_name: 'Board',
                                                                              through: :memberships, 
                                                                              source: :board

  scope :search, lambda { |user|
    where("concat(' OR ', LOWER(first_name), LOWER(last_name), LOWER(email)) LIKE LOWER(?)", "%#{user}%")
  }
  
  private
  def purge_avatar
    avatar.purge_later
  end
end
