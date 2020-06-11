module Notifications
  class CreateService < ApplicationService
    attr_accessor :type, :card

    def initialize(type, card)
      @type, @card = type, card
    end

    def call
      case type
      when "update_card_position"
        MoveCardNotification.create(card: card)
        send_email
      when "added_comment"
        AddCommentNotification.create(card: card)
        send_email
      when "new_assignee"
        AddAssigneeNotification.create(card: card)
        send_email
      end
    end

    private

    def send_email
      card.notification_receivers.each do |user|
        CardMailer.with(card: card, user: user).send(type.to_sym)
                                  .deliver_later if user.receive_emails
      end
    end

  end
end
