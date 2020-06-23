# frozen_string_literal: true

# Column can be created/updated/deleted
# @note Response to JS only
class ColumnsController < ApplicationController
  # @!group Permissions
  load_and_authorize_resource :board
  load_and_authorize_resource :column, through: :board
  # @!endgroup

  # @!group Callbacks
  before_action :find_board!
  before_action :find_column!, only: %i[update destroy]
  before_action :flash_clear
  # @!endgroup

  respond_to :js

  # @note Column can be created only if user has permissions for column's board
  # Create a column with {Column::DEFAULT_TITLE default title} and
  # automatically calculated position
  # on the current board from the current user
  # @action POST
  # @url /boards/:board_id/columns
  # @return [Flash, Column] flash with success message or error's string
  #   and column object
  def create
    @column = Columns::CreateService.call(@board, current_user)
    if @column.errors.empty?
      flash[:success] = 'Column was successfully created.'
    else
      flash[:error] = @column.errors.full_messages.join("\n")
      render status: 422
    end
  end

  # @note Column can be updated only if user has permissions for column's board
  # Update column title
  # @action PATCH
  # @url /boards/:board_id/columns/:id
  # @required [String] title
  # @return [Flash, Column, String] flash with success message or error's string,
  #   previous title string and column object
  def update
    @previousName = @column.name
    if @column.update(update_param)
      flash[:success] = 'Column was successfully updated.'
    else
      flash[:error] = @column.errors.full_messages.join("\n")
      render status: 422
    end
  end

  # @note Column can be deleted only if user has permissions for column's board
  # Permanently delete the column
  # @action DELETE
  # @url /boards/:board_id/columns/:id
  # @return [Flash, Column] flash with success message or error's string,
  #   and column object
  def destroy
    if @column.destroy
      flash[:success] = 'Column was successfully deleted!'
    else
      flash[:error] = @column.errors.full_messages.join("\n")
      render status: 422
    end
  end

  private

  # @!group Callbacks
  # @note Used for update and destroy column
  # Find column through query params
  # @return [Column]
  def find_column!
    @column = @board.columns.find(params[:id])
  end

  # @note Used for create/update/destroy
  # Find board through query params
  # @return [Board]
  def find_board!
    @board = Board.find(params[:board_id])
  end

  # Clear Flash cache so the past flashes won't appear during ajax responses
  # @return [void]
  def flash_clear
    flash.clear
  end
  # @!endgroup

  # Strong params that requer column title in the column scope
  # @return [String] column title
  def update_param
    params.require(:column).permit(:name)
  end
end
