class MembershipsController < ApplicationController
  before_action :get_board!
  before_action :get_user!
  before_action :check_user_permission!

  def index
    @memberships = Memberships.all
  end

  def create
    if !@board.memberships.exists?(user: @user)
      @board.users << @user
      flash[:success] = 'New user is added!'
    else
      flash[:danger] = 'New user was not added!'
      redirect_back fallback_location: root_path
    end
  end

  def admin
    if @board.memberships.exists?(user: @user, admin: false)
      @user.memberships.update(admin: true)
      flash[:success] = 'Success'
    else
      flash[:danger] = 'Danger'
    end
  end

  private

  def get_board!
    @board = Board.find(params[:board_id])
  end

  def get_user!
    @user = User.find(params[:user_id])
  end

  def check_user_permission!
    if current_user.memberships.exists?(board_id: @board.id, admin: true)
      flash[:success] = 'Success'
    else
      flash[:danger] = 'You are not admin for this board'
      redirect_back fallback_location: root_path
    end
  end

  def board_admin(board)
    current_user.administrated_boards.exists?(id: board.id)
  end
end