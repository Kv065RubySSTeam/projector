# frozen_string_literal: true

module Notifications
  class AddAssigneeNotificationService < Notifications::CreateService
    protected

    def notification_type
      'add_assignee_notification'
    end

    def recievers
      [notificationable.assignee, notificationable.user].compact.uniq
    end
  end
end
