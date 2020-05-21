module UsersHelper
  
  def get_avatar(user)
    if user.avatar.attached?
      user.avatar
    else
      '/images/placeholder.jpg'
    end
  end

  def get_full_user_name(user)
    [user.first_name, user.last_name].join(" ")
  end
  
end
