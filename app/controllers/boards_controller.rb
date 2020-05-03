class BoardsController < ApplicationController
  before_action :find_board!, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @boards = Board.filter(params[:filter], current_user)
    .search(params[:search]).paginate(page: params[:page])
  end

  def show
    @board = Board.find(params[:id])
  end

  def new
    @board = Board.new
  end

  def edit
  end

  def create
    @board = current_user.boards.new(board_params)
    if @board.save
      redirect_to @board
    else
      render 'new'
    end
  end

  def update
    if @board.update(board_params)
      flash[:success] = "Successfully updated!"
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

  def find_board!
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:title, :description, :public)
  end
end
