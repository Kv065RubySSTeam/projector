class MembershipsController < ApplicationController
  before_action :find_board!
  before_action :find_user!
  before_action :authorize!

  def create
    @board.users << @user
  rescue ActiveRecord::RecordNotSaved => e
    flash[:danger] = e.to_s
  end

  def admin
    @user.memberships.update(admin: true)
    if @user.memberships.empty?
      flash[:success] = 'Success'
    else
      flash[:danger] = 'Error'
    end
  end

  private

  def find_board!
    @board = Board.find(params[:id])
  end

  def find_user!
    @user = User.find(params[:user_id])
  end

  def authorize!
    # 401 Error - check
    current_user.administrated_boards.exists?(@board.id)
  end
end
