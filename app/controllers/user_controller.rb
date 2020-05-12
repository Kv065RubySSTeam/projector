class UserController < ApplicationController
  def index
    @users = User.search(params[:search]).limit(10)

    respond_to do |f|
      f.json { render json: @users }
    end
  end
end
