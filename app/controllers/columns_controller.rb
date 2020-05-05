class ColumnsController < ApplicationController
  before_action :find_column!, only: :update
  before_action :find_board!

  def new
  end

  def create
    last_position = @board.columns.maximum(:position)

    @column = @board.columns.build(name: "Default Title", 
      position: last_position.nil? ? 1 : last_position + 1,
      board_id: params[:board_id],
      user_id: current_user.id)

    if @column.save
      respond_to do |f| 
        f.js
      end
      flash[:notice] = "Column was successfully created."
    else
      flash[:error] = "With creatind were an error!"
    end
  end

  # PATCH /columns/:id
  def edit
  end

  def update
    if @column.update(update_param)
      flash[:notice] = "Column was successfully updated."
    else
      # показать ошибки
      flash[:error] = "With updating were an error!"
    end

  end

  # DELETE /columns/1
  def destroy
    @column = @board.columns.find(params[:id])
    if @column.destroy
      respond_to do |f|
        f.js
      end
      flash[:success] = "Comment was successfully deleted!"   
    else
      flash[:error] = "Something went wrong, the comment wasn't deleted"
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

end
