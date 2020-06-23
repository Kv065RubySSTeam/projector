# frozen_string_literal: true

module Notifications
  class MoveCardNotificationService < Notifications::CreateService
    protected

    def notification_type
      'move_card_notification'
    end

    def recievers
      [notificationable.assignee, notificationable.user].compact.uniq
    end
  end
end
