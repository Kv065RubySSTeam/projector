class User < ApplicationRecord
  has_many :boards, dependent: :nullify
  devise :database_authenticatable,
         :registerable, :recoverable, :validatable,
         :async,:confirmable

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

end
