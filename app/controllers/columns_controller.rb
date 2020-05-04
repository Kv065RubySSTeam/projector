class ColumnsController < ApplicationController
  before_action :find_column!, only: [:edit, :update, :destroy]
  before_action :find_board

  def new
    respond_to do |format| 
      format.js
    end
  end

  # POST /column
  def create
    last_position = @board.columns.maximum(:position)

    @column = @board.columns.create(
      name: "Default Title",
      position: last_position.nil? ? 1 : last_position + 1,
      board_id: params[:board_id],
      user_id: current_user.id)

    respond_to do |format| 
      if @column.save!
        format.js
        flash[:notice] = "Column was successfully created."
      else
        flash[:danger] = "With creatind were an error!"
      end
    end
  end

  # PATCH/PUT /columns/1
  def edit    
  end

  def update
    respond_to do |format| 
      if @column.update(column_params)
        format.js
        flash[:notice] = "Column was successfully updated."
      else
        # показать ошибки
        flash[:danger] = "With updating were an error!"
      end
    end
  end

  # DELETE /columns/1
  def destroy
    @column = @board.columns.find(params[:id])
    if @column.destroy
      flash[:success] = "Comment was successfully deleted!"
      respond_to do |format|
        format.js
      end
    else
      flash[:danger] = "Something went wrong, the comment wasn't deleted"
    end
  end

  private
  
  def find_column!
    @column = Column.find(params[:id])
  end

  def find_board
    @board = Board.find(params[:board_id])
  end

  def column_params
    params.require(:column).permit(:name, :board_id)
  end

end
