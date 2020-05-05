class UsersController < ApplicationController
  def show
    current_user
  end

  def delete_avatar
    current_user.avatar.purge
    redirect_to user_path
  end
end
