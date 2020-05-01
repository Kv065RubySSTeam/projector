class UsersController < ApplicationController
  def index
    @users = User.search(params[:search])

    respond_to do |foramt|
      foramt.json { render json: @users }
    end
  end
end
