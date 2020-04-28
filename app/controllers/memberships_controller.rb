class MembershipsController < ApplicationController
  before_action :load_board
  before_action :check_user_permission

  def create
    @user = User.find(params[:user_id])
    if @board.memberships.create(user_id: user.id, admin: false) 
      flash[:success] = 'New user is added!'
    else 
      flash[:danger] = 'New user was not added!'
      redirect_back fallback_location: root_path
    end
  end

  def update
    @membership = @board.memberships.where(user_id: params[:user_id]).first
    @membership.update_attribute('admin', true)
  end

  private

  def load_board
    @board = Board.find(params[:board_id])
  end

  def check_user_permission
    if current_user.memberships.exists?(board_id: @board.id, admin: true)
      flash[:danger] = 'You are not admin for this board'
      redirect_back fallback_location: root_path
    end
  end

  def board_admin(board)
    administrated_boards.exists?(id: board.id)
  end
end
