module UsersHelper
  def day_and_time(user)
    user.created_at.strftime("%B %d at %I:%M %P")
  end
end
