class MembershipsController < ApplicationController
  before_action :current_board

  def create; end

  def update; end

  def destroy; end

  private

  def current_board
    @board = Board.find_by_id(params[:id])
  end
end
