class MembershipsController < ApplicationController
  before_action :find_board!
  before_action :find_user!
  before_action :board_admin!

  def create
    @board.users << @user
  rescue ActiveRecord::RecordNotSaved => e
    flash[:danger] = e.to_s
  end

  def admin
    if @user.errors.empty?
      @user.memberships.update(admin: true)
      flash[:success] = 'Success'
    else
      flash[:danger] = 'Error'
    end
  end

  private

  def find_board!
    @board = Board.find(params[:board_id])
  end

  def find_user!
    @user = User.find(params[:user_id])
  end

  def board_admin!
    current_user.administrated_boards.exists?(@board.id)
  end
end
