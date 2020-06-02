class BoardsController < ApplicationController
  load_and_authorize_resource :board, except: [:create, :export, :members]
  before_action :find_board!, except: [:index, :new, :create]
  before_action :flash_clear, except: [:index, :show]

  def index
    @boards = Board.filter(params[:filter], current_user)
      .search(params[:search])
      .sorting(params[:sort])
      .paginate(page: params[:page])
  end

  def show
    @columns = @board.columns.order(position: :asc)
    @column = @board.columns.new
  end

  def new
    @board = Board.new
  end

  def edit; end

  def create
    @board = Boards::CreateService.call(current_user, board_params)
    if @board.errors.empty?
      redirect_to @board
      flash[:success] = "Board successfully created!"
    else
      render 'new', status: 422
    end
  end

  def update
    if @board.update(board_params)
      redirect_to @board
      flash[:success] = "Board successfully updated!"
    else
      render 'edit', status: 422
    end
  end

  def destroy
    if @board.destroy
      redirect_to root_path
      flash[:success] = "Board successfully deleted!"
    else
      respond_to :js
      flash[:error] = "Board has not been deleted! Something went wrong"
      render status: 422
    end
  end

  def export
    if !params[:export_id].nil?
      BoardJobs::ExportJob.perform_later(params[:export_id], @board)
    else
      BoardJobs::ExportMailJob.perform_later(current_user.email, @board)
    end
  end

  def members
    respond_to do |f|
      f.json { render json: @board.users }
    end
  end

  private

  def find_board!
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:title, :description, :public)
  end

  def flash_clear
    flash.clear()
  end

end
