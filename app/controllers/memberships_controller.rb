class MembershipsController < ApplicationController
  before_action :find_board!
  before_action :find_user!
  before_action :authorize!

  def create
    @board.users << @user
    flash[:success] = 'Membership Success'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
  end

  def admin
    @user.memberships.update(admin: true)
    if @user.memberships.empty?
      flash[:success] = 'Admin Success'
    else
      flash[:error] = 'Admin Error'
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
    unless current_user.administrated_boards.exists?(@board.id)
      render file: 'public/401.html', layout: true, status: 401
    end
  end
end
