class BoardsController < ApplicationController
	before_action :find_board, only: [:show, :edit,:update, :destroy]

  def index 
    if params.has_key? :filter 
      @filter = params[:filter]
      @boards = Board.filter(@filter).search(params[:search])
    else
      @boards = Board.all.search(params[:search])
    end

    @private_boards = @boards.private_boards
    @public_boards = @boards.public_boards
  end

  def show
  end

  def new
    @board = Board.new
  end

  def edit
  end
  
#!!! To do
  def create
    @board = Board.new(board_params)
    @board.user_id = 1  # @board.user_id = current_user.id
    if @board.save
      redirect_to @board
    else
      render 'new'
    end
  end

  def update
    flash[:success] = "Successfully updated!"
    if @board.update(board_params)
      redirect_to @board
    else
      render 'edit'
    end
  end

  def destroy
    if @board.destroy
      flash[:success] = "Successfully deleted!"
      redirect_to @board
    else
      flash[:error] = "Something went wrong, the acticle wasn't deleted"
    end
  end

private

  def find_board
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:title, :description, :search, :public)
  end
end