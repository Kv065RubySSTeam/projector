class MembershipsController < ApplicationController
  before_action :find_board!
  before_action :find_user!
  before_action :authorize!

  def create
    @board.users << @user
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }.to_json, status: 422
  end

  def admin
    @user.memberships.update(admin: true)
    if !@user.memberships.empty?
      render json: {}, status: 200
    else
      render json: {}, status: 422
    end
  end

  private

  def find_board!
    @board = Board.find(params[:board_id])
  end

  def find_user!
    @user = User.find(params[:user_id])
  end

  def authorize!
    unless current_user.administrated_boards.exists?(@board.id)
      render json: { error: 'Unauthorize' }, status: 401
    end
  end
end
