# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
                                 .includes(:user, :notificationable)
                                 .paginate(page: params[:page])
                                 .order(created_at: :desc)
  end
end
