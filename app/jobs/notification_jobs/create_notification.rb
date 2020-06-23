# frozen_string_literal: true

module NotificationJobs
  class CreateNotification < ApplicationJob
    queue_as :default

    def perform(type, notificationable)
      "Notifications::#{type}".constantize.call(notificationable)
    end
  end
end
