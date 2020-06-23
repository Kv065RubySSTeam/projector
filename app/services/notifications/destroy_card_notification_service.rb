# frozen_string_literal: true

module Notifications
  class DestroyCardNotificationService < Notifications::CreateService
    protected

    def notification_type
      'destroy_card_notification'
    end

    def recievers
      board.users
    end

    def board
      notificationable.column.board
    end
  end
end
