class ColumnsController < ApplicationController
  load_and_authorize_resource :board
  load_and_authorize_resource :column, through: :board
  before_action :find_board!
  before_action :find_column!, only: [:update, :destroy]
  before_action :flash_clear, except: :new
  respond_to :js

  def new; end

  def create
    @column = Columns::CreateService.call(@board, current_user)
    if @column.errors.empty?
      flash[:success] = "Column was successfully created."
    else
      flash[:error] = @column.errors.full_messages.join("\n")
    end
  end

  def update
    @previousName = @column.name
    if @column.update(update_param)
      flash[:success] = "Column was successfully updated."
    else
      flash[:error] = @column.errors.full_messages.join("\n")
    end
  end

  def destroy
    if @column.destroy
      flash[:success] = "Column was successfully deleted!"
    else
      flash[:error] = @column.errors.full_messages.join("\n")
    end
  end

  private
  def find_column!
    @column = @board.columns.find(params[:id])
  end

  def find_board!
    @board = Board.find(params[:board_id])
  end

  def update_param
    params.require(:column).permit(:name)
  end

  def flash_clear
    flash.clear()
  end
  
end
