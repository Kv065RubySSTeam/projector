class NotificationsController < ApplicationController

  def index
    @notifications = Notification.available_for(current_user)
                 .order('created_at DESC')
    paginate_notifications
  end
  

  protected

  def paginate_notifications
    if @load_new
      @notifications = @notifications.limit(Notification.per_page * params[:page].to_i)
      @current_page = params[:page].to_i
      @total_pages = (Notification.available_for(current_user).count() / Notification.per_page.to_f).ceil
    else
      @notifications = @notifications.paginate(page: params[:page])
      @current_page = @notifications.current_page
      @total_pages = @notifications.total_pages
    end
  end
end
