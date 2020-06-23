# frozen_string_literal: true

class User < ApplicationRecord
  # @!group Associations
  has_many :columns, dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :assigned_cards, class_name: 'Card'
  has_many :comments, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :boards, through: :memberships
  has_many :likes, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one_attached :avatar
  # @!endgroup

  # @!group Validations
  validates :email, uniqueness: true
  validates :email, uniqueness: true
  validates :first_name, length: { within: 1..100 }
  validates :last_name, length: { within: 1..100 }
  validates :avatar, content_type:
    { in: ['image/png', 'image/jpg', 'image/jpeg'],
      message: 'format is wrong, please use JPG, PNG or JPEG' }
  # @!endgroup

  # Include default devise modules. Others available are:
  # :confirmable, :omniauthable, :recoverable
  devise :database_authenticatable,
         :registerable, :recoverable, :validatable,
         :async, :confirmable,
         :omniauthable, omniauth_providers: %i[facebook]

  attribute :remove_avatar, :boolean, default: false
  after_save :purge_avatar, if: :remove_avatar

  # @see https://www.rubydoc.info/github/plataformatec/devise/Devise%2FModels%2FAuthenticatable:send_devise_notification
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # @see https://rubydoc.info/github/cofiem/aptness/master/User#new_with_session-class_method
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.facebook_data'] && session['devise.facebook_data']['extra']['raw_info']
        user.email = data['email'] if user.email.blank?
      end
    end
  end

  # @see https://rubydoc.info/github/cofiem/aptness/master/User#from_omniauth-class_method
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
    end
  end

  # Return user full name
  # @return [String]
  def full_name
    "#{first_name} #{last_name}"
  end

  # @!method administrated_boards
  #   Administrated boards checks if user is admin on current board
  # @return [Membership] where admin: true
  has_many :administrated_boards, -> { where(memberships: { admin: true }) }, class_name: 'Board',
                                                                              through: :memberships,
                                                                              source: :board

  # @!method
  #   Search user by email, first_name and last_name
  #   @return [User]
  scope :search, lambda { |user|
    where("concat_ws('OR', LOWER(email), LOWER(first_name), LOWER(last_name)) LIKE LOWER(?)", "%#{user}%")
  }

  scope :with_active_reset_password, lambda { |token|
                                       where('reset_password_sent_at > ?', Time.now - 4 * 3600)
                                         .find_by!(reset_password_token: token)
                                     }

  scope :with_enabled_email_receiving, -> { where(receive_emails: true) }

  def is_admin?(board)
    memberships.where(board: board)[0].admin
  end

  private

  # Directly purges the attachment (i.e. destroys the blob and attachment and deletes the file on the service).
  # @return [Avatar]

  def purge_avatar
    # Purges the attachment through the queuing system.
    avatar.purge_later
  end

  protected

  # Callback to overwrite if confirmation is required or not.
  # @see https://www.rubydoc.info/github/plataformatec/devise/Devise%2FModels%2FConfirmable:confirmation_required%3F
  # @return [Boolean]
  def confirmation_required?
    false
  end
end
