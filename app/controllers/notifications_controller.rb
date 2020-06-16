class NotificationsController < ApplicationController

  def index
    @notifications = Notification.available_for(current_user)
                 .order('created_at DESC')
    paginate_notifications
  end

  protected

  def paginate_notifications
    @notifications = @notifications.paginate(page: params[:page])
    @current_page = @notifications.current_page
    @total_pages = @notifications.total_pages
  end

end
