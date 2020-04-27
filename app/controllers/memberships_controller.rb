class MembershipsController < ApplicationController
  before_action :current_board

  def create
    @membership = Membership.new(params[:membership])
    unless @membership&.nil?
      @membership.save!
    end
  end

  def update
    @user = Membership.find_by_id(params[:user_id])
    unless @user.nil? && current_user.board_admin
      @user.admin = true
      @user.save!
    end
  end

  def destroy
    @membership.delete! unless @membership.nil? && curren_user.board_admin
  end

  private

  def current_board
    @board = Board.find_by_id(params[:id])
  end
end