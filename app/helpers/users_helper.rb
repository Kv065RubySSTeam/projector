# frozen_string_literal: true

module UsersHelper
  # Check if user has an avatar and return it
  # @param user
  # @return [String] *.jpg
  def get_avatar(user)
    if user.avatar.attached?
      user.avatar
    else
      '/images/placeholder.jpg'
    end
  end

  # Return user full name
  # @param user
  # @return [String] full name
  def get_full_user_name(user)
    [user.first_name, user.last_name].join(' ')
  end
end
