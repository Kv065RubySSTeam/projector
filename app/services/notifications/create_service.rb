module Notifications
  class CreateService < ApplicationService
    attr_accessor :notification_type, :card

    def initialize(notification_type, card)
      @notification_type = notification_type
      @card = card
    end

    def call
      notification_type.camelize.constantize
                              .create(notificationable: card)
      send_email
    end

    private

    def send_email
      card.notification_receivers.each do |user|
        CardMailer.with(card: card, user: user).send(notification_type.to_sym)
                                        .deliver_later if user.receive_emails
      end
    end

  end
end
