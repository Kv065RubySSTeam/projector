class ColumnsController < ApplicationController
  before_action :find_column!, only: :update
  before_action :find_board!
  before_action :flash_clear, except: [:new, :edit]

  def new; end

  def create
    @column = ColumnTemplateBuilder.call(@board, current_user)

    respond_to do |f|  
      if @column
        f.js { flash[:success] = "Column was successfully created." }
      else
        f.js { flash[:error] = "With creatind were an error!" }
      end
    end
  end

  def edit; end  

  def update
    respond_to do |f|
      if @column.update(update_param)
        f.js { flash[:success] = "Column was successfully updated." }
      else
        f.js { flash[:error] = @column.errors.full_messages.join("\n") } 
      end
    end
  end

  # DELETE /columns/1
  def destroy
    @column = @board.columns.find(params[:id])
    respond_to do |f|
      if @column.destroy
        f.js { flash[:success] = "Comment was successfully deleted!" } 
      else
        f.js { flash[:error] = "Something went wrong, the comment wasn't deleted" }
      end
    end
  end

  private  
  def find_column!
    @column = Column.find(params[:id])
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

