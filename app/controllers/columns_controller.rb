class ColumnsController < ApplicationController
  before_action :find_column!, only: [:edit, :update, :destroy]
  before_action :find_board

  def index
  end

  def new
    respond_to do |format| 
      format.js
    end
  end

  # POST /column
  def create
    @column = @board.columns.create(column_params)
    respond_to do |format| 
      if @column.valid?
        format.js
        flash[:notice] = "Column was successfully created."
      else
        flash[:notice] = "There were an error!"
      end
    end
  end

  # PATCH/PUT /columns/1
  def edit    
  end

  def update
    @column = @board.columns.update(column_params)
    if @column
      flash[:notice] = "Column was successfully created."
    else
      flash[:notice] = "There were an error!"
    end
  end

  # DELETE /columns/1
  def destroy
  end

  private
  
  def find_column!
    @column = Column.find(params[:id])
  end

  def find_board
    @board = Board.find(params[:board_id])
  end

  def column_params
    params.require(:column).permit(:name, :board_id, :position)
  end

end
