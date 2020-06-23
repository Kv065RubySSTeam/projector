# frozen_string_literal: true

# Membership can be created/admined
# Membership can be viewed on Board page
# @note Response to JSON only
class MembershipsController < ApplicationController
  # @!group Callbacks
  before_action :find_board!
  before_action :find_user!
  before_action :membership_authorize!
  before_action :find_membership!, only: %i[admin]
  # @!endgroup

  respond_to :json

  # @note Membership can be created only if user has permissions for board,
  # and he is admin at this board
  # Create a Membership on the current board, from the current user
  # @action POST
  # @url /boards/:board_id/memberships
  # @return [JSON] with success status or error message with status Unprocessable Entity
  # and empty object
  def create
    @membership = @board.memberships.create(user: @user)
    if @membership.errors.empty?
      render json: {}, status: 200
    else
      render json: { error: @membership.errors.full_messages }, status: 422
    end
  end

  # @note Membership can be updated only if user has permissions for board and
  # he is admin at this board
  # Update membership admin value
  # @action PUT
  # @url /boards/:board_id/memberships/:id/admin
  # @required [Boolean] admin
  # @return [JSON] with success message or error's with status Unprocessable Entity
  # and empty object
  def admin
    @membership.admin? ? @membership.remove_admin! : @membership.admin!
    if @membership.errors.empty?
      render json: {}, status: 200
      # respond_to :js
    else
      render json: {}, status: 422
    end
  end

  private

  # @!group Callbacks
  # @note Used for create and admin
  # Find board through query params
  # @return [Board]
  def find_board!
    @board = Board.find(params[:board_id])
  end

  # Find membership through query params
  # @return [Membership]
  def find_membership!
    @membership = @board.memberships.find_by!(user: @user)
  end

  # Find user through query params
  # @return [User]
  def find_user!
    @user = User.find(params[:id])
  end

  # Find user at the board and check if he is an admin at this board.
  # If user not found,
  # @return [JSON] with error's message with status Unauthorized
  def membership_authorize!
    render json: { error: 'Unauthorize' }, status: 401 unless current_user.administrated_boards.exists?(@board.id)
  end
end
