class MembershipsController < ApplicationController
  before_action :find_board!
  before_action :find_user!
  before_action :authorize!

  def create
    @board.users << @user
  rescue ActiveRecord::RecordInvalid => e
    # head 404
    # flash[:error] = e.message
    render json: { error: e.message }.to_json, status: 404
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
      head 401
    end
  end
end
