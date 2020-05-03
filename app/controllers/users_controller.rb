class UsersController < ApplicationController
  def index
    @user = User.search(params[:search])
