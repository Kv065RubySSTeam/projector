class MembershipsController < ApplicationController
  before_action :find_board!
  before_action :find_user!
  before_action :authorize!
  before_action :find_membership!, only: %i[admin]

  def create
    @membership = @board.memberships.create(user: @user)
    if @membership.errors.empty?
      render json: {}, status: 200
    else
      render json: { error: @membership.errors.full_messages }, status: 422
    end
  end

  def admin
    @membership.admin? ? @membership.remove_admin! : @membership.admin!
    if @membership.errors.empty?
      render json: {}, status: 200
    else
      render json: {}, status: 422
    end
  end

  private

  def find_board!
    @board = Board.find(params[:board_id])
  end

  def find_membership!
    @membership = @board.memberships.find_by!(user: @user)
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
