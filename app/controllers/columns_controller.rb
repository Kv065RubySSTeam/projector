class ColumnsController < ApplicationController

  before_action :find_board!
  before_action :find_column!, only: [:update, :destroy]  
  before_action :flash_clear, except: :new

  def new; end

  def edit; end

  def create
    @column = Columns::CreateService.call(@board, current_user)
    respond_to do |f|  
      if @column.save
        f.js { flash[:success] = "Column was successfully created." }
      else
        f.js { flash[:error] = @column.errors.full_messages.join("\n") }
      end
    end
  end

  def update
    @previousName = @column.name
    respond_to do |f|
      if @column.update(update_param)
        f.js { flash[:success] = "Column was successfully updated." }
      else
        f.js { flash[:error] = @column.errors.full_messages.join("\n") } 
      end
    end
  end

  def destroy
    respond_to do |f|
      if @column.destroy
        f.js { flash[:success] = "Column was successfully deleted!" } 
      else
        f.js { flash[:error] = @column.errors.full_messages.join("\n") }
      end
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
