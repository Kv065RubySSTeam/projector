class UsersController < ApplicationController
  # Return users.json
  # @action GET
  # @url /users
  # @return [JSON] includes all users
  def index
    @users = User.search(params[:search]).limit(10)

    respond_to do |f|
      f.json { render json: @users }
    end
  end

  # Show current_user
  # @action GET
  # @url /user
  # @return [User]
  def show; end
end
