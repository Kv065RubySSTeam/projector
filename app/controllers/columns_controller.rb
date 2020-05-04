class ColumnsController < ApplicationController
  before_action :find_column!, only: [:edit, :update, :destroy]
  before_action :find_board
  before_action :flash_clear, except: [:new, :edit]

  def new; end

  # POST /column
  def create
    last_position = @board.columns.maximum(:position)

    @column = @board.columns.create(
      name: "Default Title",
      position: last_position.nil? ? 1 : last_position + 1,
      board_id: params[:board_id],
      user_id: current_user.id)

    if @column.save!
      respond_to do |format| 
        format.js
      end
      flash[:notice] = "Column was successfully created."
    else
      flash[:danger] = "With creatind were an error!"
    end
  end

  # PATCH/PUT /columns/1
  def edit    
  end

  def update
    if @column.update(column_params)
      respond_to do |format|
        format.js
      end
      flash[:notice] = "Column was successfully updated."
    else
      if @column.errors.any?
        str = ''
        @column.errors.full_messages.each do |message|
          str << message << "\n"
        end
        flash[:error] = str
      end
    end
  end

  # DELETE /columns/1
  def destroy
    @column = @board.columns.find(params[:id])
    if @column.destroy
      flash[:success] = nil
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
    params.require(:column).permit(:name)
  end
  
  def flash_clear
    flash.clear()
  end
end

