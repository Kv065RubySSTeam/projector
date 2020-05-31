class User < ApplicationRecord
  has_many :columns, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :assigned_card, class_name: 'Card'
  has_many :comments, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :boards, through: :memberships
  has_many :likes, dependent: :destroy
  has_one_attached :avatar

  validates :email, uniqueness: true
  validates :email, uniqueness: true
  validates :first_name, length: { within: 1..100 }
  validates :last_name, length: { within: 1..100 }
  validates :avatar, content_type:
    { in: ['image/png', 'image/jpg', 'image/jpeg'],
      message: "format is wrong, please use JPG, PNG or JPEG" }

  devise :database_authenticatable,
         :registerable, :recoverable, :validatable,
         :async, :confirmable,
         :omniauthable, omniauth_providers: %i[facebook]

  attribute :remove_avatar, :boolean,  default: false
  after_save :purge_avatar, if: :remove_avatar

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']
        user.email = data['email'] if user.email.blank?
      end
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  has_many :administrated_boards, -> { where(memberships: { admin: true }) }, class_name: 'Board',
                                                                              through: :memberships,
                                                                              source: :board

  scope :search, lambda { |user|
    where("concat_ws('OR', LOWER(email), LOWER(first_name), LOWER(last_name)) LIKE LOWER(?)", "%#{user}%")
  }

  private
  def purge_avatar
    avatar.purge_later
  end
  
  protected
  def confirmation_required?
    false
  end

end
