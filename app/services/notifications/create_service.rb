# frozen_string_literal: true

module Notifications
  class CreateService < ApplicationService
    attr_accessor :notificationable

    def initialize(notificationable = nil)
      @notificationable = notificationable
    end

    def call
      recievers.each do |user|
        notification_type.camelize.constantize
                         .create(notificationable: notificationable, user: user)
        send_email(user) if user.receive_emails
      end
    end

    protected

    def send_email(user)
      NotificationMailer.with(notificationable: notificationable, user: user)
                        .send(notification_type.to_sym)
                        .deliver_later
    end

    def notification_type
      raise 'Not implemented'
    end

    def recievers
      raise 'Not implemented'
    end
  end
end
