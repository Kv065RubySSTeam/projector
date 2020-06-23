# frozen_string_literal: true

module Notifications
  class AddCommentNotificationService < Notifications::CreateService
    protected

    def notification_type
      'add_comment_notification'
    end

    def recievers
      [card.assignee, card.user].compact.uniq
    end

    def card
      notificationable.card
    end
  end
end
